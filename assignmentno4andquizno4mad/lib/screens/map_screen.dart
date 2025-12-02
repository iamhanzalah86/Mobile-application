import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../../business_logic/providers/location_provider.dart';
import '../../business_logic/providers/activity_provider.dart';
import 'activity_list_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  String _currentAddress = 'Fetching address...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  // Initialize map and get current location
  Future<void> _initializeMap() async {
    try {
      final locationProvider = context.read<LocationProvider>();
      await locationProvider.getCurrentLocation();

      if (locationProvider.currentPosition != null) {
        final position = locationProvider.currentPosition!;

        // Add current location marker
        _addCurrentLocationMarker(position);

        // Get address from coordinates
        await _getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

        // Animate to current location
        _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 15,
            ),
          ),
        );

        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error initializing map: $e');
      setState(() => _isLoading = false);
    }
  }

  // Load all activities and display as markers
  Future<void> _loadActivities() async {
    try {
      final activityProvider = context.read<ActivityProvider>();
      await activityProvider.fetchActivities();

      _updateActivityMarkers();
    } catch (e) {
      print('Error loading activities: $e');
    }
  }

  // Update markers based on activities
  void _updateActivityMarkers() {
    final activityProvider = context.read<ActivityProvider>();
    final activities = activityProvider.activities;

    // Keep current location marker
    final currentLocationMarker = _markers
        .where((marker) => marker.markerId.value == 'current_location')
        .toSet();

    // Create activity markers
    final activityMarkers = activities.map((activity) {
      return Marker(
        markerId: MarkerId(activity.id),
        position: LatLng(activity.latitude, activity.longitude),
        infoWindow: InfoWindow(
          title: activity.address,
          snippet: activity.timestamp.toString().split('.')[0],
          onTap: () => _showActivityDetail(activity),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue,
        ),
      );
    }).toSet();

    setState(() {
      _markers = currentLocationMarker..addAll(activityMarkers);
    });
  }

  // Add current location marker
  void _addCurrentLocationMarker(Position position) {
    final marker = Marker(
      markerId: const MarkerId('current_location'),
      position: LatLng(position.latitude, position.longitude),
      infoWindow: const InfoWindow(
        title: 'Current Location',
        snippet: 'You are here',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueRed,
      ),
    );

    setState(() => _markers.add(marker));
  }

  // Get address from coordinates using Geocoding
  Future<void> _getAddressFromCoordinates(double lat, double lon) async {
    try {
      final placemarks = await geo.placemarkFromCoordinates(lat, lon);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _currentAddress =
          '${place.street}, ${place.locality}, ${place.postalCode}';
        });
      }
    } catch (e) {
      print('Error getting address: $e');
      setState(() => _currentAddress = '$lat, $lon');
    }
  }

  // Show activity details when marker is tapped
  void _showActivityDetail(activity) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ActivityDetailBottomSheet(activity: activity),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  // Refresh current location
  Future<void> _refreshLocation() async {
    setState(() => _isLoading = true);
    try {
      final locationProvider = context.read<LocationProvider>();
      await locationProvider.getCurrentLocation();

      if (locationProvider.currentPosition != null) {
        final position = locationProvider.currentPosition!;

        // Update marker
        _markers.removeWhere(
              (marker) => marker.markerId.value == 'current_location',
        );
        _addCurrentLocationMarker(position);

        // Update address
        await _getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

        // Animate camera
        _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 15,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error refreshing location: $e');
    }
    setState(() => _isLoading = false);
  }

  // Center map on all activities
  Future<void> _fitAllActivities() async {
    if (_markers.isEmpty) return;

    double minLat = _markers.first.position.latitude;
    double maxLat = _markers.first.position.latitude;
    double minLon = _markers.first.position.longitude;
    double maxLon = _markers.first.position.longitude;

    for (var marker in _markers) {
      minLat = minLat > marker.position.latitude
          ? marker.position.latitude
          : minLat;
      maxLat = maxLat < marker.position.latitude
          ? marker.position.latitude
          : maxLat;
      minLon = minLon > marker.position.longitude
          ? marker.position.longitude
          : minLon;
      maxLon = maxLon < marker.position.longitude
          ? marker.position.longitude
          : maxLon;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLon),
      northeast: LatLng(maxLat, maxLon),
    );

    _mapController.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Google Map
        GoogleMap(
        onMapCreated: (GoogleMapController controller) {
      _mapController = controller;

      // Now map is ready → NOW we initialize things
      _initializeMap();
      _loadActivities();
    },

          initialCameraPosition: const CameraPosition(
            target: LatLng(33.7298, 74.3122), // Islamabad
            zoom: 12,
          ),
          markers: _markers,
          polylines: _polylines,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          compassEnabled: true,
          zoomControlsEnabled: false,
          mapToolbarEnabled: true,
        ),

        // Top App Bar
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Location',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentAddress,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Control Buttons (Bottom Right)
        Positioned(
          bottom: 80,
          right: 16,
          child: Column(
            children: [
              // Fit all activities
              FloatingActionButton(
                heroTag: 'fit_all',
                mini: true,
                backgroundColor: Colors.white,
                onPressed: _fitAllActivities,
                child: const Icon(
                  Icons.zoom_out_map,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              // Refresh location
              FloatingActionButton(
                heroTag: 'refresh',
                mini: true,
                backgroundColor: Colors.white,
                onPressed: _isLoading ? null : _refreshLocation,
                child: _isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(
                  Icons.refresh,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              // Center on current location
              FloatingActionButton(
                heroTag: 'my_location',
                mini: true,
                backgroundColor: Colors.white,
                onPressed: () {
                  final locationProvider = context.read<LocationProvider>();
                  if (locationProvider.currentPosition != null) {
                    final pos = locationProvider.currentPosition!;
                    _mapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(pos.latitude, pos.longitude),
                          zoom: 16,
                        ),
                      ),
                    );
                  }
                },
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),

        // Activity Count (Bottom Left)
        Positioned(
          bottom: 16,
          left: 16,
          child: Consumer<ActivityProvider>(
            builder: (context, provider, _) {
              return Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    'Activities: ${provider.activities.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}

// ===== ACTIVITY DETAIL BOTTOM SHEET =====
class ActivityDetailBottomSheet extends StatelessWidget {
  final activity;

  const ActivityDetailBottomSheet({
    Key? key,
    required this.activity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Address
          Text(
            'Location',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(activity.address),

          const SizedBox(height: 16),

          // Coordinates
          Text(
            'Coordinates',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Lat: ${activity.latitude.toStringAsFixed(4)}',
          ),
          Text(
            'Lon: ${activity.longitude.toStringAsFixed(4)}',
          ),

          const SizedBox(height: 16),

          // Timestamp
          Text(
            'Time',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(activity.timestamp.toString().split('.')[0]),

          const SizedBox(height: 24),

          // Delete Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<ActivityProvider>().deleteActivity(activity.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Activity deleted')),
                );
              },
              icon: const Icon(Icons.delete),
              label: const Text('Delete Activity'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}