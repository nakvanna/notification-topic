import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final RxString welcome = 'Welcome Controller'.obs;
  late FirebaseMessaging _messaging;
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  /// Create a [AndroidNotificationChannel] for heads up notifications
  final AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  @override
  Future<void> onInit() async {
    _messaging = FirebaseMessaging.instance;
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    _messaging.getInitialMessage().then(
      (RemoteMessage? message) {
        if (message != null) {
          welcome.value = message.data['title'];
        }
      },
    );
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    _requestNotificationPermission();
    _onMessageListener();
    _onMessageOpenAppListener();
    subscribeToTopic(topic: 'Grade-12A');
    getFirebaseToken();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void _requestNotificationPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('Notification status: ${settings.authorizationStatus}');
  }

  void _onMessageListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('On message: ${message.notification!.android!.channelId}');
      RemoteNotification notification = message.notification!;
      _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            _channel.description,
            // TODO add a proper drawable resource to android, for now using
            icon: 'launch_background',
          ),
        ),
      );
    });
  }

  void _onMessageOpenAppListener() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('On message open app: $message');
    });
  }

  void subscribeToTopic({required String topic}) {
    _messaging
        .subscribeToTopic(topic)
        .whenComplete(() => print('Subscribe to $topic'));
  }

  void unSubscribeFromTopic({required String topic}) {
    _messaging
        .unsubscribeFromTopic(topic)
        .whenComplete(() => print('Unsubscribe from $topic'));
  }

  Future<String?> getFirebaseToken() async {
    await _messaging.getToken().then((token) => print('Token: $token'));
  }
}
