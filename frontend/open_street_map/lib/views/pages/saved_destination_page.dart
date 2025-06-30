import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '/models/saved_destination_model.dart';
import '/services/saved_destinations_service.dart';
import 'package:open_street_map/OpenStreetMap/openstreetmap.dart';
import 'package:latlong2/latlong.dart';

class SavedDestinationsPage extends StatefulWidget {
  final String token;
  final String baseUrl;

  const SavedDestinationsPage({
    required this.token,
    required this.baseUrl,
    super.key,
  });

  @override
  State<SavedDestinationsPage> createState() => _SavedDestinationsPageState();
}

class _SavedDestinationsPageState extends State<SavedDestinationsPage> {
  late SavedDestinationService _service;
  List<SavedDestination> _destinations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _service = SavedDestinationService(
      baseUrl: widget.baseUrl,
      token: widget.token,
    );
    _loadDestinations();
  }

  Future<void> _loadDestinations() async {
    try {
      final destinations = await _service.fetchSavedDestinations();
      setState(() {
        _destinations = destinations;
        _loading = false;
      });
    } catch (e) {
      print('Failed to load: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _deleteDestination(int id) async {
    try {
      await _service.deleteDestination(id);
      setState(() {
        _destinations.removeWhere((dest) => dest.id == id);
      });
    } catch (e) {
      print('Failed to delete: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('saved.title'.tr())),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _destinations.isEmpty
              ? Center(
                  child: Text(
                    'saved.empty'.tr(),
                    style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                  ),
                )
              : ListView.builder(
                  itemCount: _destinations.length,
                  itemBuilder: (context, index) {
                    final dest = _destinations[index];
                    return ListTile(
                      title: Text(
                        dest.locationName,
                        style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete,
                            color: theme.colorScheme.error),
                        tooltip: 'saved.delete'.tr(),
                        onPressed: () => _deleteDestination(dest.id!),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OpenstreetmapScreen(
                              selectedDestination:
                                  LatLng(dest.latitude, dest.longitude),
                              selectedName: dest.locationName,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
