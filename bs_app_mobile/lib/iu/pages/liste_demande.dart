import 'package:bs_app_mobile/iu/pages/demande_details.dart';
import 'package:bs_app_mobile/iu/pages/search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListeDemandePage extends StatelessWidget {
  const ListeDemandePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("Les demandes"),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Récupérer et afficher les demandes
              const SearchSection(),
              const SizedBox(height: 20,),
              StreamBuilder(
                stream: FirebaseFirestore.instance.collection('demande').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Afficher les demandes dynamiquement
                  return Column(
                    children: snapshot.data!.docs.map((demande) {
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('utilisateurs')
                            .doc(demande['userId'])
                            .get(),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          var utilisateur = userSnapshot.data!.data() as Map<String, dynamic>;
                          String prenomDemandeur = utilisateur['prenom'] ?? 'Prenom  inconnu';
                          String nomDemandeur = utilisateur['nom'] ?? 'Nom inconnu';  // Nom du demandeur
                          String groupeSanguin = demande['groupeSanguin'] ?? 'Non spécifié';
                          String statut = demande['urgence'] ? 'Urgent' : 'Attente';

                          return _itemsDemande(context, nomDemandeur, groupeSanguin, statut,prenomDemandeur);
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Affichage dynamique des demandes avec le nom du demandeur
  Widget _itemsDemande(BuildContext context, String nomDemandeur, String groupeSanguin, String statut,String prenomDemandeur) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Affichage du prenom et nom du demandeur
          Row(
            children: [
               Text(
            prenomDemandeur,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10,),
               Text(
            nomDemandeur,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
            ],
          ),
         
          const SizedBox(height: 10),

          // Ligne pour le statut et le groupe sanguin
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Groupe sanguin
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFD80032),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  groupeSanguin,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Statut, texte "Attente" et bouton "arrow forward"
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statut == 'Urgent' ? Colors.redAccent : Colors.amberAccent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statut,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),

                  // IconButton après le texte "Attente"
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DemandeDetaislPage()),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward_ios, color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
