
import 'package:bs_app_mobile/iu/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Pour l'authentification Firebase
import 'package:bs_app_mobile/services/auth_service.dart';
import 'package:intl/intl.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Déclaration des TextEditingController pour capturer les entrées utilisateur
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _dateNaissanceController = TextEditingController(); // Ajout du contrôleur pour la date de naissance
  String? _selectedBloodGroup; // Variable pour stocker le groupe sanguin sélectionné

  // Service Firebase
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _header(context),
                const SizedBox(height: 24),
                _inputFields(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _header(context) {
    return const Column(
      children: [
        Text(
          "Inscription",
          style: TextStyle(
              fontSize: 40, fontWeight: FontWeight.bold, fontFamily: 'Billabong'),
        )
      ],
    );
  }

  _inputFields(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Nom
        TextField(
          controller: _nomController,
          decoration: InputDecoration(
            hintText: "Nom",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Theme.of(context).hintColor,
            filled: true,
          ),
        ),
        const SizedBox(height: 20),
        // Prénom
        TextField(
          controller: _prenomController,
          decoration: InputDecoration(
            hintText: "Prenom",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Theme.of(context).hintColor,
            filled: true,
          ),
        ),
        const SizedBox(height: 20),
        // Email
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: "Email",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Theme.of(context).hintColor,
            filled: true,
          ),
        ),
        const SizedBox(height: 20),
        // Password
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            hintText: "Password",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Theme.of(context).hintColor,
            filled: true,
          ),
          obscureText: true,
        ),
        const SizedBox(height: 20),
        // Numéro de téléphone
        TextField(
          controller: _telephoneController,
          decoration: InputDecoration(
            hintText: "Numéro de téléphone",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Theme.of(context).hintColor,
            filled: true,
          ),
        ),
        const SizedBox(height: 20),
        // Date de naissance (avec showDatePicker)
        TextField(
          controller: _dateNaissanceController,
          decoration: InputDecoration(
            hintText: "Date de naissance",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Theme.of(context).hintColor,
            filled: true,
          ),
          readOnly: true, // Empêche la saisie manuelle
          onTap: () async {
            // Affiche le sélecteur de date
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900), // Date minimale
              lastDate: DateTime.now(), // Date maximale
            );

            if (pickedDate != null) {
              // Formate la date et la met dans le TextField
              String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
              setState(() {
                _dateNaissanceController.text = formattedDate;
              });
            }
          },
        ),
        const SizedBox(height: 20),
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
              _selectedBloodGroup = newValue; // Mise à jour du groupe sanguin sélectionné
            });
          },
        ),
        const SizedBox(height: 24),
        // Bouton S'inscrire
        ElevatedButton(
          onPressed: _signUp, // Méthode d'inscription appelée lors du clic
          child: const Text(
            "S'inscrire",
            style: TextStyle(fontSize: 20, color: Color(0xFFFFFFFF)),
          ),
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        )
      ],
    );
  }

// Méthode pour gérer l'inscription
Future<void> _signUp() async {
  String email = _emailController.text.trim();
  String password = _passwordController.text.trim();
  String nom = _nomController.text.trim();
  String prenom = _prenomController.text.trim();
  String numeroTelephone = _telephoneController.text.trim();
  String? groupeSanguin = _selectedBloodGroup;
  String dateNaissance = _dateNaissanceController.text.trim(); // Si tu utilises un TextEditingController pour la date

  if (email.isNotEmpty &&
      password.isNotEmpty &&
      nom.isNotEmpty &&
      prenom.isNotEmpty &&
      numeroTelephone.isNotEmpty &&
      groupeSanguin != null &&
      dateNaissance.isNotEmpty) {
    try {
      // Appel au service Firebase pour l'inscription
      User? user = await _firebaseAuthService.signUp(
        email: email,
        password: password,
        nom: nom,
        prenom: prenom,
        numeroTelephone: numeroTelephone,
        groupeSanguin: groupeSanguin,
        dateNaissance: dateNaissance,
      );

      if (user != null) {
        // Réinitialiser les champs après une soumission réussie
        _nomController.clear();
        _prenomController.clear();
        _emailController.clear();
        _passwordController.clear();
        _telephoneController.clear();
        _dateNaissanceController.clear(); // Réinitialiser la date de naissance
        setState(() {
          _selectedBloodGroup = null; // Réinitialiser le groupe sanguin
        });

        // Redirection ou autres actions après une inscription réussie
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Affichage des erreurs
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Erreur d'inscription"),
          content: Text(e.message ?? "Une erreur s'est produite."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  } else {
    // Gestion des champs non remplis
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Champs manquants"),
        content: const Text("Veuillez remplir tous les champs."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}


}
