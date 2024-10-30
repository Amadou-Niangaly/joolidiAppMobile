import 'package:bs_app_mobile/iu/pages/profil.dart';
import 'package:flutter/material.dart';
import 'package:bs_app_mobile/services/auth_service.dart'; // Remplacez avec votre service d'authentification
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilPage extends StatefulWidget {
  const EditProfilPage({super.key});

  @override
  _EditProfilPageState createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  final FirebaseAuthService authService = FirebaseAuthService(); // Instance de votre service d'authentification
  final _formKey = GlobalKey<FormState>();
  TextEditingController nomController = TextEditingController();
  TextEditingController prenomController = TextEditingController();
  TextEditingController groupeSanguinController = TextEditingController();
  TextEditingController dateNaissanceController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userInfo = await authService.getUserInfo();
    setState(() {
      nomController.text = userInfo?['nom'];
      prenomController.text = userInfo?['prenom'];
      groupeSanguinController.text = userInfo?['groupeSanguin'];
      dateNaissanceController.text = userInfo?['dateNaissance'];
    });
  }

Future<void> _updateUserInfo() async {
  if (_formKey.currentState!.validate()) {
    try {
      await FirebaseFirestore.instance
          .collection('utilisateurs')
          .doc(authService.getCurrentUserId())
          .update({
        'nom': nomController.text,
        'prenom': prenomController.text,
        'groupeSanguin': groupeSanguinController.text,
        'dateNaissance': dateNaissanceController.text,
      });
      print("User information updated in Firestore.");

      if (passwordController.text.isNotEmpty) {
        // Prompt for current password
        final currentPassword = await _promptForPassword();

        try {
          await authService.reauthenticateUser(currentPassword);
          await authService.updatePassword(passwordController.text);
          print("Password updated successfully.");
        } catch (e) {
          print("Error updating password: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Votre session a expiré. Veuillez vous reconnecter.')),
          );
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informations mises à jour avec succès')),
      );
      Navigator.pop(context);
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  } else {
    print("Form validation failed.");
  }
}

Future<String> _promptForPassword() async {
  String password = '';
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Mot de passe actuel'),
      content: TextField(
        obscureText: true,
        onChanged: (value) => password = value,
        decoration: const InputDecoration(hintText: 'Entrez votre mot de passe actuel'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Confirmer'),
        ),
      ],
    ),
  );
  return password;
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
                const SizedBox(height: 20),
              TextFormField(
                controller: nomController,
                decoration:  InputDecoration(labelText: 'Nom',
                  border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
               fillColor: Theme.of(context).hintColor,
            filled: true,
                )
                
                ,
                validator: (value) => value == null || value.isEmpty ? 'Entrez un nom' : null,
              ),
                const SizedBox(height: 20),
              TextFormField(
                controller: prenomController,
                decoration:  InputDecoration(labelText: 'Prénom',
                border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
               fillColor: Theme.of(context).hintColor,
            filled: true,
                
                ),
                validator: (value) => value == null || value.isEmpty ? 'Entrez un prénom' : null,
              ),
                const SizedBox(height: 20),
              TextFormField(
                controller: groupeSanguinController,
                decoration: InputDecoration(labelText: 'Groupe Sanguin',
                
                border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
               fillColor: Theme.of(context).hintColor,
            filled: true,
                ),
                validator: (value) => value == null || value.isEmpty ? 'Entrez un groupe sanguin' : null,
              ),
                const SizedBox(height: 20),
              TextFormField(
                controller: dateNaissanceController,
                decoration: InputDecoration(labelText: 'Date de Naissance',
                 border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
               fillColor: Theme.of(context).hintColor,
            filled: true,
                ),
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode()); // Empêche l'apparition du clavier
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    dateNaissanceController.text = "${date.day}/${date.month}/${date.year}";
                  }
                },
                validator: (value) => value == null || value.isEmpty ? 'Entrez une date de naissance' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                decoration:  InputDecoration(labelText: 'Nouveau mot de passe',
                border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
               fillColor: Theme.of(context).hintColor,
            filled: true,
                ),
                obscureText: true,
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'Le mot de passe doit comporter au moins 6 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUserInfo,
                
                child: Text('Enregistrer les modifications',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                style: ElevatedButton.styleFrom(
                     shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
