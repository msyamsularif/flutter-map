import 'dart:async';
import 'dart:ui' as ui;

import 'package:example_maps/helper/constant_name_helper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsHelper {
  MapsHelper._();

  static Future<GoogleMapController> mapController({
    required Completer<GoogleMapController> controller,
  }) =>
      controller.future;

  static void animatedMap({
    required Completer<GoogleMapController> controller,
    required LatLng latLng,
    double zoom = 17.0,
  }) async {
    final mapCtrl = await mapController(controller: controller);

    mapCtrl.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: latLng,
          zoom: zoom,
        ),
      ),
    );
  }

  ///Use the ray casting algorithm to determine if points are inside polygons
  static bool isCoverageAreaPolygons({
    required List<LatLng> listLlatLng,
    required LatLng latLng,
  }) {
    int crossings = 0;

    for (int i = 0; i < listLlatLng.length; i++) {
      LatLng vertex1 = listLlatLng[i];
      LatLng vertex2 = listLlatLng[(i + 1) % listLlatLng.length];
      if (vertex1.latitude == vertex2.latitude &&
          vertex1.longitude == vertex2.longitude) {
        continue;
      }
      if (latLng.latitude < vertex1.latitude &&
          latLng.latitude < vertex2.latitude) {
        continue;
      }
      if (latLng.latitude >= vertex1.latitude &&
          latLng.latitude >= vertex2.latitude) {
        continue;
      }
      double x = (latLng.latitude - vertex1.latitude) *
              (vertex2.longitude - vertex1.longitude) /
              (vertex2.latitude - vertex1.latitude) +
          vertex1.longitude;

      if (x > latLng.longitude) {
        crossings++;
      }
    }

    return crossings % 2 == 1;
  }

  static Future<String> getAddress({required LatLng position}) async {
    //this will list down all address around the position
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark address = placemarks[0]; //get only first and closest address

    String addresStr =
        "${address.street}, ${address.locality}, ${address.administrativeArea}, ${address.country}";

    return addresStr;
  }

  static Future<List<LatLng>> getDirection({
    required double originLatitude,
    required double originLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
    TravelMode travelMode = TravelMode.driving,
  }) async {
    List<LatLng> listLatLng = [];
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      ConstantNameHelper.mapKey(), // Add API Key Map
      PointLatLng(originLatitude, originLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: travelMode,
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        listLatLng.add(
          LatLng(point.latitude, point.longitude),
        );
      }
    }

    return listLatLng;
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  static Future<void> determineUserPosition({
    required Function permissonAllowed,
  }) async {
    LocationPermission locationPermission;
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    //check if user enable service for location permission
    if (!isLocationServiceEnabled) {
      return Future.error('Location services are disabled.');
    }

    locationPermission = await Geolocator.checkPermission();

    //check if user denied location and retry requesting for permission
    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    //check if user denied permission forever
    if (locationPermission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    await permissonAllowed();
  }
}
