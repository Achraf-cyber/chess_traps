import 'package:flutter/foundation.dart';
import 'debug_config.dart';
import 'prod_config.dart';

abstract class Env {
  String get admobAppId;
  String get admobBanner;
  String get admobInterstitial;
  String get admobRewarded;
  String get admobOpening;
  String get googleAiKey;

  static Env get current => kDebugMode ? DebugConfig() : ProdConfig();
}
