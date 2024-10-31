import 'package:bs_app_mobile/iu/pages/demande.dart';
import 'package:bs_app_mobile/iu/pages/hematologie.dart';
import 'package:bs_app_mobile/iu/pages/home_content.dart';
import 'package:bs_app_mobile/iu/pages/list_centre.dart';

import 'package:bs_app_mobile/iu/pages/notification.dart';
import 'package:bs_app_mobile/iu/pages/profil.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> pages = [
    const HomePageContent(),
    const Hematologie(),
    const DemandPage(),
    const ListCentrePage(),
    const ProfPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        leading:
         Image.asset(
          'assets/images/joolidi.png',
          fit:BoxFit.contain,

          ),
        actions: [
          IconButton(
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context)=> const NotificationPage())
                 );
            }, 
            icon: const Icon(Icons.notifications))
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white, // Couleur de fond
        selectedItemColor: Theme.of(context).primaryColor, // Couleur de l'élément sélectionné
        unselectedItemColor: Colors.grey, // Couleur des éléments non sélectionnés
        selectedIconTheme: const IconThemeData(size: 30), // Taille de l'icône sélectionnée
        unselectedIconTheme: const IconThemeData(size: 24), // Taille de l'icône non sélectionnée
        selectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), // Style du texte sélectionné
        unselectedLabelStyle: const TextStyle(fontSize: 12), // Style du texte non sélectionné
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed, // Empêche les icônes de bouger
        onTap: (int newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        },
        items: const [
          BottomNavigationBarItem(
            label: 'Accueil',
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: 'Maladie',
            icon: Icon(Icons.bloodtype),
          ),
          BottomNavigationBarItem(
            label: 'Demande',
            icon: Icon(Icons.assignment),
          ),
          BottomNavigationBarItem(
            label: 'Localisation',
            icon: Icon(Icons.location_on),
          ),
          BottomNavigationBarItem(
            label: 'Profil',
            icon: Icon(Icons.person),
          ),
        ],
      ),
    );
  }
}
