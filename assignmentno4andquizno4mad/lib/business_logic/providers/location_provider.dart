import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;

class LocationProvider extends ChangeNotifier {
  Position? _currentPosition;
  String _address = 'Fetching address...';
  bool _isLoading = false;
  String? _error;
  bool _isOnline = true;

  // Getters
  Position? get currentPosition => _currentPosition;
  String get address => _address;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOnline => _isOnline;

  /// Get current location with address lookup
  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error = 'Location services are disabled. Please enable them.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Permission permanently denied
      if (permission == LocationPermission.deniedForever) {
        _error = 'Location permission denied permanently. Enable in app settings.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Get address from coordinates
      if (_currentPosition != null) {
        await _getAddressFromCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
      }

      _error = null;
      _isOnline = true;
    } catch (e) {
      _error = 'Error getting location: $e';
      _isOnline = false;
      print('Location error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Get human-readable address from coordinates
  Future<void> _getAddressFromCoordinates(double lat, double lon) async {
    try {
      final placemarks = await geo.placemarkFromCoordinates(lat, lon);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        _address =
        '${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}';
      } else {
        _address = '$lat, $lon';
      }
    } catch (e) {
      print('Geocoding error: $e');
      _address = '$lat, $lon';
    }
  }

  /// Get continuous location updates
  Stream<Position> getLocationUpdates() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  /// Watch location updates and update provider
  Future<void> watchLocation() async {
    getLocationUpdates().listen((Position position) {
      _currentPosition = position;
      _getAddressFromCoordinates(position.latitude, position.longitude);
      notifyListeners();
    }, onError: (error) {
      _error = 'Error tracking location: $error';
      notifyListeners();
    });
  }

  /// Get distance between two coordinates
  Future<double> getDistanceBetween(
      double startLat,
      double startLon,
      double endLat,
      double endLon,
      ) async {
    return await Geolocator.distanceBetween(
      startLat,
      startLon,
      endLat,
      endLon,
    );
  }

  /// Get bearing between two coordinates
  Future<double> getBearing(
      double startLat,
      double startLon,
      double endLat,
      double endLon,
      ) async {
    return Geolocator.bearingBetween(
      startLat,
      startLon,
      endLat,
      endLon,
    );
  }

  /// Clear location data
  void clearLocation() {
    _currentPosition = null;
    _address = 'No location';
    _error = null;
    notifyListeners();
  }

  String getAccuracyName(LocationAccuracy accuracy) {
    switch (accuracy) {
      case LocationAccuracy.lowest:
        return 'Lowest';
      case LocationAccuracy.low:
        return 'Low';
      case LocationAccuracy.medium:
        return 'Medium';
      case LocationAccuracy.high:
        return 'High';
      case LocationAccuracy.best:
        return 'Best';
      case LocationAccuracy.bestForNavigation:
        return 'Best for Navigation';
      case LocationAccuracy.reduced:
        return 'Reduced';
      default:
        return 'Unknown';
    }
  }

}