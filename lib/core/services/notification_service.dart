import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (kIsWeb) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(const InitializationSettings(android: android, iOS: ios));
    _initialized = true;
  }

  Future<void> showSyncSuccess(String body) async {
    if (!_initialized || kIsWeb) return;
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'nova_sync',
        'Sync updates',
        channelDescription: 'Queued transfers and contributions',
        importance: Importance.defaultImportance,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(0, 'NovaPay', body, details);
  }
}
