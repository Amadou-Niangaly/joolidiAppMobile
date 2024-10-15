import 'package:flutter/material.dart';

class CentrePage extends StatelessWidget {
  const CentrePage({super.key});

  @override
  Widget build(BuildContext context) {
 return Scaffold(
      appBar: AppBar(
        title: const Center(
          child:  Text("les centres"),
        ),
      ),

    );
  }
}