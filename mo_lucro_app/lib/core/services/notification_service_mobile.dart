import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Mobile implementation with flutter_local_notifications.
final _plugin = FlutterLocalNotificationsPlugin();
bool _initialized = false;

Future<void> initialize() async {
  if (_initialized) return;

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const settings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await _plugin.initialize(settings);
  _initialized = true;
}

Future<void> show({
  required int id,
  required String title,
  required String body,
  String? payload,
}) async {
  const androidDetails = AndroidNotificationDetails(
    'mo_lucro_channel',
    'Mo Lucro',
    channelDescription: 'Notificações do Mo Lucro',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );
  const iosDetails = DarwinNotificationDetails();
  const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
  await _plugin.show(id, title, body, details, payload: payload);
}

Future<void> schedule({
  required int id,
  required String title,
  required String body,
  required DateTime scheduledDate,
  String? payload,
}) async {
  final delay = scheduledDate.difference(DateTime.now());
  if (delay.isNegative) return;
  Future.delayed(delay, () {
    show(id: id, title: title, body: body, payload: payload);
  });
}

Future<void> scheduleMaturityReminders(
  List<Map<String, dynamic>> maturities,
) async {
  for (int i = 0; i < maturities.length; i++) {
    final m = maturities[i];
    final dateStr = m['maturityDate'] as String?;
    if (dateStr == null) continue;
    final maturityDate = DateTime.tryParse(dateStr);
    if (maturityDate == null) continue;
    final daysLeft = maturityDate.difference(DateTime.now()).inDays;

    if (daysLeft > 7) {
      await schedule(
        id: 1000 + i,
        title: '📅 Vencimento em 7 dias',
        body: '${m['name']} vence em ${maturityDate.day}/${maturityDate.month}.',
        scheduledDate: maturityDate.subtract(const Duration(days: 7)),
        payload: 'maturity_${m['id']}',
      );
    }
    if (daysLeft > 0) {
      await schedule(
        id: 2000 + i,
        title: '🔔 Investimento vence hoje!',
        body: '${m['name']} vence hoje. Planeje o reinvestimento.',
        scheduledDate: maturityDate,
        payload: 'maturity_${m['id']}',
      );
    }
  }
}

Future<void> scheduleGoalReminder({
  required String goalName,
  required double progress,
}) async {
  final nextReminder = DateTime.now().add(const Duration(days: 30));
  await schedule(
    id: goalName.hashCode,
    title: '🎯 Acompanhe sua meta',
    body: '$goalName — ${(progress * 100).toInt()}% concluída. Continue assim!',
    scheduledDate: nextReminder,
    payload: 'goal_reminder',
  );
}

Future<void> cancelAll() => _plugin.cancelAll();
Future<void> cancel(int id) => _plugin.cancel(id);
