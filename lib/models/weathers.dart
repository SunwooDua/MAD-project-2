import 'package:flutter/foundation.dart';

class Weather {
  final String location;
  final double temperature;
  final int humidity;
  final double windSpeed;
  final String condition;

  Weather({
    required this.location,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    // decode
    return Weather(
      // correctly convert what we recive from api
      location: json['name'],
      temperature: json['main']['temp'].toDouble(),
      condition: json['weather'][0]['description'],
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
    );
  }
}
