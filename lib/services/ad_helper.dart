import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:chess_traps/services/remote_config_service.dart';

class AdHelper {
  // Test IDs from: https://developers.google.com/admob/android/test-ads
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedId = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testOpeningId = 'ca-app-pub-3940256099942544/9257395921';

  static String get bannerAdUnitId {
    if (!RemoteConfigService().showLiveAds) return _testBannerId;
    return dotenv.env['ADMOB_BANNER'] ?? _testBannerId;
  }

  static String get interstitialAdUnitId {
    if (!RemoteConfigService().showLiveAds) return _testInterstitialId;
    return dotenv.env['ADMOB_INTERSTITIAL'] ?? _testInterstitialId;
  }

  static String get rewardedInterstitialAdUnitId {
    if (!RemoteConfigService().showLiveAds) return _testRewardedId;
    return dotenv.env['ADMOB_REWARDED'] ?? _testRewardedId;
  }

  static String get openingAdUnitId {
    if (!RemoteConfigService().showLiveAds) return _testOpeningId;
    return dotenv.env['ADMOB_OPENING'] ?? _testOpeningId;
  }
}
