// helpers/maps_helper.dart
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../model/maps_marker_model.dart';

class MapHelper {
  static Future<Fluster<MapMarker>> initClusterManager(
    List<MapMarker> markers,
    int minZoom,
    int maxZoom,
  ) async {
    final clusterManager = Fluster<MapMarker>(
      minZoom: minZoom,
      maxZoom: maxZoom,
      radius: 150,
      extent: 2048,
      nodeSize: 64,
      points: markers,
      createCluster: (BaseCluster? cluster, double? lng, double? lat) {
        return MapMarker(
          id: (cluster?.id?.toString() ??
              DateTime.now().millisecondsSinceEpoch.toString()),
          position: LatLng(lat ?? 0, lng ?? 0),
          isCluster: true,
          pointsSize: cluster?.pointsSize ?? 2,
          childMarkerId: cluster?.childMarkerId,
        );
      },
    );

    return clusterManager;
  }

  // Icono para los clusters
  static Future<BitmapDescriptor> getClusterIcon(
    int count,
    Color color,
    Color textColor,
    double size,
  ) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Paint paint = Paint()..color = color;

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: count.toString(),
        style: TextStyle(
          fontSize: size / 2.5,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      ),
    );

    final image =
        await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }
}
