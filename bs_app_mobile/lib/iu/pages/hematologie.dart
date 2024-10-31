import 'package:bs_app_mobile/iu/pages/maladie_details.dart';
import 'package:bs_app_mobile/iu/pages/search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Hematologie extends StatefulWidget {
  const Hematologie({super.key});

  @override
  State<Hematologie> createState() => _HematologieState();
}

class _HematologieState extends State<Hematologie> {
  String searchQuery = '';
  final CollectionReference maladiesCollection = FirebaseFirestore.instance.collection('maladies');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Section de recherche
            SearchSection(
              onSearchChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 20),
            // Affichage des maladies en temps réel
            StreamBuilder<QuerySnapshot>(
              stream: maladiesCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text("Erreur de chargement des données.");
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                final maladies = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>; // Convertir le type
                  final nom = data.containsKey('nom') ? data['nom'].toString().toLowerCase() : '';
                  return searchQuery.isEmpty || nom.contains(searchQuery.toLowerCase());
                }).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: maladies.length,
                  itemBuilder: (context, index) {
                    final maladie = maladies[index];
                    final data = maladie.data() as Map<String, dynamic>; // Convertir le type ici aussi
                    final nom = data.containsKey('nom') ? data['nom'] : 'Nom inconnu';
                    final imageUrl = data.containsKey('photo') ? data['photo'] : ''; // Ajoutez ici le traitement pour l'image
                    final symptome = data.containsKey('symptome') ? data['symptome'] : 'Symptôme non disponible';
                    final traitement = data.containsKey('traitement') ? data['traitement'] : 'Traitement non disponible';
                    final lien = data.containsKey('lien') ? data['lien'] : 'Aucun lien disponible';
                    final definition = data.containsKey('definition') ? data['definition'] : 'Définition non disponible';
                    final diagnostic = data.containsKey('diagnostic') ? data['diagnostic'] : 'Diagnostic non disponible';

                    return _maladieContainer(
                      context,
                      nom,
                      imageUrl,
                      maladie.id,
                      symptome,
                      traitement,
                      lien,
                      definition,
                      diagnostic,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _maladieContainer(BuildContext context, String nom, String imageUrl, String maladieId, String symptome, String traitement, String lien, String definition, String diagnostic) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Image d'arrière-plan
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.error, color: Colors.red)); // Gérer les erreurs d'image
                },
              ),
            ),
          ),
          // Couche de couleur semi-transparente
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          // Texte et bouton centrés au milieu de l'image
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  nom,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Naviguer vers la page de détails avec l'ID de la maladie et les détails
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MaladieDetailsPage(
                          maladieId: maladieId,
                          nom: nom,
                          imageUrl: imageUrl,
                          symptome: symptome,
                          traitement: traitement,
                          lien: lien,
                          definition: definition,
                          diagnostic: diagnostic,
                        ), // Passer les données à la page de détails
                      ),
                    );
                  },
                  child: const Text('Consulter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
