import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:chess_traps/generated/chess/base_chess_traps.dart';
import 'package:chess_traps/router.dart';
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

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        const DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
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

  Future<void> scheduleDailyNotification(TimeOfDay time) async {
    await requestPermission();
    await flutterLocalNotificationsPlugin.cancelAll();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefTimeHour, time.hour);
    await prefs.setInt(_prefTimeMinute, time.minute);
    await prefs.setBool(_prefEnabled, true);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: 0,
      title: '✨ Trap of the Day is Ready!',
      body: 'Jump in to learn a new opening trap and boost your rating ♟️',
      scheduledDate: _nextInstanceOfTime(time),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_trap_channel',
          'Daily Trap Notifications',
          channelDescription: 'Reminds you to check the trap of the day',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
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
