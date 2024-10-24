import 'package:bs_app_mobile/iu/pages/login.dart';
import 'package:bs_app_mobile/iu/pages/sign_up.dart';
import 'package:flutter/material.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
   return Scaffold(
  body: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset("assets/images/joolidi.png"),
        const SizedBox(height: 20,),
        SizedBox(
          width: double.infinity, // Prendre toute la largeur
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0), // Optionnel : marges latérales
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFFFFF),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(
                    color: Color(0XFFDC1A47)
                  )
                ),
                   minimumSize: const Size(150, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (builder)=> const LoginPage()));
              }, 
              child: const Text("se connecter",
              style:TextStyle(
                color:Color(0XFFDC1A47),
                fontSize: 20
                ) ,),
            ),
          ),
        ),
        const SizedBox(height: 10,),
        SizedBox(
          width: double.infinity, // Prendre toute la largeur
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0), // Optionnel : marges latérales
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 12.0), 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)
                ),
                minimumSize: const Size(150, 50), // Largeur: 150, Hauteur: 60
              ),
              onPressed: () {
                Navigator.push(
                  context,
                   MaterialPageRoute(builder: (builder)=>const SignUpPage())
                   );
              }, 
              child: const Text(
                "créer compte",
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 20
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  ),
);

  }
}