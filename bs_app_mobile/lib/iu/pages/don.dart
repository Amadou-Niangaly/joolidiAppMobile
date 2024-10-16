import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

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
        // Enregistrement du don dans Firestore
        DocumentReference docRef = await FirebaseFirestore.instance.collection('don').add({
          'groupeSanguin': _selectedBloodGroup,
          'centre': _selectedCentreId,
          'quantite': _quantiteController.text,
          'date': DateTime.now(),
        });

        // Récupération du token FCM pour envoyer la notification
        String token = await FirebaseMessaging.instance.getToken() ?? '';
        print("FCM Token: $token");

        // Préparer la notification
        await _sendNotification(token, 'Don de sang', 'Un nouveau don de sang a été faite.');

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

 Future<void> _sendNotification(String token, String title, String body) async {
  final response = await http.post(
    Uri.parse('http://10.0.2.2:3000/send-notification'), // Utilise 10.0.2.2 si tu utilises un émulateur Android
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'token': token,
      'title': title,
      'body': body,
    }),
  );

  print("Réponse du serveur: ${response.statusCode}");
  print("Body: ${response.body}");

  if (response.statusCode == 200) {
    print("Notification envoyée avec succès");
  } else {
    print("Erreur lors de l'envoi de la notification: ${response.body}");
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
