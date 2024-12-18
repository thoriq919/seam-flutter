import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:seam_flutter/screens/utils/color_theme.dart';

class TrackingMapScreen extends StatefulWidget {
  const TrackingMapScreen({super.key});

  @override
  _TrackingMapScreenState createState() => _TrackingMapScreenState();
}

class _TrackingMapScreenState extends State<TrackingMapScreen> {
  final LatLng _destination = LatLng(-7.993182, 111.971276);

  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  String _distance = '';
  String _duration = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _handleLocationError('Location permissions are denied');
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);

        _markers.addAll([
          Marker(
            markerId: MarkerId('current_location'),
            position: _currentLocation!,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: InfoWindow(title: 'My Location'),
          ),
          Marker(
            markerId: MarkerId('destination'),
            position: _destination,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(title: 'Kebun Ayahnya Viga'),
          ),
        ]);

        _fetchRouteFromOpenRouteService();
      });
    } catch (e) {
      _handleLocationError('Error getting location: $e');
    }
  }

  Future<void> _fetchRouteFromOpenRouteService() async {
    const apiKey = '5b3ce3597851110001cf62489d4f17fcc9b64c7597d9a925fd97d540';

    final url = Uri.parse(
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${_currentLocation!.longitude},${_currentLocation!.latitude}&end=${_destination.longitude},${_destination.latitude}');

    try {
      final response = await http.get(url, headers: {
        'Accept':
            'application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8'
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final route = data['features'][0]['geometry']['coordinates'];
        final routePoints =
            route.map<LatLng>((point) => LatLng(point[1], point[0])).toList();

        final summary = data['features'][0]['properties']['summary'];

        setState(() {
          _distance = '${(summary['distance'] / 1000).toStringAsFixed(2)} km';
          _duration = '${(summary['duration'] / 60).toStringAsFixed(0)} mins';

          _polylines.add(Polyline(
            polylineId: PolylineId('route'),
            points: routePoints,
            color: Colors.blue,
            width: 5,
            patterns: [PatternItem.dash(10), PatternItem.gap(10)],
          ));
        });
      } else {
        print('Failed to load route: ${response.body}');
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
  }

  void _handleLocationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );

    setState(() {
      _currentLocation = _destination;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: Container(
          decoration: BoxDecoration(
            color: ColorTheme.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(
              'Maps',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ColorTheme.blackFont),
            ),
            centerTitle: true,
            bottom: _distance.isNotEmpty
                ? PreferredSize(
                    preferredSize: Size.fromHeight(40),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Distance: $_distance | Duration: $_duration',
                        style: TextStyle(
                            color: ColorTheme.blackFont, fontSize: 16),
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),
      body: _currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : Stack(children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentLocation!,
                  zoom: 10,
                ),
                markers: _markers,
                polylines: _polylines,
                mapType: MapType.normal,
                onMapCreated: (controller) {
                  _mapController = controller;
                },
              ),
              Positioned(
                top: 16.0,
                right: 16.0,
                child: FloatingActionButton(
                  backgroundColor: ColorTheme.white,
                  child: Icon(
                    Icons.my_location,
                    color: ColorTheme.blackFont,
                  ),
                  onPressed: () {
                    if (_mapController != null && _currentLocation != null) {
                      _mapController!.animateCamera(
                        CameraUpdate.newLatLngZoom(_currentLocation!, 12),
                      );
                    }
                  },
                ),
              ),
            ]),
    );
  }
}
