import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../utils/token_storage.dart';
import '../../services/route_service.dart';

class MultiStopRouting extends StatefulWidget {
  const MultiStopRouting({super.key});

  @override
  State<MultiStopRouting> createState() => _MultiStopRoutingState();
}

class _MultiStopRoutingState extends State<MultiStopRouting> {
  final MapController _mapController = MapController();
  List<LatLng> _stops = [];
  List<LatLng> _routePoints = [];
  double _routeDistance = 0;
  int _routeDuration = 0;

  StreamSubscription<Position>? _positionStream;
  bool _hasSavedRoute = false;

  void _addStop(LatLng latLng) {
    setState(() => _stops.add(latLng));
  }

  void _removeStop(int index) {
    setState(() => _stops.removeAt(index));
  }

  void _clearStops() {
    setState(() {
      _stops.clear();
      _routePoints.clear();
    });
    _positionStream?.cancel();
    _hasSavedRoute = false;
  }

  Future<void> _getOptimizedRoute() async {
    if (_stops.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('multi_stop.add_more'.tr())),
      );
      return;
    }

    final coordinates =
        _stops.map((e) => "${e.longitude},${e.latitude}").join(';');
    final url = Uri.parse(
      'https://router.project-osrm.org/trip/v1/driving/$coordinates?roundtrip=true&source=first&destination=last&overview=full&geometries=polyline',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final geometry = data['trips'][0]['geometry'];
        _routeDistance = data['trips'][0]['distance'];
        _routeDuration = (data['trips'][0]['duration']).round();

        final points = PolylinePoints().decodePolyline(geometry);
        setState(() {
          _routePoints =
              points.map((p) => LatLng(p.latitude, p.longitude)).toList();
        });

        _startTrackingArrival();
      } else {
        throw Exception('Failed to get optimized route.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('multi_stop.error', args: [e.toString()]))),
      );
    }
  }

  void _startTrackingArrival() {
    _positionStream?.cancel();
    _hasSavedRoute = false;

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) async {
      if (_stops.isEmpty || _routePoints.isEmpty || _hasSavedRoute) return;

      final destination = _stops.last;
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        destination.latitude,
        destination.longitude,
      );

      if (distance < 50) {
        _hasSavedRoute = true;
        _positionStream?.cancel();

        final token = await TokenStorage.getToken();
        if (token == null) return;

        final start = _stops.first;
        final end = _stops.last;

        final success = await RouteService.saveRouteHistory(
          token: token,
          startLat: start.latitude,
          startLng: start.longitude,
          endLat: end.latitude,
          endLng: end.longitude,
          distance: _routeDistance,
          duration: _routeDuration,
          baseUrl: 'http://192.168.1.5:8888',
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("multi_stop.auto_saved".tr())),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('multi_stop.title'.tr())),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(42.0087, 20.9716),
              initialZoom: 13,
              onTap: (tapPosition, latLng) => _addStop(latLng),
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.open_street_map',
              ),
              MarkerLayer(
                markers: _stops
                    .map(
                      (point) => Marker(
                        point: point,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 35,
                        ),
                      ),
                    )
                    .toList(),
              ),
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: Colors.blue,
                      strokeWidth: 4,
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _getOptimizedRoute,
                  child: Text('multi_stop.optimize'.tr()),
                ),
                ElevatedButton(
                  onPressed: _clearStops,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: Text('multi_stop.clear'.tr()),
                ),
              ],
            ),
          ),
          if (_stops.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'multi_stop.selected_stops'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ..._stops.asMap().entries.map(
                          (entry) => ListTile(
                            dense: true,
                            title: Text(
                              'Lat: ${entry.value.latitude}, Lng: ${entry.value.longitude}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => _removeStop(entry.key),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
