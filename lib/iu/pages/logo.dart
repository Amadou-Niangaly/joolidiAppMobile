import 'package:flutter/material.dart';

class LogoPage extends StatelessWidget {
  const LogoPage({super.key});

  @override
  Widget build(BuildContext context) {
  return  Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/joolidi.png',
          fit: BoxFit.contain,
          )
      ),
    );
  }
}