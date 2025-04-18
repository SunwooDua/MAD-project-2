import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:project2/screens/forecast_screen.dart';

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
      appBar: AppBar(title: Text('Weather App'), backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
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
                      final address = _locationController.text;
                      _convertAddress(address);
                    });
                  },
                  icon: Icon(Icons.add_location),
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
          ],
        ),
      ),
    );
  }
}
