import 'package:flutter/material.dart';

class DemandeDetaislPage extends StatelessWidget {
  const DemandeDetaislPage({super.key});

  @override
  Widget build(BuildContext context) {
      return Scaffold(
      appBar: AppBar(
        title: const Text(" details demandes"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40,),
            _detailsItems(),
          ],
        ),
      ),
    );
  }
  
  _detailsItems() {
    return Container(
      width: double.infinity,
      height: 300,
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
      child: const Padding(
        padding:EdgeInsets.all(10),
        child:Column(
          children: [
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
          
              children: [
                Text("Nom",
                style: TextStyle(
                  fontSize: 16,
                ),
                ),
                 Text("Diaby",
                   style: TextStyle(
                  fontSize: 16,
                ),
                 ),  
              ],
             ),
               SizedBox(height: 15,),
                Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
          
              children: [
                Text("Prenom",
                style: TextStyle(
                  fontSize: 16,
                ),
                ),
                 Text("Moussa",
                   style: TextStyle(
                  fontSize: 16,
                ),
                 ),  
              ],
             ),
              SizedBox(height: 15,),
                Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
          
              children: [
                Text("Telephone",
                style: TextStyle(
                  fontSize: 16,
                ),
                ),
                 Text("98970909",
                   style: TextStyle(
                  fontSize: 16,
                ),
                 ),  
              ],
             ),
               SizedBox(height: 15,),
                Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
          
              children: [
                Text("Groupe sanguin",
                style: TextStyle(
                  fontSize: 16,
                ),
                ),
                 Text("O+",
                   style: TextStyle(
                  fontSize: 16,
                ),
                 ),  
              ],
             ),
              SizedBox(height: 15,),
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
          
              children: [
                Text("Quantite",
                style: TextStyle(
                  fontSize: 16,
                ),
                ),
                 Text("2(poche)",
                   style: TextStyle(
                  fontSize: 16,
                ),
                 ),  
              ],
             ),
              SizedBox(height: 15,),
                Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
          
              children: [
                Text("Urgence",
                style: TextStyle(
                  fontSize: 16,
                ),
                ),
                 Text("oui",
                   style: TextStyle(
                  fontSize: 16,
                ),
                 ),  
              ],
             ),
              SizedBox(height: 15,),
          ],
        ) ,
      
        )
      );
  }
}