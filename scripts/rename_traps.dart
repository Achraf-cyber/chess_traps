import 'dart:io';
import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  // 1. Read API Key
  final apiKey = _getApiKey();
  if (apiKey == null || apiKey.isEmpty) {
    stderr.writeln(
      'Error: GOOGLE_AI_KEY not found in .env.dev or environment.',
    );
    exit(1);
  }

  // 2. Setup Gemini
  final model = GenerativeModel(
    model: 'gemini-2.0-flash-lite',
    apiKey: apiKey,
    generationConfig: GenerationConfig(responseMimeType: 'application/json'),
  );

  // 3. Find PGN files
  final trapsDir = Directory('data/chess traps');
  if (!await trapsDir.exists()) {
    stderr.writeln('Folder not found: ${trapsDir.path}');
    return;
  }

  final pgnFiles = await trapsDir
      .list()
      .where((e) => e is File && e.path.toLowerCase().endsWith('.pgn'))
      .cast<File>()
      .toList();

  if (pgnFiles.isEmpty) {
    stderr.writeln('No PGN files found.');
    return;
  }

  for (final file in pgnFiles) {
    await _processPgnFile(file, model);
  }

  stdout.writeln('\nAll PGN files processed successfully!');
}

Future<void> _processPgnFile(File file, GenerativeModel model) async {
  stdout.writeln('Processing file: ${file.path}');
  final content = await file.readAsString();
  final games = _splitPgnIntoGames(content).toList();

  if (games.isEmpty) return;

  final newContent = StringBuffer();
  final batchSize = 10;

  for (var i = 0; i < games.length; i += batchSize) {
    final batch = games.sublist(
      i,
      i + batchSize > games.length ? games.length : i + batchSize,
    );

    stdout.writeln(
      '  Analyzing games ${i + 1} to ${i + batch.length} out of ${games.length}...',
    );

    // Prepare the prompt
    final prompt = StringBuffer();
    prompt.writeln(
      'You are a chess grandmaster and linguist. I will provide a batch of chess traps/miniatures. Each is given with its ID, current Event name, and moves.',
    );
    prompt.writeln(
      'Your task: Identify the trap or miniature. If the current Event name is random or generic (e.g. "Corr.", "Internet", "Game 1"), provide a better, meaningful name combining the Opening and the Trap/Tactic (e.g., "Caro-Kann: Smyslov Trap" or "Alapin Opening: Smothered Mate"). If it is already good, you can keep it or slightly improve it.',
    );
    prompt.writeln(
      'Provide translations for the chosen name in French, Spanish, and Arabic.',
    );
    prompt.writeln(
      'Output strictly as a JSON array of objects with the following schema:',
    );
    prompt.writeln(
      '[ { "id": number, "new_name": "string", "fr": "string", "es": "string", "ar": "string" } ]\n',
    );
    prompt.writeln('Here is the batch:');

    for (var j = 0; j < batch.length; j++) {
      final gameStr = batch[j];
      final eventMatch = RegExp(r'\[Event\s+"([^"]+)"\]').firstMatch(gameStr);
      final eventName = eventMatch?.group(1) ?? 'Unknown';

      // Extract moves (simplistic extraction: everything after the last header)
      final movesPart = gameStr
          .replaceFirst(RegExp(r'(\[.*?\]\s*)+'), '')
          .trim();

      prompt.writeln('ID: $j');
      prompt.writeln('Current Name: $eventName');
      prompt.writeln('Moves: $movesPart');
      prompt.writeln('---');
    }

    try {
      final response = await model.generateContent([
        Content.text(prompt.toString()),
      ]);
      final responseText = response.text ?? '[]';

      // Parse JSON
      List<dynamic> jsonResult;
      try {
        jsonResult = jsonDecode(responseText);
      } catch (e) {
        // Fallback: Gemini might have wrapped it in ```json ... ```
        final jsonMatch = RegExp(
          r'```json\n(.*?)\n```',
          dotAll: true,
        ).firstMatch(responseText);
        if (jsonMatch != null) {
          jsonResult = jsonDecode(jsonMatch.group(1));
        } else {
          throw Exception('Failed to parse JSON: $responseText');
        }
      }

      // Reconstruct games in the batch
      for (var j = 0; j < batch.length; j++) {
        var gameStr = batch[j];

        // Find matching response
        final match = jsonResult.firstWhere(
          (element) => element['id'] == j,
          orElse: () => null,
        );

        if (match != null) {
          final newName = match['new_name']?.toString() ?? '';
          final fr = match['fr']?.toString() ?? '';
          final es = match['es']?.toString() ?? '';
          final ar = match['ar']?.toString() ?? '';

          if (newName.isNotEmpty) {
            // Replace Event
            gameStr = gameStr.replaceFirst(
              RegExp(r'\[Event\s+"([^"]+)"\]'),
              '[Event "$newName"]',
            );

            // Inject translation tags right after Event
            final translationTags =
                '\n[Event_fr "$fr"]\n[Event_es "$es"]\n[Event_ar "$ar"]';
            gameStr = gameStr.replaceFirst(
              RegExp(r'\[Event\s+"([^"]+)"\]'),
              '[Event "$newName"]$translationTags',
            );
          }
        }

        newContent.writeln(gameStr);
        newContent.writeln('\n');
      }
    } catch (e) {
      stderr.writeln('Error generating content for batch: $e');
      // On error, just write the original games back to not lose them
      for (var j = 0; j < batch.length; j++) {
        newContent.writeln(batch[j]);
        newContent.writeln('\n');
      }
    }

    // Rate limiting: wait 4 seconds between batches
    if (i + batchSize < games.length) {
      await Future.delayed(const Duration(seconds: 4));
    }
  }

  // Rewrite file
  await file.writeAsString(newContent.toString().trim() + '\n');
}

String? _getApiKey() {
  // Check env variable
  if (Platform.environment.containsKey('GOOGLE_AI_KEY')) {
    return Platform.environment['GOOGLE_AI_KEY'];
  }

  // Try reading .env.dev
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

Iterable<String> _splitPgnIntoGames(String pgnFileContents) sync* {
  final normalized = pgnFileContents.replaceAll('\r\n', '\n').trim();
  if (normalized.isEmpty) return;

  final parts = normalized.split(RegExp(r'(?=\[Event\s+")'));
  for (final part in parts) {
    final chunk = part.trim();
    if (chunk.isEmpty) continue;
    if (!chunk.startsWith('[Event')) continue;
    yield chunk;
  }
}
