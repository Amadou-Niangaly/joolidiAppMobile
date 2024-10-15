import 'package:bs_app_mobile/iu/pages/demande_details.dart';
import 'package:bs_app_mobile/iu/pages/search.dart';
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
              const SearchSection(),
              const SizedBox(height: 24),
              _itemsDemande(context),
              const SizedBox(height: 10),
              _itemsDemande(context),
            ],
          ),
        ),
      ),
    );
  }

  // Modification : Ajout du paramètre context
  Widget _itemsDemande(BuildContext context) {
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
          // Nom du demandeur
          const Text(
            "Moussa Diaby",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
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
                child: const Text(
                  "O+",
                  style: TextStyle(
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
                      color: Colors.amberAccent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "Attente",
                      style: TextStyle(
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
