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
  List<Weather> hourlyForecast = [];

  // fetch weather
  _fetchWeather() async {
    try {
      // get weather info for hourly forecast
      final hourly = await _weatherService.fetchWeatherHourly(
        double.parse(widget.latitude),
        double.parse(widget.longitude),
      );

      setState(() {
        // update weather
        hourlyForecast = hourly;
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
            Expanded(
              child: ListView.builder(
                itemCount: hourlyForecast.length.clamp(
                  0,
                  24,
                ), // limit to one day
                itemBuilder: (context, index) {
                  final weather = hourlyForecast[index];
                  return Card(
                    child: Container(
                      child: Column(
                        children: [
                          Text('${weather.time?.hour}:00'),
                          Text('${weather.temperature}°C'),
                          Text(weather.condition),
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
    );
  }
}
