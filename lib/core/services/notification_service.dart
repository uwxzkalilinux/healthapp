import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      // طلب صلاحيات الإشعارات
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (!kIsWeb) {
          // إعداد الإشعارات المحلية للأجهزة
          const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
          const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
          const InitializationSettings initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
          
          await _localNotifications.initialize(initSettings);
        }

        // الاستماع للإشعارات في وضع التشغيل (Foreground)
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          if (message.notification != null && !kIsWeb) {
            _showLocalNotification(message.notification!);
          }
        });
      }
    } catch (e) {
      debugPrint('فشل في تهيئة الإشعارات: $e');
    }
  }

  Future<void> _showLocalNotification(RemoteNotification notification) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'health_app_channel',
      'إشعارات صحة +',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformDetails,
    );
  }

  Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      return null;
    }
  }
}
