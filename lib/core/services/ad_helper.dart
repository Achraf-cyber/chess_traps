import 'package:chess_traps/config/env.dart';
import 'package:chess_traps/core/services/remote_config_service.dart';

class AdHelper {
  static String get interstitialAdUnitId {
    if (!RemoteConfigService().showLiveAds) return Env.current.admobInterstitial;
    return Env.current.admobInterstitial;
  }

  static String get rewardedInterstitialAdUnitId {
    if (!RemoteConfigService().showLiveAds) return Env.current.admobRewarded;
    return Env.current.admobRewarded;
  }

  static String get openingAdUnitId {
    if (!RemoteConfigService().showLiveAds) return Env.current.admobOpening;
    return Env.current.admobOpening;
  }

  static DateTime? lastPopupAdShownAt;
  static int sessionPopupAdsShownCount = 0;

  static bool canShowPopupAd() {
    final remoteConfig = RemoteConfigService();
    if (!remoteConfig.adsEnabled || !remoteConfig.popupAdsActive) return false;
    if (sessionPopupAdsShownCount >= remoteConfig.maxNumberOfPopupAdsPerSession) return false;

    final now = DateTime.now();
    // Honour the remote-configured cooldown instead of a hardcoded 5 min.
    final cooldown = Duration(
      minutes: remoteConfig.minTimeBetweenPopupsAdsInMinutes,
    );
    if (lastPopupAdShownAt != null && now.difference(lastPopupAdShownAt!) < cooldown) {
      return false;
    }
    return true;
  }

  static void recordPopupAdShown() {
    lastPopupAdShownAt = DateTime.now();
    sessionPopupAdsShownCount++;
  }
}
