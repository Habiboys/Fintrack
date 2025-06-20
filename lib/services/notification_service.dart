import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fintrack/services/auth_service.dart';
import 'package:logger/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Top level function untuk handle background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
  print('Message data: ${message.data}');
  print('Message notification: ${message.notification?.title}');
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final AuthService _authService = AuthService();
  final _logger = Logger();

  // Instance FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    _logger.i('Initializing Firebase Messaging...');

    try {
      // Inisialisasi local notifications
      const androidInitialize = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosInitialize = DarwinInitializationSettings();
      const initializationsSettings = InitializationSettings(
        android: androidInitialize,
        iOS: iosInitialize,
      );

      await flutterLocalNotificationsPlugin.initialize(
        initializationsSettings,
        onDidReceiveNotificationResponse: (details) {
          _logger.i('Local notification tapped: ${details.payload}');
        },
      );

      // Buat channel notification untuk Android
      const androidChannel = AndroidNotificationChannel(
        'high_importance_channel',
        'Notifikasi Transaksi',
        description: 'Channel untuk notifikasi transaksi',
        importance: Importance.max,
      );

      // Register channel di Android
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(androidChannel);

      // Request permission untuk iOS
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      _logger.i('User granted permission: ${settings.authorizationStatus}');

      // Handle notifikasi ketika aplikasi di background
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Handle notifikasi ketika aplikasi dibuka
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _logger.i('Got a message whilst in the foreground!');
        _logger.d('Message data: ${message.data}');

        RemoteNotification? notification = message.notification;

        // Tampilkan notifikasi lokal untuk semua pesan, tidak perlu cek android
        if (notification != null) {
          _logger.i('Showing local notification for foreground message');
          _logger.i('Title: ${notification.title}');
          _logger.i('Body: ${notification.body}');

          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: const AndroidNotificationDetails(
                'high_importance_channel',
                'Notifikasi Transaksi',
                channelDescription: 'Channel untuk notifikasi transaksi',
                icon: '@mipmap/ic_launcher',
                importance: Importance.max,
                priority: Priority.high,
                enableVibration: true,
                playSound: true,
              ),
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            payload: message.data.toString(),
          );
        }
      });

      // Handle notifikasi ketika aplikasi di background dan user tap notifikasi
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _logger.i('A new onMessageOpenedApp event was published!');
        _handleNotificationTap(message);
      });

      // Dapatkan dan kirim FCM token ke server
      String? token = await _firebaseMessaging.getToken();
      _logger.i('Got FCM Token: $token');

      if (token != null) {
        try {
          await _authService.updateFcmToken(token);
          _logger.i('FCM Token berhasil dikirim ke server');
        } catch (e) {
          _logger.e('Gagal mengirim FCM token ke server', error: e);
        }
      } else {
        _logger.w('FCM Token is null');
      }

      // Listen untuk perubahan token
      _firebaseMessaging.onTokenRefresh.listen((String token) async {
        _logger.i('FCM Token refreshed: $token');
        try {
          await _authService.updateFcmToken(token);
          _logger.i('New FCM Token berhasil dikirim ke server');
        } catch (e) {
          _logger.e('Gagal mengirim FCM token baru ke server', error: e);
        }
      });

      _logger.i('Firebase Messaging initialized successfully');
    } catch (e) {
      _logger.e('Error initializing Firebase Messaging', error: e);
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    _logger.i('Notification tapped with data: ${message.data}');
    // TODO: Implementasi navigasi berdasarkan data notifikasi
  }
}
