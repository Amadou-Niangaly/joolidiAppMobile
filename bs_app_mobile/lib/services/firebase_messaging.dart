import 'dart:convert'; // Import pour jsonEncode
import 'package:bs_app_mobile/iu/pages/notification.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import pour les notifications 
import 'package:flutter/services.dart' show rootBundle;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Gère les notifications reçues en arrière-plan
  print("Handling a background message: ${message.messageId}");
}

class FirebaseMessage {
   static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeFirebase(BuildContext context) async {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          await _onSelectNotification(context, response.payload! as Map<String, dynamic>);
        }
      },
    );

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    String? token = await messaging.getToken();
    print("Token FCM : $token");

   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  print("Message reçu : ${message.notification?.title} ${message.notification?.body}");

  if (message.notification != null) {
    // Passer null ou un payload approprié
  _showNotification(message.notification!.title, message.notification!.body, null, message.data['id'] ?? 'defaultId');

  }
});

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['type'] != null) {
        _onSelectNotification(context, message.data['type']);
      }
    });
  }

  static Future<void> _onSelectNotification(BuildContext context, Map<String, dynamic> data) async {
  // Vérifiez que les données contiennent un 'id'
  String? id = data['id'];

  // Naviguer vers la NotificationPage et passer l'ID si nécessaire
  Navigator.of(context).push(
    MaterialPageRoute(builder: (context) => NotificationPage(id: id)), // Assurez-vous que NotificationPage accepte un id
  );
}
 static Future<String> getAccessToken() async {
  final serviceAccountJson = await rootBundle.loadString('assets/images/serviceAccount.json');

  List<String> scopes = [
    'https://www.googleapis.com/auth/firebase.messaging',
    'https://www.googleapis.com/auth/userinfo.email'
  ];

  final client = await auth.clientViaServiceAccount(
    auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
    scopes,
  );

  final accessToken = client.credentials.accessToken.data;

  client.close(); // Fermer le client

  return accessToken;
}

  // Fonction pour afficher la notification
 static Future<void> _showNotification(String? title, String? body, String? payload, String notificationId) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'blood_donation_channel', // ID unique du canal
    'Notifications de Don de Sang', // Nom du canal
    channelDescription: 'Recevez des mises à jour concernant les demandes de dons de sang.', // Description du canal
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0, // ID de la notification
    title,
    body,
    platformChannelSpecifics,
    payload: jsonEncode({'id': notificationId}), // Inclure l'ID de notification ici
  );
}


  // Fonction pour envoyer la notification
  static Future<void> sendNotification({
  required String title,
  required String body,
  required String token,
  required String contextType,
  required String contextData,
}) async {
  final String serverKey = await getAccessToken();
  final String firebaseMessagingEndpoint = 'https://fcm.googleapis.com/v1/projects/banque-sang-8dc2b/messages:send';

  final Map<String, dynamic> notificationMessage = {
    'message': {
      'token': token,
      'notification': {
        'title': title,
        'body': body,
      },
      'data': {
        'type': contextType,
        'id': contextData,
      },
    }
  };

  // Convertir en chaîne JSON
  final String bodyJson = jsonEncode(notificationMessage);

  // Envoyer la requête POST avec la chaîne JSON dans le corps
  final response = await http.post(
    Uri.parse(firebaseMessagingEndpoint),
    headers: {
      'Authorization': 'Bearer $serverKey',
      'Content-Type': 'application/json',
    },
    body: bodyJson, // Le corps est maintenant au format JSON
  );

  if (response.statusCode == 200) {
    print('Notification envoyée avec succès.');
  } else {
    print('Erreur lors de l\'envoi de la notification : ${response.body}');
  }
}
}
