import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();
  static final RemoteConfigService _instance = RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  final Completer<void> _ready = Completer<void>();

  /// Completes once [initialize] has finished, whether the fetch succeeded or
  /// not. Values read before this are the in-app defaults.
  Future<void> get ready => _ready.future;

  static const String _adsEnabledKey = 'ads_enabled';
  static const String _showLiveAdsKey = 'show_live_ads';
  static const String _minTimeBetweenPopupsAdsInMinutesKey = 'min_time_between_popups_ads_in_minutes';
  static const String _maxNumberOfPopupAdsPerSessionKey = 'max_number_of_popup_ads_per_session';
  static const String _popupAdsActiveKey = 'popup_ads_active';
  // How many trap detail views a user gets per day before the rewarded-unlock
  // sheet appears. Deliberately generous by default so only heavy users ever
  // see it; tune this remotely against retention without shipping a release.
  static const String _dailyFreeTrapViewsKey = 'daily_free_trap_views';
  // JSON object of chess clubs keyed by join code. See Club for the format.
  static const String _clubsKey = 'clubs';

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
        _clubsKey: '{}',
      });

      await _remoteConfig.fetchAndActivate();
      debugPrint('Remote Config initialized: ads_enabled=$adsEnabled, show_live_ads=$showLiveAds');
    } catch (e) {
      debugPrint('Remote Config initialization failed: $e');
    } finally {
      if (!_ready.isCompleted) _ready.complete();
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

  /// Raw JSON of the club map; parsed by the club provider.
  String get clubsJson => _remoteConfig.getString(_clubsKey);

  /// True when [clubsJson] came from the server rather than the in-app
  /// default. A club missing from the server's map has been revoked; one
  /// missing from the default '{}' only means we have never fetched.
  bool get clubsFromServer =>
      _remoteConfig.getValue(_clubsKey).source == ValueSource.valueRemote;

  /// Fetches now, ignoring the usual one-hour interval.
  ///
  /// Used when someone types a code we don't know: the club may have been
  /// added to the console minutes ago, after this device's last fetch.
  Future<void> refreshNow() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero,
        ),
      );
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Remote Config refresh failed: $e');
    } finally {
      try {
        await _remoteConfig.setConfigSettings(
          RemoteConfigSettings(
            fetchTimeout: const Duration(minutes: 1),
            minimumFetchInterval: kDebugMode
                ? const Duration(minutes: 5)
                : const Duration(hours: 1),
          ),
        );
      } catch (_) {}
    }
  }
}
