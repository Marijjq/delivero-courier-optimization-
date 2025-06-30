class AssignedRoute {
  final int id;
  final String title;
  final String status;
  final DateTime assignedAt;
  final DateTime? dueAt;
  final List<Map<String, double>> coordinates;
  

  AssignedRoute({
    required this.id,
    required this.title,
    required this.status,
    required this.assignedAt,
    this.dueAt,
    required this.coordinates,
  });

  factory AssignedRoute.fromJson(Map<String, dynamic> json) {
    return AssignedRoute(
      id: json['id'],
      title: json['title'],
      status: json['status'],
      assignedAt: DateTime.parse(json['assigned_at']),
      dueAt: json['due_at'] != null ? DateTime.parse(json['due_at']) : null,
      coordinates: List<Map<String, double>>.from(
        (json['coordinates'] as List).map(
          (coord) => {
            'lat': (coord['lat'] as num).toDouble(),
            'lon': (coord['lon'] as num).toDouble(),
          },
        ),
      ),
    );
  }
}
