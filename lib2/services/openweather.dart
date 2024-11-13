import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:points_verts/company_data.dart';
import 'package:weather_icons/weather_icons.dart';

import '../models/weather.dart';
import 'cache_managers/weather_cache_manager.dart';

String? _token = dotenv.env['OPENWEATHER_TOKEN'];

Future<List<Weather>> getWeather(double long, double lat, DateTime date) async {
  if (date.difference(DateTime.now()).inDays < 5) {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$long&lang=fr&units=metric&appid=$_token';
    try {
      final response =
          await WeatherCacheManager.weather.getData(url);
      final decoded = json.decode(response.body);
      final list = decoded['list'];

      if (list != null) {
        final results = <Weather>[];
        final from = date.add(const Duration(hours: 6)).millisecondsSinceEpoch;
        final to = date.add(const Duration(hours: 18)).millisecondsSinceEpoch;
        for (final forecast in list) {
          final int time = forecast['dt'] * 1000;
          if (time > from && time < to) {
            results.add(_createWeather(forecast));
          }
        }
        return results;
      }
    } catch (err) {
      print("Couldn't retrieve weather, $err");
    }
  }

  return [];
}

Weather _createWeather(var forecast) {
  return Weather(
      temperature: forecast['main']['temp'].toDouble(),
      weatherId: forecast['weather'][0]['id'],
      weather: forecast['weather'][0]['description'],
      weatherIcon: forecast['weather'][0]['icon'],
      windSpeed: forecast['wind']['speed'] * 3.6,
      timestamp: DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000),);
}

Widget getWeatherIcon(Weather weather, {double? iconSize, Color? iconColor}) {
  IconData icon;
  switch (weather.weatherId) {
    case 200:
    case 201:
    case 202:
    case 230:
    case 231:
    case 232:
      icon = WeatherIcons.thunderstorm;
    case 210:
    case 211:
    case 212:
    case 221:
      icon = WeatherIcons.lightning;
    case 300:
    case 301:
    case 321:
    case 500:
      icon = WeatherIcons.sprinkle;
    case 302:
    case 311:
    case 312:
    case 314:
    case 501:
    case 502:
    case 503:
    case 504:
      icon = WeatherIcons.rain;
    case 310:
    case 511:
    case 611:
    case 612:
    case 615:
    case 616:
    case 620:
      icon = WeatherIcons.rain_mix;
    case 313:
    case 520:
    case 521:
    case 522:
    case 701:
      icon = WeatherIcons.showers;
    case 531:
    case 901:
      icon = WeatherIcons.storm_showers;
    case 600:
    case 601:
    case 621:
    case 622:
      icon = WeatherIcons.snow;
    case 602:
      icon = WeatherIcons.sleet;
    case 711:
      icon = WeatherIcons.smoke;
    case 721:
      icon = WeatherIcons.day_haze;
    case 731:
    case 761:
    case 762:
      icon = WeatherIcons.dust;
    case 741:
      icon = WeatherIcons.fog;
    case 771:
    case 801:
    case 802:
    case 803:
      icon = WeatherIcons.cloudy_gusts;
    case 781:
    case 900:
      icon = WeatherIcons.tornado;
    case 800:
      icon = WeatherIcons.day_sunny;
    case 804:
      icon = WeatherIcons.cloudy;
    case 902:
      icon = WeatherIcons.hurricane;
    case 903:
      icon = WeatherIcons.snowflake_cold;
    case 904:
      icon = WeatherIcons.hot;
    case 905:
      icon = WeatherIcons.windy;
    case 906:
      icon = WeatherIcons.hail;
    case 957:
      icon = WeatherIcons.strong_wind;
    default:
      icon = WeatherIcons.na;
  }
  return BoxedIcon(icon,
      color: iconColor ?? CompanyColors.blue, size: iconSize,);
}
