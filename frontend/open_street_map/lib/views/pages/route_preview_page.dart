import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:easy_localization/easy_localization.dart';
import '/models/route_history_model.dart';

class RoutePreviewPage extends StatelessWidget {
  final RouteHistory route;

  const RoutePreviewPage({super.key, required this.route});

  List<LatLng> decodeGeoJsonPath(String? geoJson) {
    if (geoJson == null) return [];

    try {
      final decoded = json.decode(geoJson);
      if (decoded is Map &&
          decoded['type'] == 'LineString' &&
          decoded['coordinates'] is List) {
        return (decoded['coordinates'] as List)
            .map((pair) => LatLng(pair[1], pair[0])) // [lon, lat]
            .toList();
      }
    } catch (_) {}

    return [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pathPoints = decodeGeoJsonPath(route.path);
    final start = pathPoints.isNotEmpty ? pathPoints.first : null;
    final end = pathPoints.isNotEmpty ? pathPoints.last : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('route_preview.title'.tr()),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: start ?? const LatLng(42.0087, 20.9716),
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.open_street_map',
          ),
          if (start != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: start,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.flag, color: Colors.green, size: 36),
                ),
                Marker(
                  point: end!,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_pin, color: Colors.red, size: 36),
                ),
              ],
            ),
          if (pathPoints.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: pathPoints,
                  color: theme.colorScheme.primary,
                  strokeWidth: 4,
                ),
              ],
            ),
        ],
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${route.startLocationName} → ${route.endLocationName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '${(route.distance / 1000).toStringAsFixed(2)} km • '
              '${Duration(seconds: route.duration).inMinutes} min',
            ),
            Text(
              tr('route_preview.completed', args: [route.completedAt.toLocal().toString()]),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
