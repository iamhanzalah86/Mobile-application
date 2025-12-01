import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business_logic/providers/location_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<LocationProvider>().getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, _) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (locationProvider.isLoading)
                const CircularProgressIndicator()
              else if (locationProvider.error != null)
                Text('Error: ${locationProvider.error}',
                    style: const TextStyle(color: Colors.red))
              else if (locationProvider.currentPosition != null)
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Current Location',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Lat: ${locationProvider.currentPosition!.latitude.toStringAsFixed(4)}',
                            ),
                            Text(
                              'Lon: ${locationProvider.currentPosition!.longitude.toStringAsFixed(4)}',
                            ),
                            const SizedBox(height: 8),
                            Text('${locationProvider.address}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          context
                              .read<LocationProvider>()
                              .getCurrentLocation();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh Location'),
                      ),
                    ],
                  )
                else
                  const Text('No location data'),
            ],
          ),
        );
      },
    );
  }
}