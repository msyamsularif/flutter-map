import 'dart:async';

import 'package:example_maps/helper/maps_helper.dart';
import 'package:example_maps/pages/widget/detail_location_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final List<LatLng> _polylineCoordinates = [];
  final List<LatLng> _listAreaLatLng = const [
    LatLng(-6.250171, 107.034765),
    LatLng(-6.250036, 107.034523),
    LatLng(-6.249849, 107.034399),
    LatLng(-6.249622, 107.034458),
    LatLng(-6.249219, 107.034496),
    LatLng(-6.248440, 107.035416),
    LatLng(-6.247481, 107.035368),
    LatLng(-6.246961, 107.035602),
    LatLng(-6.246742, 107.036654),
    LatLng(-6.246792, 107.037672),
    LatLng(-6.249843, 107.036416),
    LatLng(-6.249758, 107.035536),
    LatLng(-6.249818, 107.035057),
  ];

  BitmapDescriptor _markerIconLocation = BitmapDescriptor.defaultMarker;
  BitmapDescriptor _markerIconCourier = BitmapDescriptor.defaultMarker;
  LatLng? _destinationLocation;
  Position? _realTimeLocation;
  String _address = "";
  bool _isInsideArea = true;
  bool _isConfirmLocation = false;

  @override
  void initState() {
    _setCustomMarkerIcon();

    // map will redirect to my current location when loaded
    _determineUserRealtimePosition();

    super.initState();
  }

  /// To get google office marker
  /// this code based on flutter codelabs
  ///
  // final Map<String, Marker> _markers = {};
  // Future<void> _onMapCreated(GoogleMapController controller) async {
  //   final googleOffices = await locations.getGoogleOffices();
  //   setState(() {
  //     _markers.clear();
  //     for (final office in googleOffices.offices) {
  //       final marker = Marker(
  //         markerId: MarkerId(office.name),
  //         position: LatLng(office.lat, office.lng),
  //         infoWindow: InfoWindow(
  //           title: office.name,
  //           snippet: office.address,
  //         ),
  //       );
  //       _markers[office.name] = marker;
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        body: _realTimeLocation == null
            ? Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Loading Map',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 1),
                    )
                  ],
                ),
              )
            : GoogleMap(
                zoomControlsEnabled: false,
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    _realTimeLocation!.latitude,
                    _realTimeLocation!.longitude,
                  ),
                  zoom: 15.6,
                ),
                onMapCreated: (controller) {
                  _controller.complete(controller);
                },
                markers: {
                  if (_isConfirmLocation) ...[
                    Marker(
                      markerId: const MarkerId("desstination"),
                      position: _destinationLocation!,
                      icon: _markerIconLocation,
                    ),
                    Marker(
                      markerId: const MarkerId("realtime-location"),
                      position: LatLng(
                        _realTimeLocation!.latitude,
                        _realTimeLocation!.longitude,
                      ),
                      icon: _markerIconCourier,
                      anchor: const Offset(0.5, 0.5),
                      rotation: _realTimeLocation == null
                          ? 0.0
                          : _realTimeLocation!.heading,
                    ),
                  ] else
                    Marker(
                      markerId: const MarkerId("select-location"),
                      position: () {
                        if (_destinationLocation == null &&
                            !_isConfirmLocation) {
                          return LatLng(
                            _realTimeLocation!.latitude,
                            _realTimeLocation!.longitude,
                          );
                        }

                        return _destinationLocation!;
                      }(),
                      draggable: true,
                      onDragEnd: (position) async {
                        setState(() {
                          _destinationLocation = position;
                        });

                        _getAddress(position);
                      },
                      icon: _markerIconLocation,
                    ),
                },
                polygons: {
                  Polygon(
                    polygonId: const PolygonId("1"),
                    fillColor: ThemeData(useMaterial3: true)
                        .primaryColor
                        .withOpacity(0.1),
                    strokeWidth: 2,
                    points: _listAreaLatLng,
                  ),
                },
                polylines: {
                  Polyline(
                    polylineId: const PolylineId("route"),
                    points: _polylineCoordinates,
                    endCap: Cap.roundCap,
                    startCap: Cap.roundCap,
                    color: ThemeData(useMaterial3: true).primaryColor,
                    width: 4,
                  ),
                },
              ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(
            Icons.my_location_outlined,
          ),
          onPressed: () => _determineUserCurrentPosition(),
        ),
        bottomNavigationBar: DetailLocationWidget(
          isInsideArea: _isInsideArea,
          address: _address,
          isLoading: _realTimeLocation == null,
          onTapCloseBtn: _isInsideArea
              ? () {
                  setState(() {
                    _polylineCoordinates.clear();
                    _isConfirmLocation = false;
                    _destinationLocation = null;
                  });
                }
              : null,
          onTapConfirmBtn: _isInsideArea
              ? () async {
                  _isConfirmLocation = true;

                  await _getDirectionBetwenMarker();
                }
              : null,
        ),
      ),
    );
  }

  void _setCustomMarkerIcon() async {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/images/marker.png")
        .then(
      (icon) {
        _markerIconLocation = icon;
      },
    );

    final Uint8List markerIcon = await MapsHelper.getBytesFromAsset(
      'assets/images/courier.png',
      100,
    );

    _markerIconCourier = BitmapDescriptor.fromBytes(markerIcon);
  }

  // get address from dragged pin
  Future<void> _getAddress(LatLng position) async {
    _isInsideArea = MapsHelper.isCoverageAreaPolygons(
      listLlatLng: _listAreaLatLng,
      latLng: position,
    );

    if (_isInsideArea) {
      _address = await MapsHelper.getAddress(position: position);
    } else {
      _address = 'This area is not accessible for delivery!';
    }

    setState(() {});
  }

  // get user's current location and set the map's camera to that location
  Future<void> _getUserCurrentPosition({double zoomMap = 17.0}) async {
    final Position position = await Geolocator.getCurrentPosition();

    _realTimeLocation = position;

    if (!_isConfirmLocation) {
      _destinationLocation = null;
      await _getAddress(
        LatLng(
          position.latitude,
          position.longitude,
        ),
      );
    }

    setState(() {});

    MapsHelper.animatedMap(
      controller: _controller,
      latLng: LatLng(
        position.latitude,
        position.longitude,
      ),
      zoom: zoomMap,
    );
  }

  // get user's realtime location and set the map's camera to that location
  Future<void> _gotoUserRealTimePosition({double zoomMap = 17.0}) async {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
      ),
    ).listen((realTimePosition) async {
      _realTimeLocation = realTimePosition;

      if (!_isConfirmLocation) {
        await _getAddress(
          LatLng(
            realTimePosition.latitude,
            realTimePosition.longitude,
          ),
        );
      }

      if (_destinationLocation != null) {
        await _getDirectionBetwenMarker();
      }

      MapsHelper.animatedMap(
        controller: _controller,
        latLng: LatLng(
          realTimePosition.latitude,
          realTimePosition.longitude,
        ),
        zoom: _isConfirmLocation ? 20.0 : zoomMap,
      );
    });
  }

  Future<void> _getDirectionBetwenMarker() async {
    _polylineCoordinates.clear();

    final resultListLatLng = await MapsHelper.getDirection(
      originLatitude: _realTimeLocation!.latitude,
      originLongitude: _realTimeLocation!.longitude,
      destinationLatitude: _destinationLocation!.latitude,
      destinationLongitude: _destinationLocation!.longitude,
    );

    _polylineCoordinates.addAll(resultListLatLng);

    setState(() {});
  }

  Future<void> _determineUserCurrentPosition({double zoomMap = 17.0}) async {
    await MapsHelper.determineUserPosition(
      permissonAllowed: () async =>
          await _getUserCurrentPosition(zoomMap: zoomMap),
    );
  }

  Future<void> _determineUserRealtimePosition({double zoomMap = 17.0}) async {
    await MapsHelper.determineUserPosition(
      permissonAllowed: () async =>
          await _gotoUserRealTimePosition(zoomMap: zoomMap),
    );
  }
}
