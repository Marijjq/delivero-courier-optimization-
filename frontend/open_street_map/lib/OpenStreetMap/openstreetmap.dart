import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:open_street_map/utils/token_storage.dart';
import 'package:easy_localization/easy_localization.dart';
import 'multi_stop_routing.dart';

class OpenstreetmapScreen extends StatefulWidget {
  final LatLng? selectedDestination;
  final String? selectedName;
  final VoidCallback? onArrived;


  const OpenstreetmapScreen({
    this.selectedDestination,
    this.selectedName,
        this.onArrived,
    super.key,
  });

  @override
  State<OpenstreetmapScreen> createState() => _OpenstreetmapScreenState();
}

class _OpenstreetmapScreenState extends State<OpenstreetmapScreen> {
  final MapController _mapController = MapController();
  final Location _location = Location();
  final TextEditingController _locationController = TextEditingController();
  bool isLoading = true;
  LatLng? _currentLocation;
  LatLng? _destination;
  List<LatLng> _route = [];
  bool _hasArrived = false;
  bool _isSatelliteView = false;
  

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    if (!await _checktheRequestPermissions()) return;

    _location.onLocationChanged.listen((LocationData locationData) {
      final current = LatLng(locationData.latitude!, locationData.longitude!);
      setState(() {
        _currentLocation = current;
        isLoading = false;
      });

      if (widget.selectedDestination != null) {
        setState(() {
          _destination = widget.selectedDestination!;
          _locationController.text = widget.selectedName ?? '';
        });
        _mapController.move(widget.selectedDestination!, 16);
        _fetchRoute();
      }
    });
  }

  Future<List<dynamic>> _getSuggestions(String pattern) async {
    if (pattern.isEmpty) return [];

    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search?q=$pattern&format=json&addressdetails=1&limit=5",
    );

    final response = await http.get(
      url,
      headers: {
        'User-Agent': 'open_street_map_app/1.0 (stojkovskamarija72@gmail.com)',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return [];
    }
  }

  Future<void> _fetchRoute() async {
    if (_currentLocation == null || _destination == null) return;

    final url = Uri.parse(
      "https://router.project-osrm.org/route/v1/driving/"
      '${_currentLocation!.longitude},${_currentLocation!.latitude};'
      '${_destination!.longitude},${_destination!.latitude}?overview=full&geometries=polyline',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final geometry = data['routes'][0]['geometry'];
        _decodePolyline(geometry);
      } else {
        errorMessage(tr('route_fetch_failed'));
      }
    } catch (e) {
      errorMessage(tr('route_fetch_error'));
    }
  }

  Future<bool> _checktheRequestPermissions() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return false;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return false;
    }

    return true;
  }

  Future<void> _userCurrentLocation() async {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15);
    } else {
      errorMessage(tr('current_location_unavailable'));
    }
  }

  void errorMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _decodePolyline(String encodedPolyline) {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodePoints = polylinePoints.decodePolyline(
      encodedPolyline,
    );

    setState(() {
      _route =
          decodePoints.map((p) => LatLng(p.latitude, p.longitude)).toList();
    });
  }

