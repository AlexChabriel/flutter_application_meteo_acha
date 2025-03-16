import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/weather_data.dart';
import 'favorite_screen.dart';
import 'city_screen.dart';
import "../services/geolocation_service.dart";

class HomeScreen extends StatefulWidget {
  final ApiService apiService;

  const HomeScreen({super.key, required this.apiService});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late WeatherData currentWeather = WeatherData(
    description: 'Chargement...',
    temperature: 0.0,
    iconUrl: '',
    forecast: [],
    cityName: "N/A"
  );

  String selectedCity = 'annecy';
  bool isCelsius = true;

  @override
  void initState() {
    super.initState();
    debugPrint("initState() appelé !");
    _loadWeatherData();
  }

  _loadWeatherData() async {
    try {
      final coordinates = await widget.apiService.getCoordinates(selectedCity);
      debugPrint('Coordinates response: $coordinates, Type: ${coordinates.runtimeType}');

      // Vérifie la structure exacte des données
      if (coordinates.containsKey('latitude') && coordinates.containsKey('longitude')) {
        final latitude = coordinates['latitude'];
        final longitude = coordinates['longitude'];
        debugPrint("lon : $longitude ; lat : $latitude");
        if (latitude != null && longitude != null) {
          debugPrint("donnée avant appelle de (getWeather) : lon $longitude ; lat $latitude");
          final data = await widget.apiService.getWeather(latitude, longitude, isCelsius);
          debugPrint('Weather Data: $data');
          setState(() {
            currentWeather = data;
          });
        }
      } else {
        debugPrint('⚠️ Les clés lat/lon sont absentes. Vérifie la réponse de getCoordinates.');
      }
    } catch (e) {
      debugPrint('Erreur home: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Row(
    mainAxisAlignment: MainAxisAlignment.center, // Centrer le titre
    children: [
      Expanded( // Utiliser Expanded pour que le titre prenne l'espace disponible
        child: Center(
          child: Text(
            'La meteo AC',
            textAlign: TextAlign.center, // Assurer que le texte est centré
          ),
        ),
      ),
    ],
  ),
  actions: [
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0), // Ajouter un espacement horizontal autour des icônes
      child: IconButton(
        icon: Icon(Icons.favorite),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FavoriteScreen(favoriteCities: [])),
          );
        },
      ),
    ),
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 48.0), // Ajouter un espacement horizontal autour des icônes
      child: IconButton(
        icon: Icon(Icons.search),
        onPressed: () async {
          var cityList = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CityScreen(apiService: widget.apiService)),
          );

          // Vérifier si cityList est nul avant d'aller plus loin
          if (cityList == null) {
            debugPrint("⚠️ Aucune ville sélectionnée !");
            return;
          }

          if (cityList is Iterable && cityList.isNotEmpty) {
            var city = cityList.first; // Prendre la première ville

            print("Ville sélectionnée : $city");

            if (city is String && city.isNotEmpty) {
              setState(() {
                selectedCity = city;
              });
              _loadWeatherData();
            }
          } else {
            debugPrint("⚠️ Aucune ville trouvée dans la liste !");
          }
        },
      ),
    ),
  ],
),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          
          currentWeather.iconUrl != null
              ? Uri.parse(currentWeather.iconUrl).isAbsolute
                  ? Image.network(currentWeather.iconUrl)
                  : Container()
              : Container(),
          Text('${currentWeather.temperature}°${isCelsius ? 'C' : 'F'}', style: TextStyle(fontSize: 48)),
          Text(currentWeather.description, style: TextStyle(fontSize: 24)),
          Text(currentWeather.cityName, style: TextStyle(fontSize: 24)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isCelsius = !isCelsius;
                  });
                },
                child: Text('C/F'),
              ),
              IconButton(
                icon: Icon(Icons.location_on),
                onPressed: () async {
                  String city = await GeolocationService().getCurrentLocation();
                  setState(() {
                    selectedCity = city;
                  });
                  _loadWeatherData();
                },
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: currentWeather.forecast.length,
              itemBuilder: (context, index) {
                var forecast = currentWeather.forecast[index];
                return ListTile(
                  title: Text(forecast.time),
                  subtitle: Text('${forecast.temperature}°${isCelsius ? 'C' : 'F'} - ${forecast.condition}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
