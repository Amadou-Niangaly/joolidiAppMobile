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
                const Text("Urgence ?",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(width: 10),
                ToggleButtons(
                  children:  [
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
                const SizedBox(height: 16),
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

Future<void> _submitRequest() async {
  if (_selectedBloodGroup == null || _quantityController.text.isEmpty) {
    // Vérifier que le groupe sanguin et la quantité sont sélectionnés
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Veuillez sélectionner un groupe sanguin et entrer une quantité.')),
    );
    return;
  }

  String bloodGroup = _selectedBloodGroup!;
  int quantity = int.tryParse(_quantityController.text) ?? 0; // Utiliser `tryParse` pour éviter les exceptions
  bool isUrgent = _isUrgent;

  // Obtenir l'ID de l'utilisateur connecté
  User? user = FirebaseAuth.instance.currentUser;
  String? userId = user?.uid; // Vérifier si l'utilisateur est connecté

  if (userId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Utilisateur non connecté.')),
    );
    return;
  }

  try {
    // Envoyer la demande à Firestore avec l'ID de l'utilisateur
    await FirebaseFirestore.instance.collection('demande').add({
      'groupeSanguin': bloodGroup,
      'quantite': quantity,
      'urgence': isUrgent,
      'dateDemande': FieldValue.serverTimestamp(), // Ajoute la date de la demande
      'userId': userId, // Ajoutez l'ID de l'utilisateur ici
    });

    // Afficher un message de confirmation
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
}
