import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();
  static final RemoteConfigService _instance = RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  static const String _adsEnabledKey = 'ads_enabled';
  static const String _showLiveAdsKey = 'show_live_ads';
  static const String _minTimeBetweenPopupsAdsInMinutesKey = 'min_time_between_popups_ads_in_minutes';
  static const String _maxNumberOfPopupAdsPerSessionKey = 'max_number_of_popup_ads_per_session';
  static const String _popupAdsActiveKey = 'popup_ads_active';
  // How many trap detail views a user gets per day before the rewarded-unlock
  // sheet appears. Deliberately generous by default so only heavy users ever
  // see it; tune this remotely against retention without shipping a release.
  static const String _dailyFreeTrapViewsKey = 'daily_free_trap_views';

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: kDebugMode 
              ? const Duration(minutes: 5) 
              : const Duration(hours: 1),
        ),
      );

      await _remoteConfig.setDefaults({
        _adsEnabledKey: false,
        _showLiveAdsKey: false,
        _minTimeBetweenPopupsAdsInMinutesKey: 5,
        _maxNumberOfPopupAdsPerSessionKey: 10,
        _popupAdsActiveKey: true,
        _dailyFreeTrapViewsKey: 25,
      });

      await _remoteConfig.fetchAndActivate();
      debugPrint('Remote Config initialized: ads_enabled=$adsEnabled, show_live_ads=$showLiveAds');
    } catch (e) {
      debugPrint('Remote Config initialization failed: $e');
    }
  }

  bool get adsEnabled => _remoteConfig.getBool(_adsEnabledKey);
  bool get showLiveAds => _remoteConfig.getBool(_showLiveAdsKey);
  int get minTimeBetweenPopupsAdsInMinutes => _remoteConfig.getInt(_minTimeBetweenPopupsAdsInMinutesKey);
  int get maxNumberOfPopupAdsPerSession => _remoteConfig.getInt(_maxNumberOfPopupAdsPerSessionKey);
  bool get popupAdsActive => _remoteConfig.getBool(_popupAdsActiveKey);

  /// Free trap views per day before the rewarded-unlock prompt. Falls back to
  /// a generous default if the remote value is unset/zero.
  int get dailyFreeTrapViews {
    final v = _remoteConfig.getInt(_dailyFreeTrapViewsKey);
    return v > 0 ? v : 25;
  }
}
