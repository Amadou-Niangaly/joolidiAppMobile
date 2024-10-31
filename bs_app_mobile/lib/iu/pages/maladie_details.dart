import 'package:flutter/material.dart';

class MaladieDetailsPage extends StatelessWidget {
  final String maladieId; // L'ID de la maladie
  final String nom; // Le nom de la maladie
  final String imageUrl; // L'URL de l'image de la maladie
  final String definition; // La définition de la maladie
  final String diagnostic; // Le diagnostic de la maladie
  final String symptome; // Les symptômes de la maladie
  final String traitement; // Le traitement de la maladie
  final String lien; // Lien YouTube pour plus d'informations

  const MaladieDetailsPage({
    Key? key,
    required this.maladieId,
    required this.nom,
    required this.imageUrl,
    required this.definition,
    required this.diagnostic,
    required this.symptome,
    required this.traitement,
    required this.lien,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nom), // Affiche le nom de la maladie dans la barre d'application
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Affichage de l'image de la maladie
              Center(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error, color: Colors.red); // Gérer les erreurs d'image
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Affichage du nom de la maladie
              Text(
                nom,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Affichage de la définition
              const Icon(Icons.info, color: Colors.blue),
              const SizedBox(width: 5),
              Text(
                'Définition: $definition',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),

              // Affichage du diagnostic
              const Icon(Icons.health_and_safety, color: Colors.green),
              const SizedBox(width: 5),
              Text(
                'Diagnostic: $diagnostic',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),

              // Affichage des symptômes
              const Icon(Icons.sick, color: Colors.orange),
              const SizedBox(width: 5),
              Text(
                'Symptômes: $symptome',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),

              // Affichage du traitement
              const Icon(Icons.local_hospital, color: Colors.red),
              const SizedBox(width: 5),
              Text(
                'Traitement: $traitement',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),

              // Lien YouTube
              const Icon(Icons.video_label, color: Colors.purple),
              const SizedBox(width: 5),
              TextButton(
                onPressed: () {
                  // Ouvrir le lien YouTube
                  // Vous pouvez utiliser le package url_launcher pour ouvrir l'URL
                },
                child: const Text(
                  'Voir la vidéo explicative',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
