class City {
  final String name;
  final double? latitude;
  final double? longitude;
  final String state;

  City({required this.name, required this.latitude, required this.longitude, required this.state});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['name'],
      latitude: json['coord']['lat'],
      longitude: json['coord']['lon'],
      state: json['state']
    );
  }
}
