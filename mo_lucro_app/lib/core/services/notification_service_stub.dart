/// Web stub — all notification methods are no-ops on web.

Future<void> initialize() async {}

Future<void> show({
  required int id,
  required String title,
  required String body,
  String? payload,
}) async {}

Future<void> schedule({
  required int id,
  required String title,
  required String body,
  required DateTime scheduledDate,
  String? payload,
}) async {}

Future<void> scheduleMaturityReminders(
  List<Map<String, dynamic>> maturities,
) async {}

Future<void> scheduleGoalReminder({
  required String goalName,
  required double progress,
}) async {}

Future<void> cancelAll() async {}
Future<void> cancel(int id) async {}
