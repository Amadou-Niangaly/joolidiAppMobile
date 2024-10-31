import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Pour l'authentification Firebase
import 'package:bs_app_mobile/services/auth_service.dart';
import 'home.dart'; // Modifier pour votre importation réelle

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  String? _selectedBloodGroup;

  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
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
            labelText: "Nom",
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
            labelText: "Prenom",
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
            labelText: "Email",
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
            labelText: "Mot de passe",
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
            labelText: "Telephone",
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
            labelText: "Groupe Sanguin",
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
        const SizedBox(height: 24),
        // Bouton S'inscrire
        ElevatedButton(
          onPressed: _signUp,
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

// Méthode pour gérer l'inscription avec validation de l'email et du mot de passe
Future<void> _signUp() async {
  String email = _emailController.text.trim();
  String password = _passwordController.text.trim();
  String nom = _nomController.text.trim();
  String prenom = _prenomController.text.trim();
  String numeroTelephone = _telephoneController.text.trim();
  String? groupeSanguin = _selectedBloodGroup;

  // Validation de l'email
  final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$");
  if (!emailRegex.hasMatch(email)) {
    _showErrorDialog("Adresse e-mail invalide.");
    return;
  }

  // Validation du mot de passe
  if (password.length < 6) {
    _showErrorDialog("Le mot de passe doit comporter au moins 6 caractères.");
    return;
  }

  if (email.isNotEmpty &&
      password.isNotEmpty &&
      nom.isNotEmpty &&
      prenom.isNotEmpty &&
      numeroTelephone.isNotEmpty &&
      groupeSanguin != null 
  ) {
    try {
      User? user = await _firebaseAuthService.signUp(
        email: email,
        password: password,
        nom: nom,
        prenom: prenom,
        numeroTelephone: numeroTelephone,
        groupeSanguin: groupeSanguin,
    
      );

      if (user != null) {
        _nomController.clear();
        _prenomController.clear();
        _emailController.clear();
        _passwordController.clear();
        _telephoneController.clear();
        setState(() {
          _selectedBloodGroup = null;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.message ?? "Une erreur s'est produite.");
    }
  } else {
    _showErrorDialog("Veuillez remplir tous les champs.");
  }
}

void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Erreur"),
      content: Text(message),
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
