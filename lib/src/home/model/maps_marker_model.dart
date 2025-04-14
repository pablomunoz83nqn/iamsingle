import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fluster/fluster.dart';
import 'users_model.dart'; // el modelo de usuario

class MapMarker extends Clusterable {
  final String id;
  final LatLng position;
  final BitmapDescriptor icon;
  final bool isCluster;
  final int? clusterId;
  final int? pointsSize;
  final String? childMarkerId;
  final Users? user; // 👈 esto es nuevo

  MapMarker({
    required this.id,
    required this.position,
    required this.icon,
    this.isCluster = false,
    this.clusterId,
    this.pointsSize,
    this.childMarkerId,
    this.user,
  });

  @override
  double? get latitude => position.latitude;

  @override
  double? get longitude => position.longitude;
}
