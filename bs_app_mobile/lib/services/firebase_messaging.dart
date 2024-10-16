import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Fonction pour gérer les messages en arrière-plan
Future<void> handleBackroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');
}

// Classe pour gérer les notifications Firebase
class FirebaseMessage {
  final _firebaseMessaging = FirebaseMessaging.instance;
  
  // Initialisation du plugin de notifications locales
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    // Configuration des notifications locales
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon'); // Assure-toi d'avoir un icône dans ton dossier res

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Demander la permission pour les notifications
    await _firebaseMessaging.requestPermission();
    final fTOKEN = await _firebaseMessaging.getToken();
    print('Token: $fTOKEN');

    // Gérer les messages lorsque l'application est au premier plan
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Un message a été reçu alors que l\'application est au premier plan!');
      showNotification(message); // Affiche la notification locale
    });

    // Gérer les messages lorsque l'utilisateur clique sur la notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Une notification a été cliquée !');
      // Gérer l'action après avoir cliqué sur la notification
    });

    // Gérer les messages en arrière-plan
    FirebaseMessaging.onBackgroundMessage(handleBackroundMessage);
  }

  Future<void> showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel', // id du canal
      'High Importance Notifications', // nom du canal
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }
}