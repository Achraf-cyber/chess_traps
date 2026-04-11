import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdHelper {
  static String get bannerAdUnitId => dotenv.env['ADMOB_BANNER']!;
  static String get intersticialAdUnitId => dotenv.env['ADMOB_INTERSTITIAL']!;
  static String get rewardedIntersticialAdUnitId => dotenv.env['ADMOB_REWARDED']!;
  static String get openingAdUnitId => dotenv.env['ADMOB_OPENING']!;
}
