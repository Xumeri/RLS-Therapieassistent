import 'package:flutter/material.dart';

/// A screen for displaying sensor measurement data.
///
/// This is currently a placeholder for future sensor integration features.
class SensorScreen extends StatelessWidget {
  /// The title of the screen.
  final String title = "Sensordaten";

  const SensorScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: const Center(
        child: Text("Screen für die Sensor-Messwerte", style: TextStyle(fontSize: 20),)
      ),
    );
  }
}
