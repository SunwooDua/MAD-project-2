import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class InteractiveMapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const InteractiveMapScreen({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  State<InteractiveMapScreen> createState() => _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends State<InteractiveMapScreen> {
  String _mapType = 'radar';

  final String apiKey = 'f276def9aa8fec1dab67ecf5b3b84378';

  String _getTileUrl() {
    if (_mapType == 'radar') {
      return 'https://tile.openweathermap.org/map/precipitation_new/{z}/{x}/{y}.png?appid=$apiKey';
    } else {
      return 'https://tile.openweathermap.org/map/clouds_new/{z}/{x}/{y}.png?appid=$apiKey';
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng center = LatLng(widget.latitude, widget.longitude);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Map'),
        backgroundColor: Colors.purple[100],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(center: center, zoom: 9.0),
            children: [
              // Base map layer (OpenStreetMap)
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.project2',
              ),

              // Weather overlay with transparency
              Opacity(
                opacity: 0.7,
                child: TileLayer(
                  urlTemplate: _getTileUrl(),
                  userAgentPackageName: 'com.example.project2',
                ),
              ),
            ],
          ),

          // Map type toggle buttons
          Positioned(
            top: 20,
            right: 20,
            child: Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _mapType == 'radar'
                            ? Colors.purple[200]
                            : Colors.grey[300],
                  ),
                  onPressed: () {
                    setState(() {
                      _mapType = 'radar';
                    });
                  },
                  child: const Text('Radar'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _mapType == 'satellite'
                            ? Colors.purple[200]
                            : Colors.grey[300],
                  ),
                  onPressed: () {
                    setState(() {
                      _mapType = 'satellite';
                    });
                  },
                  child: const Text('Satellite'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
