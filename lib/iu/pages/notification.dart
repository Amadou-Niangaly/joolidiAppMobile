import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationModel {
  final String body;
  final String demandeId;
  final String demandeurToken;
  final Timestamp timestamp;
  final String title;
  final String userId;

  NotificationModel({
    required this.body,
    required this.demandeId,
    required this.demandeurToken,
    required this.timestamp,
    required this.title,
    required this.userId,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> data) {
    return NotificationModel(
      body: data['body'] ?? '',
      demandeId: data['demandeId'] ?? '',
      demandeurToken: data['demandeurToken'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      title: data['title'] ?? '',
      userId: data['userId'] ?? '',
    );
  }
}

class NotificationPage extends StatelessWidget {
   final String? id; // Déclaration du paramètre id
  const NotificationPage({super.key,this.id});
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text("Notifications"),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!userSnapshot.hasData) {
            return Center(child: Text('Veuillez vous connecter.'));
          }

          final String currentUserId = userSnapshot.data!.uid;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('Aucune notification.'));
              }

              final notifications = snapshot.data!.docs
                  .map((doc) => NotificationModel.fromMap(doc.data() as Map<String, dynamic>))
                  .where((notification) => notification.userId == currentUserId)
                  .toList();

              if (notifications.isEmpty) {
                return Center(child: Text('Aucune notification pour l’utilisateur.'));
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: notifications.map<Widget>((notification) {
                    return _notificationsItem(
                      context,
                      title: notification.title,
                      body: notification.body,
                      timestamp: notification.timestamp.toDate().toLocal().toString(),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _notificationsItem(BuildContext context, {required String title, required String body, required String timestamp}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).hintColor.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, )),
            const SizedBox(height: 5),
            Text(body, style: const TextStyle(fontSize: 16,)),
            const SizedBox(height: 10),
            Text(timestamp, style: const TextStyle(fontSize: 14, color:Colors.redAccent )),
          ],
        ),
      ),
    );
  }
}
