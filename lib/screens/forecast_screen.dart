import 'package:flutter/material.dart';
import 'package:project2/services/api_service.dart';

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
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
