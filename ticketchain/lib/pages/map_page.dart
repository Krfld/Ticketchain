import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsPage extends StatelessWidget {
  final double latitude;
  final double longitude;

  const MapsPage({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 14,
      ),
      markers: {
        Marker(
          markerId: const MarkerId('0'),
          position: LatLng(latitude, longitude),
        ),
      },
    );
  }
}
