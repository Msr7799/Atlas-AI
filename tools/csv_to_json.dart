import 'dart:convert';
import 'dart:io';

/// Simple converter from a two-column CSV (Polarity,Review Text)
/// to a JSON array of objects: [{"polarity": 0, "text": "..."}, ...]
/// Usage:
///   dart tools/csv_to_json.dart <input_csv> <output_json>
Future<void> main(List<String> args) async {
  if (args.length < 2) {
    stderr.writeln('Usage: dart tools/csv_to_json.dart <input_csv> <output_json>');
    exit(64);
  }
  final inputPath = args[0];
  final outputPath = args[1];

  final inputFile = File(inputPath);
  if (!await inputFile.exists()) {
    stderr.writeln('Input file not found: $inputPath');
    exit(66);
  }

  final lines = await inputFile.readAsLines(encoding: utf8);
  if (lines.isEmpty) {
    stderr.writeln('Input file is empty');
    exit(65);
  }

  // Skip header if it starts with Polarity,Review Text
  int startIndex = 0;
  final header = lines.first.trim();
  if (header.toLowerCase().startsWith('polarity,review text')) {
    startIndex = 1;
  }

  final List<Map<String, dynamic>> items = [];

  for (int i = startIndex; i < lines.length; i++) {
    final raw = lines[i];
    if (raw.trim().isEmpty) continue;

    // Split at the first comma only (first field is polarity)
    final commaIndex = raw.indexOf(',');
    if (commaIndex == -1) {
      stderr.writeln('Skipping malformed line ${i + 1}: missing comma');
      continue;
    }

    final polarityStr = raw.substring(0, commaIndex).trim();
    var textPart = raw.substring(commaIndex + 1);

    // Remove surrounding quotes if present and unescape double quotes
    textPart = textPart.trim();
    if (textPart.startsWith('"') && textPart.endsWith('"')) {
      textPart = textPart.substring(1, textPart.length - 1);
    }
    textPart = textPart.replaceAll('""', '"');

    int? polarity;
    try {
      polarity = int.parse(polarityStr);
    } catch (_) {
      // Some rows may have BOM or stray chars; try to cleanup
      final cleaned = polarityStr.replaceAll(RegExp(r'[^0-9\-]'), '');
      if (cleaned.isEmpty) {
        stderr.writeln('Skipping line ${i + 1}: invalid polarity "$polarityStr"');
        continue;
      }
      try {
        polarity = int.parse(cleaned);
      } catch (e) {
        stderr.writeln('Skipping line ${i + 1}: cannot parse polarity "$polarityStr"');
        continue;
      }
    }

    items.add({
      'polarity': polarity,
      'text': textPart,
    });
  }

  final outFile = File(outputPath);
  await outFile.create(recursive: true);
  // Pretty JSON for readability
  final encoder = const JsonEncoder.withIndent('  ');
  await outFile.writeAsString(encoder.convert(items), encoding: utf8);

  stdout.writeln('Wrote ${items.length} items to $outputPath');
}
