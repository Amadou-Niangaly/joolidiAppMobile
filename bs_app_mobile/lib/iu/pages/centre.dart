import 'package:bs_app_mobile/iu/pages/list_centre.dart';
import 'package:flutter/material.dart';

class CentrePage extends StatelessWidget {
  const CentrePage({super.key});

  @override
  Widget build(BuildContext context) {
 return Scaffold(
      appBar: AppBar(
        title: const Center(
          child:Text("centre"),
        ),
      ),
      body:  const SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            ListCentrePage()
          ],
        ),
      ),

    );
  }
}