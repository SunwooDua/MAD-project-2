import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:project2/screens/forecast_screen.dart';
import 'package:project2/screens/settings_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'package:project2/screens/interactive_map.dart';
import 'package:project2/screens/weather_community_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _locationController = TextEditingController();
  String location = '';
  String longitude = '';
  String latitude = '';
  String? backgroundImage;

  @override
  void initState() {
    super.initState();
    _initFirebaseMsg();
    _loadBackground();
  }

  Future<void> _loadBackground() async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance
            .collection('settings')
            .doc('default')
            .get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      setState(() {
        backgroundImage = data['theme']['backgroundImage'] ?? null;
      });
    }
  }

  Future<void> _initFirebaseMsg() async {
    await FirebaseMessaging.instance.requestPermission();
    String? token = await FirebaseMessaging.instance.getToken();

    FirebaseFirestore.instance
        .collection('settings')
        .doc('default')
        .snapshots()
        .listen((settingsDoc) {
          Map<String, dynamic> alertSettings = {};
          if (settingsDoc.exists) {
            alertSettings = settingsDoc.data() as Map<String, dynamic>;
          }
          FirebaseMessaging.onMessage.listen((RemoteMessage message) {
            _handleNotification(message, alertSettings);
          });
        });
  }

  void _handleNotification(
    RemoteMessage message,
    Map<String, dynamic> alertSettings,
  ) {
    String title = message.notification?.title?.toLowerCase() ?? 'no title';
    String body = message.notification?.body?.toLowerCase() ?? 'no body';
    RegExp reg = RegExp(r'-?\d+(\.\d+)?');
    Match? match = reg.firstMatch(body);
    double? temp = match != null ? double.tryParse(match.group(0)!) : null;

    bool showMessage = false;

    if (title.contains('rain') && alertSettings['alerts']['rain'] == true)
      showMessage = true;
    if (title.contains('snow') && alertSettings['alerts']['snow'] == true)
      showMessage = true;
    if (title.contains('high') && temp != null) {
      double setTemp = alertSettings['alerts']['temperature'] ?? 0;
      if (setTemp < temp) showMessage = true;
    }
    if (title.contains('low') && temp != null) {
      double setTemp = alertSettings['alerts']['temperature'] ?? 0;
      if (setTemp > temp) showMessage = true;
    }

    if (showMessage) {
      _showMsgDialog(
        message.notification!.title ?? "No Title",
        message.notification!.body ?? "No Body",
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification filtered out based on settings')),
      );
    }
  }

  void _showMsgDialog(String title, String body) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
    );
  }

  Future<void> _getCurrentPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    Placemark place = placemarks[0];

    setState(() {
      location =
          '${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}';
      latitude = position.latitude.toString();
      longitude = position.longitude.toString();
    });
  }

  Future<void> _convertAddress(String address) async {
    List<Location> locations = await locationFromAddress(address);
    List<Placemark> placemarks = await placemarkFromCoordinates(
      locations[0].latitude,
      locations[0].longitude,
    );

    Placemark place = placemarks[0];

    setState(() {
      location =
          '${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}';
      latitude = locations[0].latitude.toString();
      longitude = locations[0].longitude.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(onPressed: _loadBackground, icon: Icon(Icons.update)),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image:
              backgroundImage != null
                  ? DecorationImage(
                    image:
                        backgroundImage!.startsWith('assets')
                            ? AssetImage(backgroundImage!)
                            : FileImage(File(backgroundImage!))
                                as ImageProvider,
                    fit: BoxFit.cover,
                  )
                  : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                color: Colors.white.withAlpha(200),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      location.isNotEmpty
                          ? 'Your location is: $location'
                          : 'Please enter your location!',
                      style: TextStyle(fontSize: 25),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                color: Colors.white.withAlpha(200),
                child: TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Enter your location',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        final address = _locationController.text;
                        _convertAddress(address);
                      },
                      icon: Icon(Icons.add_location),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _getCurrentPosition,
                  child: Text('Auto-detect Location'),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (latitude.isNotEmpty && longitude.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ForecastScreen(
                                latitude: latitude,
                                longitude: longitude,
                                locationName: location,
                              ),
                        ),
                      );
                    }
                  },
                  child: Text('Forecast'),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsScreen()),
                    );
                  },
                  child: Text('Settings'),
                ),
              ),
              // Interactive Map Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (latitude.isNotEmpty && longitude.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => InteractiveMapScreen(
                                latitude: double.parse(latitude),
                                longitude: double.parse(longitude),
                              ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Please enter or detect a location first.',
                          ),
                        ),
                      );
                    }
                  },
                  child: Text('Interactive Map'),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                WeatherCommunityScreen(location: location),
                      ),
                    );
                  },
                  child: Text('Community Reports'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
