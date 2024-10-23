
import 'package:bs_app_mobile/services/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Assurez-vous d'importer Firestore

class DemandPage extends StatefulWidget {
  const DemandPage({super.key});

  @override
  _DemandPageState createState() => _DemandPageState();
}

class _DemandPageState extends State<DemandPage> {
  String? _selectedBloodGroup; // Variable pour le groupe sanguin sélectionné
  final TextEditingController _quantityController = TextEditingController(); // Contrôleur pour la quantité
  bool _isUrgent = false; // Variable pour gérer l'urgence

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _containerFirst(),
              _containerTwo(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _containerFirst() {
    return Container(
      width: double.infinity,
      height: 400,
      child: Stack(
        children: [
          // Image de fond
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bloodimg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dégradé linéaire
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFD80032).withOpacity(0.6),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: const Center(
              child: Text(
                "Un besoin vital mérite une réponse immédiate. Demandez du sang, nous sommes prêts à vous soutenir.",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFFFFF),
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _containerTwo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      height: MediaQuery.of(context).size.height - 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            // Liste déroulante pour le groupe sanguin
            DropdownButtonFormField<String>(
              value: _selectedBloodGroup,
              items: <String>[
                'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                hintText: "Groupe Sanguin",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                fillColor: Theme.of(context).hintColor,
                filled: true,
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBloodGroup = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            // Quantité de sang
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(
                hintText: "Quantité (poche)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                fillColor: Theme.of(context).hintColor,
                filled: true,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            // ToggleButton pour choisir l'urgence
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Urgence ?",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(width: 10),
                ToggleButtons(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text("Oui"),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text("Non"),
                    ),
                  ],
                  isSelected: [_isUrgent, !_isUrgent],
                  onPressed: (int index) {
                    setState(() {
                      _isUrgent = index == 0;
                    });
                  },
                  color: Colors.black,
                  selectedColor: Colors.white,
                  fillColor: const Color(0xFFD80032),
                  splashColor: Colors.red,
                  borderRadius: BorderRadius.circular(15),
                  borderColor: const Color(0xFFD80032),
                  selectedBorderColor: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Envoyer
            ElevatedButton(
              onPressed: _submitRequest, // Méthode d'envoi de la demande
              child: const Text(
                "Envoyer",
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

  Future<void> _storeNotification(String title, String body, String userId, int quantity, String bloodGroup) async {
  try {
    await FirebaseFirestore.instance.collection('notifications').add({
      'title': title,
      'body': body,
      'userId': userId,
      'quantity': quantity,
      'bloodGroup': bloodGroup,
      'timestamp': FieldValue.serverTimestamp(),
    });
    print("Enregistrement de la notification avec les données : $title, $body, $userId, $quantity, $bloodGroup");
    print("Notification stockée avec succès !");
  } catch (e) {
    print("Erreur lors du stockage de la notification : $e");
  }
}

  Future<void> _submitRequest() async {
  // Vérifier si le groupe sanguin et la quantité sont sélectionnés
  if (_selectedBloodGroup == null || _quantityController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Veuillez sélectionner un groupe sanguin et entrer une quantité.')),
    );
    return;
  }

  String bloodGroup = _selectedBloodGroup!;
  int quantity = int.tryParse(_quantityController.text) ?? 0;
  bool isUrgent = _isUrgent;

  User? user = FirebaseAuth.instance.currentUser;
  String? userId = user?.uid;

  // Vérifier si l'utilisateur est connecté
  if (userId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Utilisateur non connecté.')),
    );
    return;
  }

  // Indiquer le chargement
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Envoi de la demande...')),
  );

  try {
    // Récupérer les informations de l'utilisateur (prénom et nom)
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('utilisateurs').doc(userId).get();
    var userData = userDoc.data() as Map<String, dynamic>?;

    // Vérifier que les données de l'utilisateur existent
    if (userData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la récupération des informations de l\'utilisateur.')),
      );
      return;
    }

    String userName = "${userData['prenom']} ${userData['nom']}"; // Concaténer le prénom et le nom

    // Envoyer la demande à Firestore
    DocumentReference requestDoc = await FirebaseFirestore.instance.collection('demande').add({
      'groupeSanguin': bloodGroup,
      'quantite': quantity,
      'urgence': isUrgent,
      'dateDemande': FieldValue.serverTimestamp(),
      'userId': userId,
    });

    // Récupérer tous les tokens
    List<String> tokens = await getAllTokens();
    print("Tokens: $tokens");

    // Préparer le message pour la notification
    String message = 'Une nouvelle demande de sang de $quantity (poches) $bloodGroup a été faite par $userName.';

    // Envoyer la notification à tous les utilisateurs
    await _sendNotificationToTokens(tokens, 'Demande de Sang', message);

    // Stocker la notification dans Firestore
    await _storeNotification('Demande de Sang', message, userId, quantity, bloodGroup);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Demande envoyée avec succès!')),
    );

    // Réinitialiser les champs
    setState(() {
      _selectedBloodGroup = null;
      _quantityController.clear();
      _isUrgent = false;
    });
  } catch (e) {
    print("Une erreur est survenue lors de l'envoi de la demande : $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur lors de l\'envoi de la demande : $e')),
    );
  }
}



  // Méthode pour récupérer tous les tokens FCM
Future<List<String>> getAllTokens() async {
  List<String> tokens = [];
  try {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('utilisateurs').get();
    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>?; // Assurez-vous que data est de type Map
      if (data != null && data['fcm_token'] != null && data['fcm_token'].isNotEmpty) {
        tokens.add(data['fcm_token']);
      }
    }
  } catch (e) {
    print("Erreur lors de la récupération des tokens : $e");
  }
  return tokens;
}

Future<void> _sendNotificationToTokens(List<String> tokens, String title, String body) async {
  for (String token in tokens) {
    try {
      await FirebaseMessage.sendNotification(
        title: title,
        body: body,
        token: token,
        contextType: 'demande', // Type de contexte personnalisé
        contextData: 'some_id', // Les données contextuelles à envoyer (par exemple, l'ID de la demande)
      );
      print('Notification envoyée à $token');
    } catch (e) {
      print('Erreur lors de l\'envoi de la notification à $token: $e');
    }
  }
}
}
