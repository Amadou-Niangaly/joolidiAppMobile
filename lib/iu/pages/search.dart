import 'package:flutter/material.dart';

class SearchSection extends StatelessWidget {
  final Function(String) onSearchChanged; // Ajoutez le paramètre ici

  const SearchSection({super.key, required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).hintColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: onSearchChanged, // Ajoutez cette ligne
              decoration: InputDecoration(
                hintText: 'Rechercher',
                border: InputBorder.none,
              ),
            ),
          ),
          const Icon(Icons.search),
        ],
      ),
    );
  }
}
