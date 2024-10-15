import 'package:bs_app_mobile/iu/pages/centre.dart';
import 'package:bs_app_mobile/iu/pages/centre_details.dart';
import 'package:bs_app_mobile/iu/pages/liste_demande.dart';
import 'package:bs_app_mobile/iu/pages/notification.dart';
import 'package:bs_app_mobile/services/auth_service.dart';
import 'package:flutter/material.dart';

class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
   return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 30,),
             _bienvenuSection(),
                const SizedBox(height: 10,),
             _sensiblisationSection(),
                const SizedBox(height: 10,),
              _voirSection(),  
              _urgenceSection(context),
              _historiqueSection(context),
          ],
        ),
      )
    );
  }
  
   // Nouvelle méthode pour récupérer et afficher le prénom de l'utilisateur
  Widget _bienvenuSection() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: FirebaseAuthService().getUserInfo(), // Récupérer les infos utilisateur
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Afficher un indicateur de chargement
        } else if (snapshot.hasError) {
          return const Text("Erreur lors de la récupération des informations.");
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Text("Utilisateur non trouvé.");
        } else {
          final userInfo = snapshot.data!;
          final prenom = userInfo['prenom']; // Récupérer le prénom de l'utilisateur
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(10),
            child: Text(
              "Bienvenu $prenom !", // Afficher le prénom
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
      },
    );
  }

  
  _sensiblisationSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white, 
    borderRadius: BorderRadius.circular(10), 
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2), // Couleur de l'ombre avec opacité
        spreadRadius: 2, // Expansion de l'ombre
        blurRadius: 8, // Rayon de flou pour l'ombre
        offset: const Offset(0, 4), // Décalage de l'ombre (horizontal, vertical)
      ),
    ],

 ),
     child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
       children: [
         Image.asset('assets/images/motivation.png'),
         const SizedBox(width: 10,),
           const Expanded(  // Utilisation de Expanded pour ajuster le texte
                child: Text(
                  "Donnez son sang, c'est sauver une vie .",
                  style: TextStyle(
                    fontSize: 25, 
                  ),
           ),
           ),
       ],
     ),
    );
  }
  
  _voirSection() {
         return Container(
          width: double.infinity,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      child:  const Text("cliquez pour voir",
      style: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
        
      ),
      ),
    );
  }
  
   _urgenceSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround, // Pour espacer les containers
      children: [
        _urgenceContainer(
          'Demandes ',
          'assets/images/urgence.png', // Remplace avec ton image
          () {
            // Naviguer vers la première page d'urgence
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ListeDemandePage()),
            );
          },
        ),
        _urgenceContainer(
          'Centres',
          'assets/images/centre.png', // Remplace avec ton image
          () {
            // Naviguer vers la page des centres
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CentrePage ()),
            );
          },
        ),
      ],
    );
  }

  Widget _urgenceContainer(String title, String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        height: 160, // Largeur fixe pour les containers
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
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
          children: [
            Image.asset(imagePath, height: 80), // Image
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

 _historiqueSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround, // Pour espacer les containers
      children: [
        _historiqueContainer(
          'Historique don',
          'assets/images/demande.png', // Remplace avec ton image
          () {
            // Naviguer vers la première page d'urgence
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationPage()),
            );
          },
        ),
        _historiqueContainer(
          'Historique demande',
          'assets/images/histdon.png', // Remplace avec ton image
          () {
            // Naviguer vers la page des centres
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _historiqueContainer(String title, String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        height: 160, // Largeur fixe pour les containers
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
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
          children: [
            Image.asset(imagePath, height: 80), // Image
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }




