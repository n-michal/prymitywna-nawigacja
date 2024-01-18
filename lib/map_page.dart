import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:sensors_plus/sensors_plus.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  static const routeName = '/map-page';

  @override
  State<MapPage> createState() => _HomePageState();
}

class _HomePageState extends State<MapPage> {
  late List<Marker> _markers;
  Polyline _polyline = Polyline(
    points: [],
  );
  final _movementSubscriptions = <StreamSubscription<dynamic>>[];
  final StreamController<LocationMarkerPosition> _positionStreamController =
      StreamController();
  late final Stream<LocationMarkerHeading> _compassStream;
  double _startingLat = 50.160750;
  double _startingLng = 18.313110;
  double _bearingRad = 0;
  late LocationMarkerPosition _previousLocation;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _compassStream = FlutterCompass.events!.map((event) {
      // FlutterCompass gives N = 0, S = 180 or -180, E = 90, W = -90
      // so we have to convert to 0 - 360 rising clockwise with N = 0
      var bearing = event.heading!;

      if (bearing < 0) {
        bearing = 360 + bearing;
      }

      _bearingRad = degToRadian(bearing);

      return LocationMarkerHeading(
        heading: _bearingRad,
        accuracy: event.accuracy!,
      );
    });

    _previousLocation = LocationMarkerPosition(
      latitude: _startingLat,
      longitude: _startingLng,
      accuracy: 0,
    );

    _positionStreamController.add(_previousLocation);

    _movementSubscriptions
      ..add(
        gyroscopeEventStream().listen(
          (event) {
            if (!_isNavigating) return;
            if (event.x > 2 || event.y > 2 || event.z > 2) {
              // Only consider significant accelerations
              _updateLocation();
            }
          },
          onError: (e) {
            showDialog<AlertDialog>(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  title: Text('Sensor Not Found'),
                  content: Text(
                    'Urzadzenie nie wspiera zyroskopu',
                  ),
                );
              },
            );
          },
          cancelOnError: true,
        ),
      )
      ..add(
        userAccelerometerEventStream().listen(
          (accelerometerEvent) {
            if (!_isNavigating) return;
            // Ignoring sideways motion to avoid moving
            // when the user is only turning
            if (accelerometerEvent.y > 1 || accelerometerEvent.z > 1) {
              _updateLocation();
            }
          },
          onError: (e) {
            showDialog<AlertDialog>(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  title: Text('Sensor Not Found'),
                  content: Text(
                    'Urzadzenie nie wspiera akcelerometru',
                  ),
                );
              },
            );
          },
          cancelOnError: true,
        ),
      );

    _markers = [
      Marker(
        point: LatLng(_startingLat, _startingLng),
        child: const SizedBox.shrink(),
      ),
    ];
  }

  @override
  void dispose() {
    for (final subscription in _movementSubscriptions) {
      subscription.cancel();
    }
    _positionStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prymitywna nawigacja'),
        actions: [
          IconButton(
            onPressed: _isNavigating || _markers.length < 2
                ? () {}
                : () {
                    setState(() {
                      _markers.removeLast();
                      _polyline.points.removeLast();
                    });
                  },
            icon: const Icon(Icons.undo),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(_startingLat, _startingLng),
                initialZoom: 12,
                onTap: (_, point) {
                  if (!_isNavigating && _markers.length < 21) {
                    setState(() {
                      _markers.add(
                        Marker(
                          point: point,
                          child: const Icon(Icons.place),
                        ),
                      );
                      _polyline = Polyline(
                        points: [..._markers.map((e) => e.point)],
                        color: Colors.grey,
                        strokeWidth: 5,
                      );
                    });
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                CurrentLocationLayer(
                  alignPositionOnUpdate: AlignOnUpdate.always,
                  style: const LocationMarkerStyle(
                    marker: Icon(Icons.arrow_upward),
                    showHeadingSector: false,
                    markerDirection: MarkerDirection.heading,
                  ),
                  positionStream: _positionStreamController.stream,
                  headingStream: _compassStream,
                ),
                MarkerLayer(markers: _markers),
                PolylineLayer(polylines: [_polyline]),
                const RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      'OpenStreetMap contributors',
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _isNavigating = !_isNavigating;
                if (_isNavigating) return;
                _startingLat = _previousLocation.latitude;
                _startingLng = _previousLocation.longitude;
                _markers = [
                  Marker(
                    point: LatLng(_startingLat, _startingLng),
                    child: const SizedBox.shrink(),
                  ),
                ];
                _polyline = Polyline(
                  points: [],
                );
              });
            },
            child: _isNavigating
                ? Container(
                    height: 70,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                    ),
                    child: const Center(
                      child: Text(
                        'Zatrzymaj Nawigacje',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : Container(
                    height: 70,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.lightBlueAccent,
                    ),
                    child: const Center(
                      child: Text(
                        'Start Nawigacji',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  LocationMarkerPosition _getNewPosition({
    required LocationMarkerPosition currentPosition,
    required double distanceDeg,
    required double bearing,
  }) {
    final currentLat = degToRadian(currentPosition.latitude);
    final currentLng = degToRadian(currentPosition.longitude);
    final distanceRad = degToRadian(distanceDeg);
    final newLat = asin(
      sin(currentLat) * cos(distanceRad) +
          cos(currentLat) * sin(distanceRad) * cos(bearing),
    );
    final newLng = currentLng +
        atan2(
          sin(bearing) * sin(distanceRad) * cos(currentLat),
          cos(distanceRad) - sin(currentLat) * sin(newLat),
        );

    return LocationMarkerPosition(
      latitude: radianToDeg(newLat),
      longitude: radianToDeg(newLng),
      accuracy: 0,
    );
  }

  void _updateLocation() {
    final newLocation = _getNewPosition(
      currentPosition: _previousLocation,
      distanceDeg: 0.001,
      bearing: _bearingRad,
    );
    _positionStreamController.add(newLocation);

    _previousLocation = newLocation;
  }
}
