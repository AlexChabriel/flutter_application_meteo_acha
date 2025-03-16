import 'package:flutter/material.dart';

class WeatherData {
  final String description;
  final double temperature;
  final String iconUrl;
  final List<Forecast> forecast;
  final String cityName; // Ajout du champ cityName

  WeatherData({
    required this.description,
    required this.temperature,
    required this.iconUrl,
    required this.forecast,
    required this.cityName, // Ajout du paramètre cityName dans le constructeur
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    debugPrint("");
    // Liste des prévisions à partir de 'list' (habituellement la clé utilisée dans les prévisions par OpenWeather)
    List<Forecast> forecastList = [];
    if (json['list'] != null) {
      for (var item in json['list']) {
        forecastList.add(Forecast.fromJson(item));
      }
    }

    return WeatherData(
      description: json['weather'][0]['description'],
      temperature: json['main']['temp'],
      iconUrl: 'https://openweathermap.org/img/w/${json['weather'][0]['icon']}.png',
      forecast: forecastList,
      cityName: json['name'], // Récupération du nom de la ville depuis la clé 'name'
    );
  }
}

class Forecast {
  final String time;
  final double temperature;
  final String condition;
  final String iconUrl;

  Forecast({
    required this.time,
    required this.temperature,
    required this.condition,
    required this.iconUrl,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      time: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000).toString(), // Conversion du timestamp UNIX
      temperature: json['main']['temp'],
      condition: json['weather'][0]['description'],
      iconUrl: 'https://openweathermap.org/img/wn/${json['weather'][0]['icon']}.png', // Construction de l'URL de l'icône
    );
  }
}
