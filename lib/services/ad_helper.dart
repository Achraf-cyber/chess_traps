import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdHelper {
  static String get bannerAdUnitId =>
      dotenv.env['ADMOB_BANNER'] ?? 'ca-app-pub-3940256099942544/6300978111';

  static String get interstitialAdUnitId =>
      dotenv.env['ADMOB_INTERSTITIAL'] ??
      'ca-app-pub-3940256099942544/1033173712';

  static String get rewardedInterstitialAdUnitId =>
      dotenv.env['ADMOB_REWARDED'] ?? 'ca-app-pub-3940256099942544/5224354917';

  static String get openingAdUnitId =>
      dotenv.env['ADMOB_OPENING'] ?? 'ca-app-pub-3940256099942544/3419835294';
}
