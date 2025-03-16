import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/city.dart';
import '../models/weather_data.dart';

class ApiService {
  final String _baseUrl = 'https://api.openweathermap.org';
  final String _apiKey = 'a19c953708d2672f7d7e1b0c482ff463'; // Définir directement l'API Key ici

 Future<Map<String, dynamic>> _get(String endpoint, Map<String, String> params , String typeAppel) async {
    final uri = Uri.https(_baseUrl.replaceAll('https://', ''), endpoint, {...params, 'appid': _apiKey});
  debugPrint("L'URL : $uri");

  final response = await http.get(uri);
  debugPrint("Réponse : $response");

  if (response.statusCode == 200) {
    try {
      final data = json.decode(response.body);
      debugPrint("Réponse JSON décodée : $data");

      if (data is Map<String, dynamic>) {
        // Si l'appel est "direct", on vérifie la présence des coordonnées
        if (typeAppel == 'direct') {
          if (data.containsKey('lat') && data.containsKey('lon')) {
            return data;
          } else {
            throw Exception('Required keys (lat, lon) are missing');
          }
        } else {
          // Si ce n'est pas un appel direct, retourne simplement les données
          return data;
        }
      } else if (data is List && data.isNotEmpty && data[0] is Map<String, dynamic>) {
        return data[0] as Map<String, dynamic>;
      } else {
        throw Exception('Format de données inattendu');
      }
    } catch (e) {
      throw Exception('Échec du décodage JSON : $e');
    }
  } else {
    throw Exception('Échec de la récupération des données : ${response.statusCode} ${response.reasonPhrase}');
  }
  }

 Future<dynamic> getAllCities(String query) async {
  try {
    final data = await _get('/geo/1.0/direct', {
      'q': query,
      'country': 'FR', // Recherche dans la France
      'limit': '1'  // Limite la recherche à une seule ville
    }, "direct");

    debugPrint("Données reçues de l'API pour $query : $data");

    // Vérifiez si les données sont valides
    if (data.isNotEmpty) {
      return data;  // Retourne la première ville (puisqu'on a limité la recherche à 1)
    } else {
      debugPrint("Aucune ville trouvée pour $query.");
      return null;
    }
  } catch (e) {
    debugPrint("Erreur dans getAllCities pour $query : $e");
    return null;
  }
}

Future<Map<String, double>> getCoordinates(String city) async {
  final data = await _get('/geo/1.0/direct', {'q': city, 'limit': '1'},"direct");
  print('Data received: $data');

  if (data.isNotEmpty) {
    final double lat = data['lat'];
    final double lon = data['lon'];

    print('Latitude: $lat, Longitude: $lon');

    if (lat != null && lon != null) {
      if (lat is double && lon is double) {
        return {
          'latitude': lat,
          'longitude': lon,
        };
      } else {
        throw Exception('Latitude or Longitude is not a valid number.');
      }
    } else {
      throw Exception('Latitude or Longitude is null.');
    }
  } else {
    throw Exception('City not found or coordinates are not available.');
  }
}

  Future<String> getCityName(double latitude, double longitude) async {
    final data = await _get('/geo/1.0/reverse', {
      'lat': latitude.toString(),
      'lon': longitude.toString(),
      'limit': '1'
    },"reverse");
    if (data.isEmpty) {
      throw Exception('City name not found.');
    }
    return data[0]['name'];
  }

  Future<WeatherData> getWeather(double latitude, double longitude, bool isCelsius) async {
  debugPrint("donnée début appelle de (getWeather) : lon $longitude ; lat $latitude");
  final units = isCelsius ? 'metric' : 'imperial';
  final data = await _get('/data/2.5/weather', {
    'lat': latitude.toString(),
    'lon': longitude.toString(),
    'units': units
  },"weather");
  print("donnée sortie getWeather $data");
  return WeatherData.fromJson(data);
}

  Future<List<Forecast>> getForecast(double latitude, double longitude, bool isCelsius) async {
    final units = isCelsius ? 'metric' : 'imperial';
    final data = await _get('/data/2.5/forecast', {
      'lat': latitude.toString(),
      'lon': longitude.toString(),
      'units': units
    },"forecast");
    return (data['list'] as List).map((forecast) => Forecast.fromJson(forecast)).toList();
  }
} 