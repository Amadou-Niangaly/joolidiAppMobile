import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocalsPage extends StatelessWidget {
  final Map<String, dynamic> centre; // Paramètre pour les informations du centre

  const LocalsPage({super.key, required this.centre}); // Constructeur qui accepte le paramètre 'centre'

  @override
  Widget build(BuildContext context) {
    // Récupérer les coordonnées du centre
    final location = centre['localisation']?.split(',');
    final lat = double.tryParse(location?[0] ?? '') ?? 0.0;
    final lng = double.tryParse(location?[1] ?? '') ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Localisation'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          SizedBox(
            height: 400,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(lat, lng), // Utiliser les coordonnées du centre
                initialZoom: 11,
                interactionOptions: InteractionOptions(flags: InteractiveFlag.doubleTapZoom),
              ),
              children: [
                openStreetMapTileLayer,
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(lat, lng),
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.location_pin,
                        size: 60,
                        color: Colors.red,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Nom:",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                    Text('${centre['nom'] ?? 'Inconnu'}',style:const TextStyle(fontSize: 16,))
                  ],
                ),
                const SizedBox(height: 10,),
                   Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Adresse:",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                    Text('${centre['adresse'] ?? 'Inconnu'}',style:const TextStyle(fontSize: 16,))
                  ],
                ),
                  const SizedBox(height: 10,),
                   Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Heure d\'ouverture:',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                    Text('${centre['heureOuverture'] ?? 'Inconnu'}',style:const TextStyle(fontSize: 16,))
                  ],
                ),
                    const SizedBox(height: 10,),
                   Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Telephone:',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                    Text('${centre['telephone'] ?? 'Inconnu'}',style:const TextStyle(fontSize: 16,))
                  ],
                )
              ],
            ),

          )
        ],
      ),
    );
  }
}

TileLayer get openStreetMapTileLayer => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
    );
