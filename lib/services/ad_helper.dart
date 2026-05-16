import 'package:chess_traps/config/env.dart';
import 'package:chess_traps/services/remote_config_service.dart';

class AdHelper {
  static String get bannerAdUnitId {
    if (!RemoteConfigService().showLiveAds) return Env.current.admobBanner;
    return Env.current.admobBanner;
  }

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
    final cooldown = Duration(minutes: remoteConfig.minTimeBetweenPopupsAdsInMinutes);
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
