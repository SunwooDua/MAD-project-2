import 'package:flutter/material.dart';
import 'package:project2/services/api_service.dart';
import 'package:project2/models/weathers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Theme
  String? _selectTheme;

  // alert
  bool _rainAlert = false; // initially false
  bool _snowAlert = false;
  double _temperatureThreshold = 50; // initial temperature

  // load alert function
  Future<void> _loadAlert() async {
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
    return const Placeholder();
  }
}
