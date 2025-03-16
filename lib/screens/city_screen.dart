import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/city.dart';

class CityScreen extends StatefulWidget {
  final ApiService apiService;

  const CityScreen({super.key, required this.apiService});

  @override
  _CityScreenState createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  List<City> allCities = [];
  List<String> searchedCities = [];
  bool isLoading = true;  // Initialisez isLoading à true

  @override
  void initState() {
    super.initState();
    debugPrint("initState() appelé !");
    _loadCities();
  }

  _loadCities() async {
    debugPrint("Début du chargement des villes...");
    try {
      // Liste des villes en France
      List<String> citiesInFrance = [
        "Paris", "Marseille", "Lyon", "Toulouse", "Nice", 
        "Nantes", "Strasbourg", "Montpellier", "Bordeaux", "Lille", 
        "Rennes", "Reims", "Le Havre", "Saint-Étienne", "Toulon", 
        "Angers", "Grenoble", "Dijon", "Nîmes", "Aix-en-Provence", 
        "Saint-Denis", "Le Mans", "Amiens", "Clermont-Ferrand", "La Rochelle", 
        "Annecy", "Besançon", "Perpignan", "Orléans", "Brest", "Limoges"
      ];

      // Variable pour stocker les données des villes
      List<dynamic> citiesData = [];

      // Utilisation de forEach pour récupérer les données de chaque ville
      await Future.forEach(citiesInFrance, (city) async {
        final cityData = await widget.apiService.getAllCities(city); // Récupérer les données pour chaque ville
        debugPrint("sortie getAllCities: $cityData");
        // Vérifier si cityData contient un champ 'name' valide
        if (cityData != null && cityData.containsKey('name')) {
          final name = cityData['name']; // Extraire le nom de la ville
          debugPrint("juste le nom : $name");
          if (name != null) {
            debugPrint("ça passe dans le if");
            citiesData.add(cityData); // Ajouter cityData dans la liste citiesData
            debugPrint("Données récupérées : $cityData");
          }
        }
      });

      if (citiesData.isEmpty) {
        debugPrint("Aucune ville trouvée.");
      } else {
        debugPrint("Villes récupérées : ${citiesData.map((city) => city['name']).toList()}");
      }

      // Finaliser le changement d'état pour l'affichage
      setState(() {
        isLoading = false;
        // Convertir citiesData (liste dynamique) en une liste de City
        debugPrint("avant utilisation map : $citiesData");
        allCities = citiesData.map((city) => City.fromJson(city)).toList();
      });
      debugPrint("Chargement terminé, isLoading = $isLoading");

    } catch (e) {
      debugPrint("Erreur lors du chargement des villes: $e");
    }
  }

  void searchCity(String query) {
    setState(() {
      searchedCities = allCities
          .where((city) => city.name.toLowerCase().contains(query.toLowerCase()))
          .map((city) => city.name)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recherche de ville'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              // Afficher un champ de recherche
              String? query = await showSearch(
                context: context,
                delegate: CitySearchDelegate(allCities),
              );
              if (query != null && query.isNotEmpty) {
                searchCity(query); // Rechercher la ville en fonction de la requête
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())  // Afficher un indicateur de chargement pendant le chargement des données
          : allCities.isEmpty
              ? Center(child: Text('Aucune ville trouvée.'))  // Afficher un message si aucune ville n'est trouvée après le chargement
              : ListView.builder(
                  itemCount: searchedCities.isEmpty ? allCities.length : searchedCities.length,
                  itemBuilder: (context, index) {
                    final city = searchedCities.isEmpty ? allCities[index] : allCities.firstWhere((c) => c.name == searchedCities[index]);
                    return ListTile(
                      title: Text(city.name),
                      onTap: () {
                        Navigator.pop(context, city.name); // Retourner la ville sélectionnée
                      },
                    );
                  },
                ),
    );
  }
}

class CitySearchDelegate extends SearchDelegate<String> {
  final List<City> cities;

  CitySearchDelegate(this.cities);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';  // Réinitialiser la recherche
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');  // Fermer la recherche
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = cities
        .where((city) => city.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    
    return ListView(
      children: results.map((city) {
        return ListTile(
          title: Text(city.name),
          onTap: () {
            close(context, city.name);  // Retourner le nom de la ville
          },
        );
      }).toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = cities
        .where((city) => city.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView(
      children: suggestions.map((city) {
        return ListTile(
          title: Text(city.name),
          onTap: () {
            query = city.name;  // Mettre à jour la recherche avec la ville sélectionnée
            showResults(context);  // Afficher les résultats
          },
        );
      }).toList(),
    );
  }
}