void _checkArrival(LatLng current) async {
  if (_destination == null || _hasArrived) return;

  final distance = Distance().as(LengthUnit.Meter, current, _destination!);
  if (distance < 20) {
    _hasArrived = true;
    errorMessage(tr('arrival_message'));

    final token = await TokenStorage.getToken();
    if (token == null || _currentLocation == null) return;

    final url = Uri.parse(
      "https://router.project-osrm.org/route/v1/driving/"
      "${_currentLocation!.longitude},${_currentLocation!.latitude};"
      "${_destination!.longitude},${_destination!.latitude}?overview=false",
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final distance = data['routes'][0]['distance'];
      final duration = data['routes'][0]['duration'];

      await http.post(
        Uri.parse("http://192.168.1.5:8888/api/route-history"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'start_latitude': _currentLocation!.latitude,
          'start_longitude': _currentLocation!.longitude,
          'end_latitude': _destination!.latitude,
          'end_longitude': _destination!.longitude,
          'distance': distance,
          'duration': duration.round(),
        }),
      );
    }

    // ✅ Notify parent widget
    if (widget.onArrived != null) {
      widget.onArrived!();
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar:
          widget.selectedName != null
              ? AppBar(
                title: Text(widget.selectedName!),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              )
              : null,
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentLocation ?? const LatLng(0, 0),
                  initialZoom: 2,
                  minZoom: 0,
                  maxZoom: 100,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        _isSatelliteView
                            ? 'https://api.maptiler.com/tiles/satellite/{z}/{x}/{y}.jpg?key=hjTRq4TsvxIwEP3bOkz6'
                            : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.delivero',
                    tileProvider: NetworkTileProvider(), // ✅ No caching
                  ),

                  CurrentLocationLayer(
                    style: LocationMarkerStyle(
                      marker: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.my_location,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      markerSize: const Size(35, 35),
                      markerDirection: MarkerDirection.heading,
                    ),
                  ),
                  if (_destination != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _destination!,
                          width: 50,
                          height: 50,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  if (_currentLocation != null &&
                      _destination != null &&
                      _route.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _route,
                          color: theme.colorScheme.primary,
                          strokeWidth: 4,
                        ),
                      ],
                    ),
                ],
              ),
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TypeAheadField<dynamic>(
                controller: _locationController,
                suggestionsCallback: _getSuggestions,
                itemBuilder: (context, dynamic suggestion) {
                  return ListTile(title: Text(suggestion['display_name']));
                },
                onSelected: (dynamic suggestion) async {
                  final lat = double.parse(suggestion['lat']);
                  final lon = double.parse(suggestion['lon']);
                  final selected = LatLng(lat, lon);
                  final displayName = suggestion['display_name'];

                  final shouldSave = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text(tr("save_destination_title")),
                          content: Text(
                            tr("save_destination_message", args: [displayName]),
                          ),
                          actions: [
                            TextButton(
                              child: Text(tr("no")),
                              onPressed: () => Navigator.pop(context, false),
                            ),
                            TextButton(
                              child: Text(tr("yes")),
                              onPressed: () => Navigator.pop(context, true),
                            ),
                          ],
                        ),
                  );

                  setState(() {
                    _locationController.text = displayName;
                    _destination = selected;
                  });

                  if (shouldSave == true) {
                    final token = await TokenStorage.getToken();

                    if (token == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(tr("auth_token_missing"))),
                      );
                      return;
                    }

                    try {
                      final response = await http.post(
                        Uri.parse(
                          "http://192.168.1.5:8888/api/saved-destinations",
                        ),
                        headers: {
                          'Authorization': 'Bearer $token',
                          'Content-Type': 'application/json',
                        },
                        body: json.encode({
                          'location_name': displayName,
                          'latitude': lat,
                          'longitude': lon,
                        }),
                      );

                      if (response.statusCode == 201) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(tr("destination_saved"))),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              tr(
                                "destination_save_failed",
                                args: [response.statusCode.toString()],
                              ),
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            tr("destination_save_error", args: [e.toString()]),
                          ),
                        ),
                      );
                    }
                  }

                  _mapController.move(selected, 16);
                },
                builder: (context, controller, focusNode) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: tr("enter_location_hint"),
                      hintStyle: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          controller.clear();
                          setState(() {
                            _destination = null;
                            _route.clear();
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              elevation: 0,
              onPressed: _userCurrentLocation,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.my_location,
                size: 30,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          Positioned(
            bottom: 90,
            right: 20,
            child: FloatingActionButton(
              onPressed: () async {
                if (_destination == null) {
                  errorMessage(tr("select_destination_first"));
                  return;
                }
                _hasArrived = false;
                if (_currentLocation != null) {
                  _mapController.move(_currentLocation!, 17);
                }

                await _fetchRoute();

                _location.onLocationChanged.listen((locationData) {
                  final newLocation = LatLng(
                    locationData.latitude!,
                    locationData.longitude!,
                  );
                  setState(() {
                    _currentLocation = newLocation;
                  });

                  _mapController.move(newLocation, _mapController.camera.zoom);
                  _checkArrival(newLocation);
                });
              },
              backgroundColor: Colors.white,
              child: Icon(Icons.navigation, color: theme.colorScheme.primary),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MultiStopRouting()),
                );
              },
              icon: const Icon(Icons.alt_route),
              label: const Text('Multi Stop'),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
          Positioned(
            top: 80,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'toggleView',
              backgroundColor: Colors.white,
              onPressed: () {
                setState(() {
                  _isSatelliteView = !_isSatelliteView;
                });
              },
              child: Icon(
                _isSatelliteView ? Icons.map : Icons.satellite_alt,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
