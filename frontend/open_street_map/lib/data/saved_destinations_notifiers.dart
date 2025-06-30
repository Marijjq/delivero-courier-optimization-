import 'package:flutter/foundation.dart';
import 'destination_storage.dart';

final SavedDestinationNotifier savedDestinationNotifier = SavedDestinationNotifier();

class SavedDestinationNotifier extends ChangeNotifier {
  List<Map<String, dynamic>> destinations = [];

  SavedDestinationNotifier() {
    load();
  }

  void add(Map<String, dynamic> destination) {
    destinations.add(destination);
    DestinationStorage.saveDestinations(destinations);
    notifyListeners();
  }

  Future<void> load() async {
    destinations = await DestinationStorage.loadDestinations();
    notifyListeners();
  }
}
