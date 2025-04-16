import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project2/models/weathers.dart';

class WeatherService {
  final String API_KEY = 'f276def9aa8fec1dab67ecf5b3b84378';
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<Weather> fetchWeather(double latitude, double longitude) async {
    // from inclass 15
    final response = await http.get(
      Uri.parse(
        '$baseUrl?lat=$latitude&lon=$longitude&appid=$API_KEY&units=metric',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Weather.fromJson(data);
    } else {
      throw Exception('Failed to load weather');
    }
  }
}
