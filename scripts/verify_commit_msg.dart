import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Error: Missing commit message file path.');
    exit(1);
  }

  final file = File(args.first);
  if (!file.existsSync()) {
    print('Error: Commit message file not found.');
    exit(1);
  }

  final lines = file.readAsLinesSync();
  if (lines.isEmpty) {
    print('Error: Commit message is empty.');
    exit(1);
  }

  // We only check the first line (the subject)
  final subject = lines.first;

  if (subject.startsWith('Merge ') || subject.startsWith('Revert ')) {
    print('✅ Ignoring merge/revert commit format.');
    exit(0);
  }

  // Pattern: type(scope): description [SCRUM-ID]
  final pattern = RegExp(r'^([a-z]+)(?:\(([a-zA-Z0-9_\-]+)\))?:\s(.+)\s\[([a-zA-Z]+-\d+)\]$');
  final match = pattern.firstMatch(subject);

  void failCheck(String error) {
    print('\n❌ Invalid Commit Message Format!');
    print('\nYour commit message:\n"$subject"\n');
    print('Error: $error\n');
    print('''
Expected format:
type(scope): description [SCRUM-ID]

Rules:
1. type must be one of: feat, fix, docs, style, refactor, chore
2. (scope) is optional but must not contain spaces if provided
3. description must start with a lowercase letter and NOT end with a period
4. Must end with a [SCRUM-ID] (e.g., [SCRUM-123])

Examples of Valid Commits:
✅ feat(auth): add magic link login [SCRUM-12]
✅ fix: repair overflow on profile header [SCRUM-15]
✅ chore: bump supabase_flutter version [SCRUM-10]
''');
    exit(1);
  }

  if (match == null) {
    failCheck('Does not match basic structure (type(scope): description [ID])');
  }

  final type = match!.group(1)!;
  final description = match!.group(3)!;

  final allowedTypes = ['feat', 'fix', 'docs', 'style', 'refactor', 'chore'];
  if (!allowedTypes.contains(type)) {
    failCheck('Invalid type "$type". Allowed types are: ${allowedTypes.join(', ')}');
  }

  if (!description.startsWith(RegExp(r'[a-z]'))) {
    failCheck('Description must start with a lowercase letter');
  }

  if (description.endsWith('.')) {
    failCheck('Description must not end with a period (.)');
  }

  print('✅ Commit message format is valid.');
  exit(0);
}
