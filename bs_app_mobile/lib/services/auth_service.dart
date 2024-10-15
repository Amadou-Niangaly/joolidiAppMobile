import 'package:bs_app_mobile/iu/pages/intro.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // Pour Firestore

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
      // Création de l'utilisateur avec Firebase Authentication
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = credential.user;
      if (user != null) {
        // Ajout des informations supplémentaires de l'utilisateur dans Firestore
        await _firestore.collection('utilisateurs').doc(user.uid).set({
          'nom': nom,
          'prenom': prenom,
          'email': email,
          'numeroTelephone': numeroTelephone,
          'groupeSanguin': groupeSanguin,
          'dateNaissance':dateNaissance,
          'role': 'user', // Ajout du rôle 'user'
          'uid': user.uid, // Stocke l'UID de l'utilisateur
          'dateInscription': FieldValue.serverTimestamp() // Date d'inscription
        });

        return user; // Retourne l'utilisateur après l'inscription réussie
      }
    } catch (e) {
      print("Une erreur est survenue lors de l'inscription : $e");
    }
    return null;
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print("Une erreur est survenue lors de la connexion : $e");
    }
    return null;
  }
 // Méthode pour déconnecter l'utilisateur
   Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut(); // Déconnexion de Firebase Auth
      print("Utilisateur déconnecté avec succès.");
      // Redirection vers la page IntroPage
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => IntroPage()), // Remplacez IntroPage par le nom de votre page d'introduction
        (Route<dynamic> route) => false, // Supprime toutes les autres pages de la pile
      );
    } catch (e) {
      print("Une erreur est survenue lors de la déconnexion : $e");
    }
  }

   Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      User? user = _auth.currentUser; // Récupérer l'utilisateur actuel
      if (user != null) {
        DocumentSnapshot doc = await _firestore.collection('utilisateurs').doc(user.uid).get();
        if (doc.exists) {
          return doc.data() as Map<String, dynamic>; // Retourner les données de l'utilisateur
        }
      }
    } catch (e) {
      print("Une erreur est survenue lors de la récupération des informations utilisateur : $e");
    }
    return null;
  }
}
