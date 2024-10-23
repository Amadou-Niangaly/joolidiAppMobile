
import 'package:bs_app_mobile/services/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importer Firebase Auth

class DonPage extends StatefulWidget {
  const DonPage({super.key});

  @override
  _DonPageState createState() => _DonPageState();
}

class _DonPageState extends State<DonPage> {
  String? _selectedBloodGroup;
  String? _selectedCentreId;
  List<Map<String, String>> _centres = [];
  final TextEditingController _quantiteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCentres();
  }

  @override
  void dispose() {
    _quantiteController.dispose();
    super.dispose();
  }

  Future<void> _loadCentres() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('centreDon').get();
      List<Map<String, String>> centresList = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'nom': doc['nom'] as String,
        };
      }).toList();
      setState(() {
        _centres = centresList;
      });
    } catch (e) {
      print('Erreur lors du chargement des centres: $e');
    }
  }

 Future<void> _envoyerDon() async {
  if (_selectedBloodGroup != null && _selectedCentreId != null && _quantiteController.text.isNotEmpty) {
    try {
      // Obtenir l'utilisateur connecté
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("Aucun utilisateur connecté.");
      }
      String userId = currentUser.uid;

      // Enregistrement du don dans Firestore avec l'UID de l'utilisateur
      DocumentReference docRef = await FirebaseFirestore.instance.collection('don').add({
        'groupeSanguin': _selectedBloodGroup,
        'centre': _selectedCentreId,
        'quantite': _quantiteController.text,
        'date': DateTime.now(),
        'userId': userId, // Enregistrement de l'UID de l'utilisateur
      });

      // Récupérer tous les tokens
      List<String> tokens = await getAllTokens();
      print("Tokens: $tokens");

      // Préparer le message pour la notification
      String message = 'Un don de sang est demandé .';

      // Envoyer la notification à tous les utilisateurs
      await _sendNotificationToTokens(tokens, 'Demande de Sang', message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Don envoyé avec succès !')),
      );

      // Réinitialiser les champs après l'envoi
      setState(() {
        _selectedBloodGroup = null;
        _selectedCentreId = null;
        _quantiteController.clear();
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'envoi du don : $e')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Veuillez remplir tous les champs.')),
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
      await  FirebaseMessage.sendNotification(
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
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bloodimg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
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
                "Un don de sang, une vie sauvée. Participez à ce miracle !",
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
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
          DropdownButtonFormField<String>(
            value: _selectedCentreId,
            items: _centres.map((Map<String, String> centre) {
              return DropdownMenuItem<String>(
                value: centre['id'],
                child: Text(centre['nom']!),
              );
            }).toList(),
            decoration: InputDecoration(
              hintText: "Centres",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              fillColor: Theme.of(context).hintColor,
              filled: true,
            ),
            onChanged: (String? newValue) {
              setState(() {
                _selectedCentreId = newValue;
              });
            },
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _quantiteController,
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
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _envoyerDon,
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
    );
  }
}
