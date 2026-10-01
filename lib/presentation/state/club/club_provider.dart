import 'dart:async';
import 'dart:convert';

import 'package:chess_traps/core/services/analytics_service.dart';
import 'package:chess_traps/core/services/app_link_service.dart';
import 'package:chess_traps/core/services/remote_config_service.dart';
import 'package:chess_traps/data/club/club.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The club this device joined, or null.
///
/// The club is cached on the device so its branding shows instantly and
/// offline. Once Remote Config has loaded, the cache is checked against the
/// server's club map: edits to the name, logo or color come through, and a
/// club removed from the map is dropped, which is how a code is revoked.
class ClubNotifier extends Notifier<Club?> {
  static const _clubKey = 'club';

  StreamSubscription<String>? _linkSub;

  @override
  Club? build() {
    _linkSub = AppLinkService.clubLinks.listen(
      (code) => join(code, source: 'link'),
    );
    ref.onDispose(() => _linkSub?.cancel());
    _init();
    return null;
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = _decodeCached(prefs.getString(_clubKey));
    if (!ref.mounted) return;
    if (cached != null) state = cached;

    // A club link that launched the app is handled after the cache is loaded,
    // so it can replace a previous club rather than race with it.
    final pendingCode = AppLinkService.takePendingClubCode();
    if (pendingCode != null) {
      await join(pendingCode, source: 'link');
      return;
    }

    await RemoteConfigService().ready;
    if (!ref.mounted) return;
    await _revalidate();
  }

  Future<void> _revalidate() async {
    final current = state;
    if (current == null) {
      unawaited(AnalyticsService.instance.setClubCode(null));
      return;
    }
    final config = RemoteConfigService();
    if (!config.clubsFromServer) {
      // Never fetched: keep the cached club rather than wiping it offline.
      unawaited(AnalyticsService.instance.setClubCode(current.code));
      return;
    }
    final fresh = _lookup(current.code);
    if (fresh == null) {
      await _save(null);
      unawaited(AnalyticsService.instance.setClubCode(null));
    } else {
      await _save(fresh);
      unawaited(AnalyticsService.instance.setClubCode(fresh.code));
    }
  }

  /// Joins the club with [code]. Returns false when no club has that code,
  /// even after fetching the latest club list.
  Future<bool> join(String code, {String source = 'code'}) async {
    final normalized = Club.normalizeCode(code);
    if (normalized.isEmpty) return false;

    var club = _lookup(normalized);
    if (club == null) {
      await RemoteConfigService().refreshNow();
      club = _lookup(normalized);
    }
    if (club == null || !ref.mounted) return false;

    await _save(club);
    unawaited(AnalyticsService.instance.setClubCode(club.code));
    unawaited(
      AnalyticsService.instance.logClubJoined(code: club.code, source: source),
    );
    return true;
  }

  Future<void> leave() async {
    final current = state;
    if (current == null) return;
    await _save(null);
    unawaited(AnalyticsService.instance.setClubCode(null));
    unawaited(AnalyticsService.instance.logClubLeft(code: current.code));
  }

  Future<void> _save(Club? club) async {
    final prefs = await SharedPreferences.getInstance();
    if (club == null) {
      await prefs.remove(_clubKey);
    } else {
      await prefs.setString(
        _clubKey,
        jsonEncode({'code': club.code, ...club.toJson()}),
      );
    }
    if (ref.mounted) state = club;
  }

  Club? _lookup(String code) {
    try {
      final map = jsonDecode(RemoteConfigService().clubsJson);
      if (map is! Map) return null;
      for (final entry in map.entries) {
        final key = entry.key;
        if (key is String && Club.normalizeCode(key) == code) {
          return Club.fromJson(key, entry.value);
        }
      }
    } catch (e) {
      debugPrint('Invalid clubs JSON in Remote Config: $e');
    }
    return null;
  }

  static Club? _decodeCached(String? raw) {
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw);
      if (json is! Map || json['code'] is! String) return null;
      return Club.fromJson(json['code'] as String, json);
    } catch (_) {
      return null;
    }
  }
}

final clubProvider = NotifierProvider<ClubNotifier, Club?>(ClubNotifier.new);
