class SavedDestination {
  final int? id;
  final String locationName;
  final double latitude;
  final double longitude;

  SavedDestination({
    this.id,
    required this.locationName,
    required this.latitude,
    required this.longitude,
  });

  factory SavedDestination.fromJson(Map<String, dynamic> json) {
    return SavedDestination(
      id: json['id'],
      locationName: json['location_name'],
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location_name': locationName,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
