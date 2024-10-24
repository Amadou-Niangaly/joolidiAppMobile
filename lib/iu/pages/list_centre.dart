import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bs_app_mobile/iu/pages/localisation.dart'; // Assurez-vous que ce chemin est correct
import 'package:bs_app_mobile/iu/pages/search.dart'; // Assurez-vous que ce chemin est correct

class ListCentrePage extends StatefulWidget {
  const ListCentrePage({super.key});

  @override
  _ListCentrePageState createState() => _ListCentrePageState();
}

class _ListCentrePageState extends State<ListCentrePage> {
  String searchQuery = ''; // Variable pour stocker la requête de recherche

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const SizedBox(height: 40),
              SearchSection(
                onSearchChanged: (value) {
                  setState(() {
                    searchQuery = value; // Met à jour la requête de recherche
                  });
                },
              ),
              const SizedBox(height: 20),
              _itemsCentre(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemsCentre(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('centreDon').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Aucun centre disponible'));
        }

        final centres = snapshot.data!.docs;

        // Filtrer les centres selon la recherche
        final filteredCentres = centres.where((centre) {
          final centreData = centre.data() as Map<String, dynamic>;
          return centreData['nom'].toString().toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredCentres.length,
          itemBuilder: (context, index) {
            final centre = filteredCentres[index].data() as Map<String, dynamic>;
            return _centreCard(context, centre);
          },
        );
      },
    );
  }

  Widget _centreCard(BuildContext context, Map<String, dynamic> centre) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      height: 100,
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            centre['nom'] ?? 'Nom indisponible',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ouvert: ${centre['heureOuverture'] ?? 'Inconnu'}',
                style: const TextStyle(fontSize: 16),
              ),
              IconButton(
                onPressed: () {
                  // Naviguer vers LocalsPage avec les données du centre
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (builder) => LocalsPage(centre: centre),
                    ),
                  );
                },
                icon: const Icon(Icons.location_pin, size: 30, color: Colors.grey),
              )
            ],
          ),
        ],
      ),
    );
  }
}
