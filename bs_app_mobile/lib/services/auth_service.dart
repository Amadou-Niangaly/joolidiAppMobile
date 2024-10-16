import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:bs_app_mobile/iu/pages/intro.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signUp({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required String numeroTelephone,
    required String groupeSanguin,
    required String dateNaissance,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = credential.user;
      if (user != null) {
        await _firestore.collection('utilisateurs').doc(user.uid).set({
          'nom': nom,
          'prenom': prenom,
          'email': email,
          'numeroTelephone': numeroTelephone,
          'groupeSanguin': groupeSanguin,
          'dateNaissance': dateNaissance,
          'role': 'user',
          'uid': user.uid,
          'dateInscription': FieldValue.serverTimestamp()
        });

        // Enregistrer le token FCM
        await _saveFCMToken(user.uid); // Enregistrer le token FCM

        return user;
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription : $e');
    }
    return null;
  }

  Future<void> _saveFCMToken(String userId) async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await _firestore.collection('utilisateurs').doc(userId).set({
        'fcm_token': token,
      }, SetOptions(merge: true));
      print('Token FCM enregistré pour l\'utilisateur: $userId');
    }
  }

  Future<void> updateToken(String userId, String token) async {
  try {
    await _firestore.collection('utilisateurs').doc(userId).update({
      'fcmToken': token, // Ajoutez ce champ à votre document utilisateur
    });
    print("Token FCM mis à jour avec succès.");
  } catch (e) {
    print("Erreur lors de la mise à jour du token FCM : $e");
  }
}


Future<User?> signInWithEmailAndPassword(String email, String password) async {
  try {
    UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = credential.user;
    if (user != null) {
      // Obtenez le token FCM
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        // Mettez à jour le token dans Firestore
        await updateToken(user.uid, token);
      }
    }

    return user;
  } catch (e) {
    print("Une erreur est survenue lors de la connexion : $e");
  }
  return null;
}

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      print("Utilisateur déconnecté avec succès.");
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => IntroPage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print("Une erreur est survenue lors de la déconnexion : $e");
    }
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await _firestore.collection('utilisateurs').doc(user.uid).get();
        if (doc.exists) {
          return doc.data() as Map<String, dynamic>;
        }
      }
    } catch (e) {
      print("Une erreur est survenue lors de la récupération des informations utilisateur : $e");
    }
    return null;
  }
}
