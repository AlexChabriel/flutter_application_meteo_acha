import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialisation de ApiService
  final apiService = ApiService();

  runApp(MyApp(apiService: apiService));
}

class MyApp extends StatelessWidget {
  final ApiService apiService;

  const MyApp({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Météo AC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(apiService: apiService),
    );
  }
}