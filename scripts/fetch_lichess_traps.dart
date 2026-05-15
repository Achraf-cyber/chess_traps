import 'dart:convert';
import 'dart:io';

void main() async {
  final query = 'chess traps';
  final url = Uri.parse('https://lichess.org/study/search?q=${Uri.encodeComponent(query)}');
  
  final client = HttpClient();
  stdout.writeln('Searching Lichess for: $query...');
  
  try {
    final request = await client.getUrl(url);
    final response = await request.close();
    
    if (response.statusCode == 200) {
      final html = await response.transform(utf8.decoder).join();
      final regex = RegExp(r'href="/study/([a-zA-Z0-9]+)"');
      final matches = regex.allMatches(html);
      
      final studyIds = matches.map((m) => m.group(1)!).toSet().toList();
      stdout.writeln('Found ${studyIds.length} studies: $studyIds');
      
      int downloaded = 0;
      for (final id in studyIds.take(5)) { // Download top 5 studies
        stdout.writeln('Downloading study $id...');
        final pgnUrl = Uri.parse('https://lichess.org/api/study/$id.pgn');
        final pgnReq = await client.getUrl(pgnUrl);
        final pgnRes = await pgnReq.close();
        
        if (pgnRes.statusCode == 200) {
          final pgnData = await pgnRes.transform(utf8.decoder).join();
          final file = File('data/chess traps/lichess_study_$id.pgn');
          await file.writeAsString(pgnData);
          stdout.writeln('Saved ${file.path}');
          downloaded++;
        } else {
          stdout.writeln('Failed to download study $id');
        }
        await Future<void>.delayed(const Duration(seconds: 1)); // Be nice to Lichess API
      }
      stdout.writeln('Downloaded $downloaded studies.');
    } else {
      stdout.writeln('Failed to search Lichess: ${response.statusCode}');
    }
  } catch (e) {
    stdout.writeln('Error: $e');
  } finally {
    client.close();
  }
}
