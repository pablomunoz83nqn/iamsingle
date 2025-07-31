import 'package:fluster/fluster.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loveradar/src/home/model/users_model.dart';

class MapMarker extends Clusterable {
  final String id;
  final LatLng position;
  final BitmapDescriptor icon;
  final Users? user;

  final bool isCluster;
  final int? clusterId;
  final int? pointsSize;
  final String? childMarkerId;

  MapMarker({
    required this.id,
    required this.position,
    this.icon = BitmapDescriptor.defaultMarker,
    this.user,
    this.isCluster = false,
    this.clusterId,
    this.pointsSize,
    this.childMarkerId,
  });

  @override
  double get latitude => position.latitude;

  @override
  double get longitude => position.longitude;
}
