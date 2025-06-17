import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class ChooseLocationScreen extends StatefulWidget {
  const ChooseLocationScreen({Key? key}) : super(key: key);

  @override
  _ChooseLocationScreenState createState() => _ChooseLocationScreenState();
}

class _ChooseLocationScreenState extends State<ChooseLocationScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  Marker? _marker;

  @override
  void initState() {
    super.initState();
    _getPermissionAndLocation();
  }

  Future<void> _getPermissionAndLocation() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final location = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentLocation = location;
        _marker = Marker(
          markerId: const MarkerId('selected_location'),
          position: location,
        );
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _currentLocation = position.target;
      _marker = Marker(
        markerId: const MarkerId('selected_location'),
        position: position.target,
      );
    });
  }

  void _saveLocation() {
    if (_currentLocation != null) {
      Navigator.pop(context, _currentLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Location')),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation!,
                    zoom: 16,
                  ),
                  myLocationEnabled: true,
                  onCameraMove: _onCameraMove,
                  markers: _marker != null ? {_marker!} : {},
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: _saveLocation,
                      child: const Text('Save this location'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
