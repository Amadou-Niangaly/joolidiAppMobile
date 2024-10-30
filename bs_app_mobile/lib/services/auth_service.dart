import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:bs_app_mobile/iu/pages/intro.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Inscription d'un utilisateur
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
        // Sauvegarder les données utilisateur dans Firestore
        await _firestore.collection('utilisateurs').doc(user.uid).set({
          'nom': nom,
          'prenom': prenom,
          'email': email,
          'numeroTelephone': numeroTelephone,
          'groupeSanguin': groupeSanguin,
          'dateNaissance': dateNaissance,
          'role': 'user',
          'uid': user.uid,
          'dateInscription': FieldValue.serverTimestamp(),
        });

        // Enregistrer le token FCM après inscription
        await _saveFCMToken(user.uid);

        return user;
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription : $e');
    }
    return null;
  }

  // Méthode pour récupérer et enregistrer le token FCM dans Firestore
  Future<void> _saveFCMToken(String uid) async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        print("Token FCM récupéré : $token");
        await _firestore.collection('utilisateurs').doc(uid).set({
          'fcm_token': token,
        }, SetOptions(merge: true));  // Fusionner pour éviter d'écraser les autres données
        print('Token FCM enregistré pour l\'utilisateur: $uid');
      }

      // Écouter les mises à jour du token FCM
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        await _firestore.collection('utilisateurs').doc(uid).set({
          'fcm_token': newToken,
        }, SetOptions(merge: true));
        print("Token FCM mis à jour via onTokenRefresh pour l'utilisateur: $uid");
      });
    } catch (e) {
      print('Erreur lors de l\'enregistrement du token FCM : $e');
    }
  }
    // Returns the ID of the currently logged-in user, or null if no user is logged in
  String? getCurrentUserId() {
    User? user = _auth.currentUser;
    return user?.uid;
  }

  // Allows the user to update their password
  Future<void> updatePassword(String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        await user.reload(); // Refresh the user's data
        print("Password updated successfully.");
      } else {
        print("No user is currently logged in.");
      }
    } catch (e) {
      print("Error updating password: $e");
      throw Exception('Failed to update password');
    }
  }
Future<void> reauthenticateUser(String password) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null && user.email != null) {
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );

    await user.reauthenticateWithCredential(credential);
  } else {
    throw FirebaseAuthException(
      code: 'no-user',
      message: 'No user is currently signed in.',
    );
  }
}


  // Connexion d'un utilisateur avec son email et mot de passe
Future<User?> signInWithEmailAndPassword(String email, String password) async {
  print("Tentative de connexion avec l'email : $email"); // Ajoutez ce print

  try {
    UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = credential.user;
    if (user != null) {
      print("Utilisateur connecté : ${user.uid}"); // Ajoutez ce print

      // Récupérer le token FCM actuel de l'appareil
      String? newToken = await FirebaseMessaging.instance.getToken();
      print("Nouveau token FCM : $newToken"); // Ajoutez ce print

      // Récupérer l'ancien token FCM enregistré dans Firestore
      DocumentSnapshot doc = await _firestore.collection('utilisateurs').doc(user.uid).get();
      String? oldToken = doc.get('fcm_token');

      if (newToken != null && newToken != oldToken) {
        await _firestore.collection('utilisateurs').doc(user.uid).set({
          'fcm_token': newToken,
        }, SetOptions(merge: true));
        print("Token FCM mis à jour pour l'utilisateur: ${user.uid}.");
      } else {
        print("Le token FCM n'a pas changé ou est nul.");
      }
    } else {
      print("Aucun utilisateur connecté.");
    }

    return user;
  } catch (e) {
    print("Une erreur est survenue lors de la connexion : $e");
    return null;
  }
}



  // Déconnexion de l'utilisateur
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

  // Récupérer les informations de l'utilisateur actuellement connecté
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
