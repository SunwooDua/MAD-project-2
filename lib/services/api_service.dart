import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project2/models/weathers.dart';

class WeatherService {
  final String API_KEY = 'f276def9aa8fec1dab67ecf5b3b84378';
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/forecast';

  // for hourly forecast
  // openmapweather provide 3 hour forecast for 5 days
  Future<List<Weather>> fetchWeatherHourly(
    double latitude,
    double longitude,
  ) async {
    // from inclass 15
    final response = await http.get(
      Uri.parse(
        '$baseUrl?lat=$latitude&lon=$longitude&appid=$API_KEY&units=metric',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> forecastList = data['list'];

      // to make sure only one day is returned (instead of full 5 day)
      // 3 hour interval (24 / 3 = 8) but if include start 9
      // only pass 9 item to list
      final hourlyForecast = forecastList.take(9).toList();

      return hourlyForecast
          .map((item) => Weather.fromHourlyJson(item))
          .cast<Weather>()
          .toList();
    } else {
      throw Exception('Failed to load hourly weather');
    }
  }

  // for daily forecast
  Future<List<Weather>> fetchWeatherDaily(
    double latitude,
    double longitude,
  ) async {
    // from inclass 15
    final response = await http.get(
      Uri.parse(
        '$baseUrl?lat=$latitude&lon=$longitude&appid=$API_KEY&units=metric',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final List<dynamic> forecastList =
          data['list']; // 3 hour interval 5 day = total 40 items

      Map<String, Weather> dailyForecast = {};

      for (var item in forecastList) {
        // loop for every variable
        final weather = Weather.fromHourlyJson(
          item,
        ); // save weather data using hourly
        final dateKey =
            '${weather.time?.year}-${weather.time?.month}-${weather.time?.day}'; // separate by date

        // if no date exist, add weather
        if (!dailyForecast.containsKey(dateKey)) {
          dailyForecast[dateKey] = weather;
        }
      }

      return dailyForecast.values.toList();
    } else {
      throw Exception("Failed to load daily weather : ${response.body}");
    }
  }
}
