import 'package:flutter/material.dart';
import 'package:project2/services/api_service.dart';
import 'package:project2/models/weathers.dart';

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
            Text('Location : ${widget.locationName}'),
            Text(
              'Hourly Forecast : ${DateTime.now().toLocal().toString().split(' ')[0]}', // only show date no time
            ),
            Expanded(
              child: ListView.builder(
                itemCount: hourlyForecast.length,
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
            Divider(),
            Text("Daily"),
            Expanded(
              child: ListView.builder(
                itemCount: dailyForecast.length,
                itemBuilder: (context, index) {
                  final weather = dailyForecast[index];
                  return Card(
                    child: Container(
                      child: Column(
                        children: [
                          Text(
                            '${weather.time?.toLocal().toString().split(' ')[0]}',
                          ),
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
