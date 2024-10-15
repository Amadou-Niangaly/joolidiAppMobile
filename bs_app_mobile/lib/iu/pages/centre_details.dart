import 'package:flutter/material.dart';

class CentreDetailsPage extends StatelessWidget {
  const CentreDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
   return Scaffold(
      appBar: AppBar(
        title: const Center(
          child:  Text("centre details"),
        ),
      ),

    );
  }
}