import 'package:bs_app_mobile/iu/pages/demande_details.dart';
import 'package:bs_app_mobile/iu/pages/search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListeDemandePage extends StatefulWidget {
  const ListeDemandePage({super.key});

  @override
  _ListeDemandePageState createState() => _ListeDemandePageState();
}

class _ListeDemandePageState extends State<ListeDemandePage> {
  String searchQuery = '';

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
              SearchSection(
                onSearchChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('demande').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Filtrer les demandes selon la recherche
                  var filteredDocs = snapshot.data!.docs.where((demande) {
                    // Ici, vous pouvez filtrer en fonction du nom, du groupe sanguin, etc.
                    var utilisateurId = demande['userId'];
                    return demande['groupeSanguin'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
                           demande['quantite'].toString().contains(searchQuery) ||
                           utilisateurId.toString().contains(searchQuery);
                  }).toList();

                  // Trier les demandes par dateDemande (plus récent en haut)
                  filteredDocs.sort((a, b) {
                    var dateA = a['dateDemande'];
                    var dateB = b['dateDemande'];

                    // Vérifiez le type de date
                    if (dateA is Timestamp && dateB is Timestamp) {
                      return dateB.seconds.compareTo(dateA.seconds); // Tri décroissant
                    } else if (dateA is String && dateB is String) {
                      // Optionnel : gérer les dates sous forme de chaîne
                      return DateTime.parse(dateB).compareTo(DateTime.parse(dateA)); // Tri décroissant
                    }
                    return 0; // Si les deux dates ne sont pas comparables, ne changez rien
                  });

                  if (filteredDocs.isEmpty) {
                    return const Center(child: Text("Aucune demande trouvée."));
                  }

                  // Afficher les demandes dynamiquement
                  return Column(
                    children: filteredDocs.map((demandeData) {
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('utilisateurs')
                            .doc(demandeData['userId'])
                            .get(),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          var utilisateur = userSnapshot.data!.data() as Map<String, dynamic>;
                          String prenomDemandeur = utilisateur['prenom'] ?? 'Prénom inconnu';
                          String nomDemandeur = utilisateur['nom'] ?? 'Nom inconnu';
                          String TelDemandeur = utilisateur['numeroTelephone'] ?? 'Tel inconnu';
                          String groupeSanguin = demandeData['groupeSanguin'] ?? 'Non spécifié';
                          String statut = demandeData['urgence'] ? 'Urgent' : 'Attente';

                          return _itemsDemande(
                            context, 
                            nomDemandeur, 
                            TelDemandeur,
                            groupeSanguin, 
                            statut, 
                            prenomDemandeur, 
                            utilisateur, 
                            demandeData 
                          );
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
  Widget _itemsDemande(BuildContext context, String nomDemandeur, String TelDemandeur, String groupeSanguin, String statut, String prenomDemandeur, Map<String, dynamic> utilisateur, DocumentSnapshot demandeData) {
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
          // Affichage du prénom et nom du demandeur
          Row(
            children: [
              Text(
                prenomDemandeur,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
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
                        MaterialPageRoute(
                          builder: (context) => DemandeDetailsPage(
                            nom: utilisateur['nom'],
                            prenom: utilisateur['prenom'],
                            telephone: utilisateur['numeroTelephone'],
                            groupeSanguin: groupeSanguin,
                            quantite: demandeData['quantite'],
                            urgence: demandeData['urgence'],
                            demandeId: demandeData.id,
                          ),
                        ),
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
