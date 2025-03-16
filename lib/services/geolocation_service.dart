import 'package:geolocator/geolocator.dart';

class GeolocationService {
  Future<String> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    // Use position.latitude and position.longitude to get the city name
    return 'Paris';  // Replace with actual logic to get city name from coordinates
  }
}