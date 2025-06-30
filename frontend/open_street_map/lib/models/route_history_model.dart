// models/route_history_model.dart
class RouteHistory {
  final int id;
  final String startLocationName;
  final String endLocationName;
  final double distance;
  final int duration;
  final DateTime completedAt;
  final String? path;

  RouteHistory({
    required this.id,
    required this.startLocationName,
    required this.endLocationName,
    required this.distance,
    required this.duration,
    required this.completedAt,
    this.path,
  });

  factory RouteHistory.fromJson(Map<String, dynamic> json) {
    return RouteHistory(
      id: json['id'],
      startLocationName: json['start_location_name'] ?? 'Start',
      endLocationName: json['end_location_name'] ?? 'End',
      distance: (json['distance'] as num).toDouble(),
      duration: json['duration'] ?? 0,
      completedAt: DateTime.parse(json['completed_at']),
      path: json['path'],
    );
  }
}
