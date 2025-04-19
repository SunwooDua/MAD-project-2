import 'package:flutter/material.dart';
import 'package:project2/services/api_service.dart';
import 'package:project2/models/weathers.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:project2/screens/forecast_screen.dart';
import 'package:project2/screens/settings_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';

class ForecastScreen extends StatefulWidget {
  final String latitude;
  final String longitude;
  final String locationName;

  const ForecastScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
  });

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  final _weatherService = WeatherService();
  List<Weather> hourlyForecast = [];
  List<Weather> dailyForecast = [];
  bool showHourly = true; // default is to show hourly forecast
  String? backgroundImage;

  // fetch weather
  _fetchWeather() async {
    try {
      // get weather info for hourly forecast
      final hourly = await _weatherService.fetchWeatherHourly(
        double.parse(widget.latitude),
        double.parse(widget.longitude),
      );

      // get weather info for daily forecast
      final daily = await _weatherService.fetchWeatherDaily(
        double.parse(widget.latitude),
        double.parse(widget.longitude),
      );

      setState(() {
        // update weather
        hourlyForecast = hourly;
        dailyForecast = daily;
      });
    } catch (e) {
      print(e); // handle error
    }
  }

  // group weather
  String groupWeather(String condition) {
    final g =
        condition
            .toLowerCase(); // g as group , lowercase so there is no missing

    if (g.contains('sun') || g.contains('clear'))
      return 'sunny'; // if weather contians sun or clear return sunny
    if (g.contains('cloud'))
      return 'cloudy'; // if weather conatins cloud return cloudy
    if (g.contains('snow'))
      return 'snowy'; // if weather conatins snow return snowy
    if (g.contains('rain') || g.contains('drizzle'))
      return 'rainy'; // if weather conatins rain or drizzle return rainy
    else {
      return 'cloudy'; // rest are atomoshphere that related to cloudy
    }
  }

  // selecting appropriate weather image
  String getWeatherImages(String condition) {
    switch (groupWeather(condition)) {
      // switch depending on its group
      case 'sunny':
        return 'assets/sunny.png';
      case 'cloudy':
        return 'assets/cloudy.png';
      case 'snowy':
        return 'assets/snowy.png';
      case 'rainy':
        return 'assets/rainy.png';
      default:
        return 'assets/cloudy.png';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
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

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Forecast"),
        backgroundColor: Colors.lightBlueAccent,
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  color: Colors.white.withAlpha(200),
                  child: Text('Location : ${widget.locationName}'),
                ),
                Container(
                  color: Colors.white.withAlpha(200),

                  child: Text(
                    '${showHourly ? "Hourly" : "Daily"} Forecast : ${DateTime.now().toLocal().toString().split(' ')[0]}', // only show date no time
                  ),
                ),
                SizedBox(height: 20),
                // buttons to switch daily or hourly
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showHourly = true;
                        });
                      },
                      child: Text('Hourly'),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showHourly = false;
                        });
                      },
                      child: Text('Daily'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Forecast Lists
                Expanded(
                  child: ListView.builder(
                    itemCount:
                        showHourly
                            ? hourlyForecast.length
                            : dailyForecast.length,
                    itemBuilder: (context, index) {
                      final weather =
                          showHourly
                              ? hourlyForecast[index]
                              : dailyForecast[index];
                      final date =
                          showHourly
                              ? '${weather.time?.hour}:00'
                              : weather.time?.toLocal().toString().split(
                                    ' ',
                                  )[0] ??
                                  '';
                      return Card(
                        child: Container(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(date),
                                    Text(weather.condition),
                                    Text('${weather.temperature ?? ' '}°C'),
                                    Text(
                                      'Humidity: ${weather.humidity ?? ' '}%',
                                    ),
                                    Text(
                                      'Wind: ${weather.windSpeed ?? ' '}m/s',
                                    ),
                                  ],
                                ),
                              ),
                              Image.asset(
                                // contain image
                                getWeatherImages(weather.condition),
                                width: 80,
                                height: 50,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
