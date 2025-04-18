import 'package:flutter/material.dart';
import 'package:project2/services/api_service.dart';
import 'package:project2/models/weathers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Theme
  String? _selectTheme;
  // for changing background image
  String? _backgroundImage = 'assets/happy.jpg';

  // alert
  bool _rainAlert = false; // initially false
  bool _snowAlert = false;
  double _temperatureThreshold = 50; // initial temperature

  @override
  void initState() {
    // load alert setting
    super.initState();
    _loadAlert();
  }

  // load alert function
  Future<void> _loadAlert() async {
    // get toekn for FCM
    String? token = await FirebaseMessaging.instance.getToken();

    // just to simplify
    DocumentSnapshot doc =
        await FirebaseFirestore.instance
            .collection('settings')
            .doc('default')
            .get();

    // only when doc exist
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      var alert =
          data['alerts'] ??
          {}; // update alert, when null update as empty string
      setState(() {
        _rainAlert = alert['rain'] ?? false;
        _snowAlert = alert['snow'] ?? false;
        _temperatureThreshold = (alert['temperature'] ?? 50).toDouble();
      });
    }
  }

  // update alert function
  Future<void> _updateAlert() async {
    FirebaseFirestore.instance.collection('settings').doc('default').set({
      // using default since no login is required
      'alerts': {
        'rain': _rainAlert,
        'snow': _snowAlert,
        'temperature': _temperatureThreshold,
      },
    }, SetOptions(merge: true)); // only change data mentioned above to true!

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Alert Setting has been updated')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Colors.yellowAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          image:
              _backgroundImage !=
                      null // while background image is not null
                  ? DecorationImage(
                    image: AssetImage(_backgroundImage!), // use backgroundImage
                    fit: BoxFit.cover,
                  )
                  : null,
        ),
        child: Column(
          children: [
            SwitchListTile(
              // rain
              title: Text("Rain Alert"),
              value: _rainAlert,
              onChanged: (val) {
                setState(() {
                  _rainAlert = val;
                });
              },
            ),
            SizedBox(height: 20),
            SwitchListTile(
              // snow
              title: Text("Snow Alert"),
              value: _snowAlert,
              onChanged: (val) {
                setState(() {
                  _snowAlert = val;
                });
              },
            ),
            SizedBox(height: 20),
            // temperature using slide
            ListTile(
              title: Text(
                'Temperature : ${_temperatureThreshold.toStringAsFixed(2)} °C',
              ),
              subtitle: Slider(
                min: -100,
                max: 100,
                divisions: 200,
                value: _temperatureThreshold,
                onChanged: (double value) {
                  setState(() {
                    _temperatureThreshold = value;
                  });
                },
              ),
            ),
            SizedBox(height: 20),
            // update
            ElevatedButton(
              onPressed: _updateAlert,
              child: Text('Update Changed Settings'),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _backgroundImage = 'assets/happy.jpg';
                    });
                  },
                  child: Text('Happy'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _backgroundImage = 'assets/sad.jpg';
                    });
                  },
                  child: Text('Sad'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _backgroundImage = 'assets/angry.jpg';
                    });
                  },
                  child: Text('Angry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
