import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();
  static final RemoteConfigService _instance = RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  static const String _adsEnabledKey = 'ads_enabled';
  static const String _showLiveAdsKey = 'show_live_ads';

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
      });

      await _remoteConfig.fetchAndActivate();
      debugPrint('Remote Config initialized: ads_enabled=$adsEnabled, show_live_ads=$showLiveAds');
    } catch (e) {
      debugPrint('Remote Config initialization failed: $e');
    }
  }

  bool get adsEnabled => _remoteConfig.getBool(_adsEnabledKey);
  bool get showLiveAds => _remoteConfig.getBool(_showLiveAdsKey);
}
