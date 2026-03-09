import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';

// Conditional import: only pull in the plugin on non-web platforms.
import 'notification_service_stub.dart'
    if (dart.library.io) 'notification_service_mobile.dart' as platform;

/// Notification service — cross-platform.
/// Uses flutter_local_notifications on mobile, no-ops on web.
class NotificationService {
  static Future<void> initialize() => platform.initialize();

  static Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) =>
      platform.show(id: id, title: title, body: body, payload: payload);

  static Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) =>
      platform.schedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          payload: payload);

  static Future<void> scheduleMaturityReminders(
    List<Map<String, dynamic>> maturities,
  ) =>
      platform.scheduleMaturityReminders(maturities);

  static Future<void> scheduleGoalReminder({
    required String goalName,
    required double progress,
  }) =>
      platform.scheduleGoalReminder(goalName: goalName, progress: progress);

  static Future<void> cancelAll() => platform.cancelAll();
  static Future<void> cancel(int id) => platform.cancel(id);

  static Future<bool> areNotificationsEnabled() async {
    final box = await Hive.openBox('settings');
    return box.get('notifications_enabled', defaultValue: true) as bool;
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    final box = await Hive.openBox('settings');
    await box.put('notifications_enabled', enabled);
    if (!enabled) await cancelAll();
  }
}
