import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _locationController = TextEditingController();
  String location = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weather App')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              child: Center(
                child: Text(location, style: TextStyle(fontSize: 25)),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Enter your location',
                border: OutlineInputBorder(), // border
                suffixIcon: IconButton(
                  // button to enter location
                  onPressed: () {
                    //update location manually when push button
                    setState(() {
                      location = _locationController.text;
                    });
                  },
                  icon: Icon(Icons.add_location),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                child: Text('Auto-detect Location'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
