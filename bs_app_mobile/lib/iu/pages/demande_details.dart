 // Importez votre AuthService
import 'package:bs_app_mobile/services/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Assurez-vous d'importer FirebaseAuth

class DemandeDetailsPage extends StatelessWidget {
  final String? nom;
  final String? prenom;
  final String? telephone;
  final String? groupeSanguin;
  final int? quantite;
  final bool? urgence;
  final String demandeId; // ID de la demande

  const DemandeDetailsPage({
    super.key,
    this.nom,
    this.prenom,
    this.telephone,
    this.groupeSanguin,
    this.quantite,
    this.urgence,
    required this.demandeId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails de la demande"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            _detailsItems(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirmation'),
                      content: const Text(
                        'En acceptant cette demande, vos informations seront envoyées au demandeur pour qu\'il prenne contact avec vous.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Annuler',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context).pop();

                            // Récupérer l'UID de l'utilisateur actuel
                            String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
                            if (currentUserId != null) {
                              // Récupérer les détails de l'utilisateur actuel
                              DocumentSnapshot currentUserSnapshot = await FirebaseFirestore.instance
                                  .collection('utilisateurs')
                                  .doc(currentUserId)
                                  .get();
                              
                              var currentUserData = currentUserSnapshot.data() as Map<String, dynamic>?;

                              // Vérifiez si les données de l'utilisateur actuel sont disponibles
                              if (currentUserData != null) {
                                String? currentNom = currentUserData['nom'];
                                String? currentPrenom = currentUserData['prenom'];
                                String? currentTelephone = currentUserData['numeroTelephone'];
                                String? currentGroupeSanguin = currentUserData['groupeSanguin'];

                                // Récupérer le token FCM du demandeur et son userId
                                Map<String, String?> demandeurData = await getDemandeurTokenAndId(demandeId);
                                String? demandeurToken = demandeurData['fcm_token'];
                                String? demandeurId = demandeurData['userId'];

                                if (demandeurToken != null && demandeurId != null) {
                                  // Envoyer la notification au demandeur
                                  await _sendNotificationToDemandeur(
                                    demandeurToken,
                                    "Demande acceptée",
                                    "$currentPrenom $currentNom a accepté votre demande. Contactez-le au $currentTelephone. Groupe sanguin: $currentGroupeSanguin",
                                  );

                                  // Stocker la notification dans Firestore
                                  await _storeNotification(
                                    demandeId,
                                    "Demande acceptée",
                                    "$currentPrenom $currentNom a accepté votre demande. Contactez-le au $currentTelephone. Groupe sanguin: $currentGroupeSanguin",
                                    demandeurToken,
                                    demandeurId, // Passer le userId ici
                                  );

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Demande acceptée et notification envoyée')),
                                    );
                                  }
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Erreur : impossible de récupérer le token ou l\'ID du demandeur')),
                                    );
                                  }
                                }
                              }
                            }
                          },
                          child: const Text('Accepter', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text(
                "Accepter",
                style: TextStyle(fontSize: 20, color: Color(0xFFFFFFFF)),
              ),
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailsItems() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            _detailRow("Nom", nom ?? 'Non spécifié'),
            const SizedBox(height: 15),
            _detailRow("Prénom", prenom ?? 'Non spécifié'),
            const SizedBox(height: 15),
            _detailRow("Téléphone", telephone ?? 'Non spécifié'),
            const SizedBox(height: 15),
            _detailRow("Groupe sanguin", groupeSanguin ?? 'Non spécifié'),
            const SizedBox(height: 15),
            _detailRow("Quantité", quantite != null ? "$quantite poche(s)" : 'Non spécifié'),
            const SizedBox(height: 15),
            _detailRow("Urgence", urgence != null ? (urgence! ? "Oui" : "Non") : 'Non spécifié'),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Future<Map<String, String?>> getDemandeurTokenAndId(String demandeId) async {
    try {
      DocumentSnapshot demandeSnapshot = await FirebaseFirestore.instance
          .collection('demande')
          .doc(demandeId)
          .get();

      var data = demandeSnapshot.data() as Map<String, dynamic>?;

      if (data != null && data['userId'] != null) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('utilisateurs')
            .doc(data['userId'])
            .get();

        var userData = userSnapshot.data() as Map<String, dynamic>?;

        if (userData != null && userData['fcm_token'] != null) {
          return {
            'fcm_token': userData['fcm_token'] as String?,
            'userId': data['userId'] as String?,
          };
        }
      }
    } catch (e) {
      print("Erreur lors de la récupération du token et de l'ID du demandeur : $e");
    }
    return {'fcm_token': null, 'userId': null};
  }

  Future<void> _sendNotificationToDemandeur(String demandeurToken, String title, String body) async {
    try {
      await FirebaseMessage.sendNotification(
        title: title,
        body: body,
        token: demandeurToken,
        contextType: 'demande',
        contextData: demandeId,
      );
      print('Notification envoyée au demandeur avec succès');
    } catch (e) {
      print('Erreur lors de l\'envoi de la notification : $e');
    }
  }

  Future<void> _storeNotification(String demandeId, String title, String body, String demandeurToken, String demandeurId) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'demandeId': demandeId,
        'title': title,
        'body': body,
        'demandeurToken': demandeurToken,
        'userId': demandeurId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Notification stockée avec succès dans Firestore');
    } catch (e) {
      print('Erreur lors du stockage de la notification : $e');
    }
  }
}
