import 'package:flutter/material.dart';
import 'package:open_street_map/OpenStreetMap/openstreetmap.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const OpenstreetmapScreen(); 
  }
}
