// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  final result = Process.runSync('git', ['rev-parse', '--abbrev-ref', 'HEAD']);
  if (result.exitCode != 0) {
    print('Error: Could not determine git branch name.');
    exit(1);
  }

  final branchName = (result.stdout as String).trim();

  // Allowed specific branches:
  final exactAllowed = ['main', 'develop'];

  // Allowed prefixed branches
  // feat/SCRUM-ID-description
  // fix/SCRUM-ID-description
  // hotfix/description
  final featFixPattern = RegExp(r'^(feat|fix)/[a-zA-Z0-9]+-\d+-.*$');
  final hotfixPattern = RegExp(r'^hotfix/.*$');

  if (exactAllowed.contains(branchName)) {
    print('✅ Branch name "$branchName" is allowed.');
    exit(0);
  } else if (featFixPattern.hasMatch(branchName) ||
      hotfixPattern.hasMatch(branchName)) {
    print('✅ Branch name "$branchName" follows convention.');
    exit(0);
  } else {
    print('''
❌ Invalid Branch Name!

Current branch name: "$branchName"

Allowed branch name conventions:
- main
- develop
- feat/SCRUM-ID-description
- fix/SCRUM-ID-description
- hotfix/description

Examples:
- feat/SCRUM-10-setup-flavors
- fix/SCRUM-12-login-bug
- hotfix/patch-v1.1
''');
    exit(1);
  }
}
