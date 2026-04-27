import 'dart:io';
import 'dart:convert';

void main() async {
  final apiKey = Platform.environment['GOOGLE_AI_KEY'] ?? _getApiKey();
  if (apiKey == null) {
    print('No API key');
    return;
  }
  
  final client = HttpClient();
  final request = await client.getUrl(Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey'));
  final response = await request.close();
  final responseBody = await response.transform(utf8.decoder).join();
  final json = jsonDecode(responseBody) as Map<String, dynamic>;
  final models = json['models'] as List<dynamic>?;
  if (models != null) {
    for (final model in models) {
      print(model['name']);
    }
  } else {
    print(responseBody);
  }
  client.close();
}

String? _getApiKey() {
  final envFile = File('.env.dev');
  if (envFile.existsSync()) {
    for (final line in envFile.readAsLinesSync()) {
      if (line.startsWith('GOOGLE_AI_KEY=')) {
        return line.substring('GOOGLE_AI_KEY='.length).trim();
      }
    }
  }
  return null;
}
