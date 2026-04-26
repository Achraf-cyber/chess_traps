import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:chess_traps/generated/chess/base_chess_traps.dart';
import 'package:chess_traps/router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class NotificationService {
  factory NotificationService() => _instance;
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const _prefTimeHour = 'notification_time_hour';
  static const _prefTimeMinute = 'notification_time_minute';
  static const _prefEnabled = 'notification_enabled';

  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      await _configureLocalTimezone();
    } catch (e) {
      debugPrint('Failed to configure local timezone: $e');
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        if (chessTraps.isEmpty) return;
        final now = DateTime.now();
        final dayOfYear =
            now.difference(DateTime(now.year)).inDays;
        final index = dayOfYear % chessTraps.length;
        router.push(TrapDetailRoute(index: index).location);
      },
    );

    // Request Android 13+ notification permission proactively at startup.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    // Default: Enabled, 9:00 AM
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_prefEnabled)) {
      await prefs.setBool(_prefEnabled, true);
      await prefs.setInt(_prefTimeHour, 9);
      await prefs.setInt(_prefTimeMinute, 0);
    }

    final enabled = prefs.getBool(_prefEnabled) ?? true;
    if (enabled) {
      final hour = prefs.getInt(_prefTimeHour) ?? 9;
      final minute = prefs.getInt(_prefTimeMinute) ?? 0;
      await scheduleDailyNotification(TimeOfDay(hour: hour, minute: minute));
    }
  }

  Future<void> requestPermission() async {
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
  }

  Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;
    final android = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final canSchedule = await android?.canScheduleExactNotifications();
    return canSchedule ?? false;
  }

  Future<void> requestExactAlarmsPermission() async {
    if (Platform.isAndroid) {
      final android = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.requestExactAlarmsPermission();
    }
  }

  Future<bool> isIgnoringBatteryOptimizations() async {
    if (!Platform.isAndroid) return true;
    return await Permission.ignoreBatteryOptimizations.isGranted;
  }

  Future<void> requestIgnoreBatteryOptimizations() async {
    if (Platform.isAndroid) {
      await Permission.ignoreBatteryOptimizations.request();
    }
  }

  Future<void> _configureLocalTimezone() async {
    try {
      final String? deviceTimeZone = await FlutterTimezone.getLocalTimezone();
      if (deviceTimeZone == null) return;
      final location = tz.getLocation(deviceTimeZone);
      tz.setLocalLocation(location);
    } catch (_) {
      // Keep default location if timezone lookup fails.
    }
  }

  Future<void> scheduleDailyNotification(TimeOfDay time) async {
    await requestPermission();
    await flutterLocalNotificationsPlugin.cancelAll();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefTimeHour, time.hour);
    await prefs.setInt(_prefTimeMinute, time.minute);
    await prefs.setBool(_prefEnabled, true);

    final details = const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_trap_channel',
        'Daily Trap Notifications',
        channelDescription: 'Reminds you to check the trap of the day',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    final scheduledDate = _nextInstanceOfTime(time);
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: 0,
        title: '✨ Trap of the Day is Ready!',
        body: 'Jump in to learn a new opening trap and boost your rating ♟️',
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      // Fallback when exact alarms are unavailable on some Android setups.
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: 0,
        title: '✨ Trap of the Day is Ready!',
        body: 'Jump in to learn a new opening trap and boost your rating ♟️',
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> cancelNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefEnabled, false);
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
