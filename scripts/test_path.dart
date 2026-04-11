// ignore_for_file: avoid_print

import 'dart:isolate';

void main() async {
  final uri = await Isolate.resolvePackageUri(
    Uri.parse('package:chessground/chessground.dart'),
  );
  print(uri);
}
