import 'package:flutter_local_notifications/flutter_local_notifications.dart';

  class NotificationService {
    static final FlutterLocalNotificationsPlugin _plugin =
        FlutterLocalNotificationsPlugin();
    static bool _initialized = false;

    static Future<void> init() async {
      if (_initialized) return;
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const settings = InitializationSettings(android: android);
      await _plugin.initialize(settings);
      _initialized = true;
    }

    static Future<void> showStreamNotification({
      required String channelName,
      required String category,
    }) async {
      await init();
      const androidDetails = AndroidNotificationDetails(
        'cricz_stream',
        'Stream Notifications',
        channelDescription: 'Live stream notifications',
        importance: Importance.high,
        priority: Priority.high,
      );
      const details = NotificationDetails(android: androidDetails);
      await _plugin.show(
        channelName.hashCode.abs(),
        '🔴 Now Watching: $channelName',
        '$category • CricZ TV Live',
        details,
      );
    }

    static Future<void> showFavoriteNotification(
        String channelName, bool added) async {
      await init();
      const androidDetails = AndroidNotificationDetails(
        'cricz_fav',
        'Favorites',
        channelDescription: 'Favorites notifications',
        importance: Importance.low,
        priority: Priority.low,
      );
      const details = NotificationDetails(android: androidDetails);
      await _plugin.show(
        0,
        added ? '❤️ Added to Favorites' : '💔 Removed from Favorites',
        channelName,
        details,
      );
    }
  }
  