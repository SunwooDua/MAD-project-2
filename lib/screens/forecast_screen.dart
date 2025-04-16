import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
