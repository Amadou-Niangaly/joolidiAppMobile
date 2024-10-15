import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonPage extends StatefulWidget {
  const DonPage({super.key});

  @override
  _DonPageState createState() => _DonPageState();
}

class _DonPageState extends State<DonPage> {
  String? _selectedBloodGroup;
  String? _selectedCentreId; // Utilise l'ID du centre
  List<Map<String, String>> _centres = []; // Liste de maps pour les centres
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
          'id': doc.id, // Récupère l'ID du document
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
    if (_selectedBloodGroup != null && _selectedCentreId != null) {
      try {
        await FirebaseFirestore.instance.collection('don').add({
          'groupeSanguin': _selectedBloodGroup,
          'centreId': _selectedCentreId, // Enregistre l'ID du centre
          'quantite': _quantiteController.text,
          'date': DateTime.now(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Don envoyé avec succès !')),
        );
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
                value: centre['id'], // Utiliser l'ID ici
                child: Text(centre['nom']!), // Affiche le nom
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
                _selectedCentreId = newValue; // Stocke l'ID du centre sélectionné
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
