import 'package:flutter/material.dart';
import '/models/assigned_route_model.dart';
import '/services/assigned_route_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_street_map/OpenStreetMap/openstreetmap.dart';
import 'package:easy_localization/easy_localization.dart';

class AssignedRoutesPage extends StatefulWidget {
  final AssignedRouteService assignedRouteService;

  const AssignedRoutesPage({super.key, required this.assignedRouteService});

  @override
  State<AssignedRoutesPage> createState() => _AssignedRoutesPageState();
}

class _AssignedRoutesPageState extends State<AssignedRoutesPage> {
  late Future<List<AssignedRoute>> _assignedRoutesFuture;

  @override
  void initState() {
    super.initState();
    _assignedRoutesFuture = widget.assignedRouteService.fetchAssignedRoutes();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('assigned.title'.tr()),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<AssignedRoute>>(
        future: _assignedRoutesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'assigned.error'.tr(args: [snapshot.error.toString()]),
                style: TextStyle(color: theme.colorScheme.error),
              ),
            );
          }

          final assignedRoutes = snapshot.data ?? [];

          if (assignedRoutes.isEmpty) {
            return Center(child: Text('assigned.none'.tr()));
          }

          return ListView.builder(
            itemCount: assignedRoutes.length,
            itemBuilder: (context, index) {
              final route = assignedRoutes[index];
              return ListTile(
                title: Text(route.title),
                subtitle: Text(
                  '${'assigned.status'.tr()}: ${route.status}\n'
                  '${'assigned.due'.tr()}: ${route.dueAt?.toLocal().toString().split(" ").first ?? "N/A"}',
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  final coords = route.coordinates;
                  if (coords.isEmpty) return;

                  final lastCoord = coords.last;
                  final destination = LatLng(
                    lastCoord['lat']!,
                    lastCoord['lon']!,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OpenstreetmapScreen(
                        selectedDestination: destination,
                        selectedName: route.title,
                        onArrived: () async {
                          await widget.assignedRouteService
                              .markAsFinished(route.id);

                          setState(() {
                            _assignedRoutesFuture = widget
                                .assignedRouteService
                                .fetchAssignedRoutes();
                          });
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
