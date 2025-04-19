import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:project2/screens/forecast_screen.dart';
import 'package:project2/screens/settings_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

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

  // initialize fcm
  @override
  void initState() {
    super.initState();
    _initFirebaseMsg();
    _loadBackground(); // for background
  }

  // load background
  Future<void> _loadBackground() async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance
            .collection('settings')
            .doc('default')
            .get();

    // only when doc exist
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      setState(() {
        // load background image
        backgroundImage = data['theme']['backgroundImage'] ?? null;
      });
    }
  }

  Future<void> _initFirebaseMsg() async {
    // ask for permission
    await FirebaseMessaging.instance.requestPermission();

    // get token
    String? token = await FirebaseMessaging.instance.getToken();

    // fetch settings
    FirebaseFirestore.instance
        .collection('settings')
        .doc('default')
        .snapshots()
        .listen((settingsDoc) {
          Map<String, dynamic> alertSettings = {};
          if (settingsDoc.exists) {
            alertSettings = settingsDoc.data() as Map<String, dynamic>;
          }
          // foreground
          FirebaseMessaging.onMessage.listen((RemoteMessage message) {
            _handleNotification(
              message,
              alertSettings,
            ); // to update settings live
          });
        });
  }

  void _handleNotification(
    RemoteMessage message,
    Map<String, dynamic> alertSettings,
  ) {
    print("Notification recived: ${message.notification?.title}");

    // save title as lowercase to decide wether to show or not show the msg
    String title = message.notification?.title?.toLowerCase() ?? 'no title';
    // for temperature
    String body = message.notification?.body?.toLowerCase() ?? "no body";
    RegExp reg = RegExp(
      r'-?\d+(\.\d+)?',
    ); // reg ex -? for optional negative, d+ for one or more digit number, (\.\d+ for decimal)
    Match? match = reg.firstMatch(
      body,
    ); // find what matches above reg expression
    double? temp =
        match != null
            ? double.tryParse(match.group(0)!)
            : null; // if match is not null pick first matched as temp

    // condition to decide display msg or not
    bool showMessage = false;

    // logic to decide
    if (title.contains('rain') && alertSettings['alerts']['rain'] == true) {
      showMessage = true;
    }
    if (title.contains('snow') && alertSettings['alerts']['snow'] == true) {
      showMessage = true;
    }
    if (title.contains('high') && temp != null) {
      double setTemp =
          alertSettings['alerts']['temperature'] ??
          0; // save temperature Threshold setting
      if (setTemp < temp) {
        showMessage =
            true; // when high temp warning, only show when temp is higher
      }
    }
    if (title.contains('low') && temp != null) {
      double setTemp =
          alertSettings['alerts']['temperature'] ??
          0; // save temperature Threshold setting
      if (setTemp > temp) {
        showMessage = true; // when low temp warning, only show when temp is low
      }
    }

    if (showMessage == true) {
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

  // display nofitication
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
    LocationPermission permission =
        await Geolocator.checkPermission(); // check permission
    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission(); // if no permission ask for permission
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
      ), // make it more accurate
    );

    // convert locations into placemarks
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    // choose first of placemark
    Placemark place = placemarks[0];
    // if null give empty
    String city = place.locality ?? '';
    String state = place.administrativeArea ?? '';
    String country = place.country ?? '';

    setState(() {
      location = '$city, $state, $country'; // update location
      // pass latitude and longitude
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

    // choose first of placemark
    Placemark place = placemarks[0];
    // if null give empty
    String city = place.locality ?? '';
    String state = place.administrativeArea ?? '';
    String country = place.country ?? '';

    setState(() {
      location = '$city, $state, $country'; // update location
      // since we captured address need to update lat and longt
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
          IconButton(
            onPressed: _loadBackground,
            icon: Icon(Icons.update),
          ), // refresh
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image:
              backgroundImage !=
                      null // while background image is not null
                  ? DecorationImage(
                    image:
                        backgroundImage!.startsWith('assets')
                            ? AssetImage(backgroundImage!)
                            : FileImage(
                              File(backgroundImage!),
                            ), // use backgroundImage
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
                    border: OutlineInputBorder(), // border
                    suffixIcon: IconButton(
                      // button to enter location
                      onPressed: () {
                        //update location manually when push button
                        setState(() {
                          final address = _locationController.text;
                          _convertAddress(address);
                        });
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
                width: double.infinity, // as wide as possible
                child: ElevatedButton(
                  onPressed: () {
                    if (latitude.isNotEmpty && longitude.isNotEmpty) {
                      //pass longitude and latitude
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
                width: double.infinity, // as wide as possible
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
            ],
          ),
        ),
      ),
    );
  }
}
