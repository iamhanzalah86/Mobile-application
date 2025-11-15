import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const PlatformNativeApp());

class PlatformNativeApp extends StatelessWidget {
  const PlatformNativeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Platform Native Code',
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('Platform Native Code Example')),
        body: const PlatformDemo(),
      ),
    );
  }
}

class PlatformDemo extends StatefulWidget {
  const PlatformDemo({super.key});

  @override
  State<PlatformDemo> createState() => _PlatformDemoState();
}

class _PlatformDemoState extends State<PlatformDemo> {
  // MethodChannel - Communication bridge between Flutter and native code
  static const platform = MethodChannel('com.example.native/channel');

  String _batteryLevel = 'Unknown';
  String _deviceInfo = 'Unknown';
  String _toastMessage = '';
  bool _isLoading = false;

  // Method to get battery level from native platform
  Future<void> _getBatteryLevel() async {
    setState(() {
      _isLoading = true;
    });

    String batteryLevel;
    try {
      // Invoking native method using MethodChannel
      final int result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level: $result%';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'";
    }

    setState(() {
      _batteryLevel = batteryLevel;
      _isLoading = false;
    });
  }

  // Method to get device information from native platform
  Future<void> _getDeviceInfo() async {
    setState(() {
      _isLoading = true;
    });

    String deviceInfo;
    try {
      // Invoking native method with different method name
      final String result = await platform.invokeMethod('getDeviceInfo');
      deviceInfo = result;
    } on PlatformException catch (e) {
      deviceInfo = "Failed to get device info: '${e.message}'";
    }

    setState(() {
      _deviceInfo = deviceInfo;
      _isLoading = false;
    });
  }

  // Method to show native Toast (Android) or Alert (iOS)
  Future<void> _showNativeToast() async {
    try {
      // Invoking native method with arguments
      await platform.invokeMethod('showToast', {
        'message': 'Hello from Flutter!',
      });
      setState(() {
        _toastMessage = 'Native toast/alert shown successfully!';
      });
    } on PlatformException catch (e) {
      setState(() {
        _toastMessage = "Failed to show toast: '${e.message}'";
      });
    }
  }

  // Method to open native settings
  Future<void> _openNativeSettings() async {
    try {
      // Invoking native method without return value
      await platform.invokeMethod('openSettings');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Opening native settings...')),
      );
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: '${e.message}'")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section 1: MethodChannel Explanation
          _buildSectionCard(
            'MethodChannel',
            'Communication bridge between Flutter and platform-specific code (Android/iOS)',
            Colors.blue,
            Icons.link,
          ),
          const SizedBox(height: 16),

          // Section 2: Battery Level Example
          _buildFeatureCard(
            'Get Battery Level',
            _batteryLevel,
            Icons.battery_charging_full,
            Colors.green,
            _getBatteryLevel,
          ),
          const SizedBox(height: 16),

          // Section 3: Device Info Example
          _buildFeatureCard(
            'Get Device Info',
            _deviceInfo,
            Icons.phone_android,
            Colors.purple,
            _getDeviceInfo,
          ),
          const SizedBox(height: 16),

          // Section 4: Native Toast Example
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: const [
                      Icon(Icons.message, color: Colors.orange, size: 30),
                      SizedBox(width: 12),
                      Text(
                        'Show Native Toast/Alert',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _toastMessage.isEmpty ? 'Click button to show native message' : _toastMessage,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _showNativeToast,
                    icon: const Icon(Icons.send),
                    label: const Text('Show Toast'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Section 5: Open Native Settings
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: const [
                      Icon(Icons.settings, color: Colors.teal, size: 30),
                      SizedBox(width: 12),
                      Text(
                        'Open Native Settings',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Opens device settings using native code',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _openNativeSettings,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open Settings'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Loading Indicator
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Helper widget for section cards
  Widget _buildSectionCard(String title, String description, Color color, IconData icon) {
    return Card(
      elevation: 4,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for feature cards
  Widget _buildFeatureCard(
      String title,
      String result,
      IconData icon,
      Color color,
      VoidCallback onPressed,
      ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 30),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                result,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.refresh),
              label: const Text('Get Data'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}