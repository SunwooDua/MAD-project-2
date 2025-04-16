import 'package:flutter/material.dart';
import 'package:project2/services/api_service.dart';
import 'package:project2/models/weathers.dart';

class ForecastScreen extends StatefulWidget {
  final String latitude;
  final String longitude;

  const ForecastScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  final _weatherService = WeatherService();
  Weather? _weather; // save weather model in _weather

  // fetch weather
  _fetchWeather() async {
    try {
      // get weather info
      final weather = await _weatherService.fetchWeather(
        double.parse(widget.latitude),
        double.parse(widget.longitude),
      );

      setState(() {
        // update weather
        _weather = weather;
      });
    } catch (e) {
      print(e); // handle error
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forecast")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Temperature: ${_weather?.temperature}℃'),
            Text('Humidity: ${_weather?.humidity}%'),
            Text('Condition: ${_weather?.condition}'),
            Text('Wind Speed: ${_weather?.windSpeed} m/s'),
          ],
        ),
      ),
    );
  }
}
