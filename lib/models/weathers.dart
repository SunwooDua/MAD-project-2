import 'package:flutter/foundation.dart';

class Weather {
  final double temperature;
  final int humidity;
  final double windSpeed;
  final String condition;
  final DateTime? time;

  Weather({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
    this.time,
  });

  // hourly
  factory Weather.fromHourlyJson(Map<String, dynamic> json) {
    // decode
    return Weather(
      // correctly convert what we recive from api
      temperature: json['main']['temp'].toDouble(),
      condition: json['weather'][0]['description'],
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
      time: DateTime.fromMillisecondsSinceEpoch(
        json['dt'] * 1000,
      ), // 1000 mili is one sec
    );
  }
}
