import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:open_street_map/data/notifiers.dart';
import 'package:open_street_map/models/route_history_model.dart';
import 'package:open_street_map/services/route_service.dart';
import 'package:open_street_map/utils/token_storage.dart';
import 'route_preview_page.dart'; 

class RouteHistoryPage extends StatefulWidget {
  const RouteHistoryPage({super.key});

  @override
  State<RouteHistoryPage> createState() => _RouteHistoryPageState();
}

class _RouteHistoryPageState extends State<RouteHistoryPage> {
  late Future<List<RouteHistory>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadRouteHistory();
  }

  Future<List<RouteHistory>> _loadRouteHistory() async {
    final token = await TokenStorage.getToken();
    if (token == null) throw Exception('No token found');

    return await RouteService.fetchRouteHistory(
      token,
      'http://192.168.1.5:8888',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("route_history.title".tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => selectedPageNotifier.value = 0,
        ),
      ),
      body: FutureBuilder<List<RouteHistory>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                tr('route_history.error'),
                style: TextStyle(color: theme.colorScheme.error),
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return Center(child: Text('route_history.empty'.tr()));
          }

          final routes = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _historyFuture = _loadRouteHistory();
              });
            },
            child: ListView.builder(
              itemCount: routes.length,
              itemBuilder: (context, index) {
                final route = routes[index];
                return ListTile(
                  leading: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.circle, size: 10, color: Colors.green),
                      Icon(Icons.arrow_downward, size: 16, color: Colors.grey),
                      Icon(Icons.location_pin, size: 20, color: Colors.red),
                    ],
                  ),
                  title: Text('${route.startLocationName} → ${route.endLocationName}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${(route.distance / 1000).toStringAsFixed(2)} km • '
                        '${Duration(seconds: route.duration).inMinutes} min',
                      ),
                      Text(
                        DateFormat.yMMMd().add_Hm().format(route.completedAt),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Route?'),
                          content: const Text('Are you sure you want to delete this route?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        final token = await TokenStorage.getToken();
                        try {
                          await RouteService.deleteRouteHistory(
                            route.id,
                            'http://192.168.1.5:8888',
                            token,
                          );
                          setState(() => _historyFuture = _loadRouteHistory());
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to delete route.')),
                          );
                        }
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RoutePreviewPage(route: route),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
