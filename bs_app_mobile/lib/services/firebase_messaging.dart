import 'dart:convert'; // Import pour jsonEncode
import 'package:bs_app_mobile/iu/pages/notification.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import pour les notifications locales

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
    _showNotification(message.notification!.title, message.notification!.body, null); 
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
  final Map<String, dynamic> serviceAccountJson = {
    "type": "service_account",
    "project_id": "banque-sang-8dc2b",
    "private_key_id": "f62c81128fa553227fc72a7ec24ffc1c82bb4b65",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDcZZjkOqFA2+Ip\nXWIX8lQj7ZttxCV6ZEPpATYo7yhR+NH2PCtDOsboKVZalEM63je0Yp4mp7e7ig6O\nJNmF47ZbsrLJcwHN492f8e+wzPQcs7PatVIrJguUBcy6nAuFM+thyUX1lLuEva8N\nWdghWFZFzHZgffez9D04gezeQeL+J2EMNxAcqLRin9cZk6hlum3WRCKDX16wFsbI\nvTPXHqtH64USQhdEXoXbxTT8QYXd+lo/7lKW1CJUzS+aWqcgnhAhFtJ9FeDlZVKp\nMP8dsPfDH7i6vr1eT/PSQ1tAYOEJmZ1XDvkbDzaFojnK/vGd+h9C2Gqs3Tg0N8SL\nst6gojLTAgMBAAECggEAavtWD9L120ngqjuOFhmnBhmcTNfdaV+qJzxTUeNlKwUg\nxenHBkdNrfwC0s0NJVIgsAr+wby/zuTg09bHT9qM9k3zwx10TsDBH5aMxsF17Ui9\nkPha/l7lV+DI0/xTC0F8jGbq8p5Tt8drZYurAeSjXBY3j/cVeeCgpwFKPUi2Kq+D\nsWTkdftQORcfJQoaDwn2Xu5iwlISLdms5zwdKdk4g31Luhg7g0ay7X8+qFOSYu37\nele4WZuE1pWRxNV8azBDj/Syb3GXEW0N/fCXLwjNJS2LodJbs4yO7jBkjekizQTN\npGD7AONeR4vnTSKFLohr2jyKvn3DgwqCwXnM5v4F4QKBgQD9eT6+6OFbZzwLUzr/\n5wUHaNXcijUVioU/3kS/NoxmT1DE9g+jiEc1GWZ/YzO89Xd8BbECPq5iB8GFGaQq\nP2VOCGZOdRQ02AN1cUgpCMIc4bhzjkTRaTMO6KDgxACbvPzO/qau304KkwWaeacl\nAO8R+pK7gAUkmHMWuucwsFwfVQKBgQDel/RgDO2ih+aL2I4p6w6VtMF39RILFjcm\nZ9bENxGGshBHeGMTr7Zw0Wq/MZSBr5DRm1QMxMlpwnv4kwCTuoZgTd0kjqdDzLaf\nbGOg8MjnEHE1ytzkFoXoRTfYlpi5hE2I9+Ihd4r4ztUG5NnbWPuEfUjUtygVJaZw\nXeBC50T5hwKBgBKWf5l0boJLccXK1rrJcD742yYPJJFt1RO38waqs2UVT/EBsmfl\nqIMmV7PjzHmA7sAzkqV9f0BFHVXraXSHraApUYdTYqX1aVuFcStBLyr7CpG+zyEk\nO9BOEu4osXq6QzfSyNpuGcUAvxpy7WTzSpTg8T26x6XFYDs8fZO+eyL5AoGBALjH\nBVqSgNWx4MToIKNVeAb4RL4Sl0bSyzc7bcH2QLtCp1bc7coSy+z9OpK6UqARILOP\nMIdk+BmuE4E2bn0zkobxPAkzzk/u6Q6QSGf6WZvOP1w7KYDB3akBhKlr4h3mYQK5\nW2MSvC9satRNNzfptui1o7bI0CI13eNbWmXPW6eTAoGAVTS9b7VSJM5wHxZ1d7mW\n6rwgFvr1wbneZ0SuxiExmNR1x8AuQ/5M5xb+b375ZOdp4moNMn6VwHHJkEeoU9fs\ncjyc6cMGCTaYt6ucSV9hVMHxrWdgrHdHTQXtoVaG96YDNPhFoPzDzFKCWsu+5x+N\nJhGCAcw85eTD2RwYyXGtjZU=\n-----END PRIVATE KEY-----\n",
    "client_email": "banque-de-sang-projet@banque-sang-8dc2b.iam.gserviceaccount.com",
    "client_id": "115939432747689808933",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/banque-de-sang-projet%40banque-sang-8dc2b.iam.gserviceaccount.com"
  };

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
  static Future<void> _showNotification(String? title, String? body, String? payload) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'blood_donation_channel', // Remplacez par un ID de canal unique
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
      payload: payload, // Passer le payload
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
