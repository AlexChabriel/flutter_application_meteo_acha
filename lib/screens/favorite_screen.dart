import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/weather_data.dart';

class FavoriteScreen extends StatelessWidget {
  final List<String> favoriteCities;

  const FavoriteScreen({super.key, required this.favoriteCities});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Villes Favorites'),
      ),
      body: ListView.builder(
        itemCount: favoriteCities.length,
        itemBuilder: (context, index) {
          String city = favoriteCities[index];
          return FutureBuilder<Map<String, double>>(
            future: ApiService().getCoordinates(city),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Erreur : ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return Center(child: Text('Aucune donnée disponible'));
              } else {
                double latitude = snapshot.data!['latitude']!;
                double longitude = snapshot.data!['longitude']!;
                return FutureBuilder<WeatherData>(
                  future: ApiService().getWeather(latitude, longitude, true), // Utilisation d'ApiService
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Erreur : ${snapshot.error}'));
                    } else if (!snapshot.hasData) {
                      return Center(child: Text('Aucune donnée disponible'));
                    } else {
                      WeatherData weatherData = snapshot.data!;
                      return ListTile(
                        title: Text(city),
                        subtitle: Text('${weatherData.temperature}° - ${weatherData.description}'),
                        leading: Image.network(weatherData.iconUrl),
                      );
                    }
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}
