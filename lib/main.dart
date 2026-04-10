// Default entry point — runs the dev flavor.
// Use the flavor-specific entry points instead:
//   --target lib/main_dev.dart  --flavor dev
//   --target lib/main_prod.dart --flavor prod
//
// See .vscode/launch.json for the configured launch configurations.

import 'app.dart';

Future<void> main() async {
  await runMainApp('.env.dev');
}
