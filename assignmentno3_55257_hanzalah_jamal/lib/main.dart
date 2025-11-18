import 'package:flutter/material.dart';

void main() {
  runApp(const SmartHomeApp());
}

// Apply theming and styling to create a consistent modern look.
class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Home Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
        useMaterial3: true,
        // [FIXED] Changed 'CardTheme' to 'CardThemeData' to fix the error in your screenshot
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

// Data Model for a Device
class SmartDevice {
  String name;
  String roomName;
  String type; // 'Light', 'Fan', 'AC', 'Camera'
  bool isOn;
  double value; // Represents brightness or speed (0.0 to 1.0)

  SmartDevice({
    required this.name,
    required this.roomName,
    required this.type,
    this.isOn = false, // Default OFF
    this.value = 0.5,
  });

  // Helper to get icon based on type
  IconData getIcon() {
    switch (type) {
      case 'Light':
        return Icons.lightbulb;
      case 'Fan':
        return Icons.wind_power;
      case 'AC':
        return Icons.ac_unit;
      case 'Camera':
        return Icons.videocam;
      default:
        return Icons.devices;
    }
  }
}

// Main screen with dashboard layout
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Initial Dummy Data
  List<SmartDevice> devices = [
    SmartDevice(
        name: "Living Room Light",
        roomName: "Living Room",
        type: "Light",
        isOn: true),
    SmartDevice(
        name: "Bedroom Fan", roomName: "Bedroom", type: "Fan", isOn: false),
    SmartDevice(
        name: "Main AC", roomName: "Living Room", type: "AC", isOn: false),
  ];

  // Dialog to add a new device
  void _addNewDevice() {
    String newName = "";
    String newRoom = "";
    String selectedType = "Light";
    final List<String> deviceTypes = ["Light", "Fan", "AC", "Camera"];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // Needed to update dropdown inside dialog
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add New Device"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                        labelText: "Device Name"), //
                    onChanged: (val) => newName = val,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: const InputDecoration(
                        labelText: "Room Name"), //
                    onChanged: (val) => newRoom = val,
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    //
                    value: selectedType,
                    isExpanded: true,
                    items: deviceTypes.map((String type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (val) {
                      setDialogState(() {
                        selectedType = val!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (newName.isNotEmpty && newRoom.isNotEmpty) {
                      setState(() {
                        // Device appears dynamically
                        devices.add(SmartDevice(
                          name: newName,
                          roomName: newRoom,
                          type: selectedType,
                        ));
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Responsive layout calculation
    var screenWidth = MediaQuery.of(context).size.width;
    int gridCount = screenWidth > 600 ? 4 : 2;

    return Scaffold(
      // AppBar with Title, Menu Icon, and Profile Icon
      appBar: AppBar(
        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
        title: const Text("Smart Home Dashboard"),
        actions: [
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.account_circle, size: 30)),
          const SizedBox(width: 10),
        ],
      ),
      // FAB to add device
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewDevice,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        // GridView for dashboard layout
        child: GridView.builder(
          itemCount: devices.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridCount,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final device = devices[index];
            // Device Card
            return DeviceCard(
              device: device,
              onChanged: (bool value) {
                setState(() {
                  device.isOn = value; // State update
                });
              },
              onTap: () {
                // Navigate to details screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeviceDetailScreen(
                      device: device,
                      onStateChange: () =>
                          setState(() {}), // Update dashboard when returning
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// Widget for individual Device Card
class DeviceCard extends StatelessWidget {
  final SmartDevice device;
  final Function(bool) onChanged;
  final VoidCallback onTap;

  const DeviceCard({
    super.key,
    required this.device,
    required this.onChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // InkWell for visual response
    return Card(
      // [FIXED] Replaced .withOpacity() with .withValues() to fix the warning
      color: device.isOn
          ? Colors.indigoAccent.withValues(alpha: 0.1)
          : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Device Icon
              Icon(
                device.getIcon(),
                size: 40,
                color: device.isOn ? Colors.indigo : Colors.grey,
              ),
              const Spacer(),
              // Device Name
              Text(
                device.name,
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              Text(device.roomName,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 10),
              // Status Text
              Text(
                device.isOn ? "ON" : "OFF",
                style: TextStyle(
                  color: device.isOn ? Colors.indigo : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Toggle Switch
              Switch(
                value: device.isOn,
                onChanged: onChanged,
                // [FIXED] Replaced activeColor with activeThumbColor
                activeThumbColor: Colors.indigo,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Details Screen
class DeviceDetailScreen extends StatefulWidget {
  final SmartDevice device;
  final VoidCallback onStateChange; // Callback to sync state

  const DeviceDetailScreen(
      {super.key, required this.device, required this.onStateChange});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
        // Back button is automatic in AppBar, but handled implicitly
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Larger Device Image/Icon
            Hero(
              // Nice animation bonus
              tag: widget.device.name,
              child: Icon(
                widget.device.getIcon(),
                size: 150,
                color: widget.device.isOn ? Colors.indigo : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 30),

            // Current Status
            Text(
              "Status: ${widget.device.isOn ? 'Active' : 'Inactive'}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            // Slider for brightness/speed (Only if ON)
            if (widget.device.type == 'Light' ||
                widget.device.type == 'Fan') ...[
              Text(
                widget.device.type == 'Light' ? "Brightness" : "Speed",
                style: const TextStyle(fontSize: 18),
              ),
              Slider(
                value: widget.device.value,
                onChanged: widget.device.isOn
                    ? (newVal) {
                  setState(() {
                    widget.device.value = newVal;
                    widget.onStateChange(); // Sync main dashboard
                  });
                }
                    : null, // Disabled if device is OFF
                activeColor: Colors.indigo,
              ),
            ],

            const Spacer(),

            // Big Toggle Button for better control
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    widget.device.isOn = !widget.device.isOn;
                    widget.onStateChange(); // Sync main dashboard
                  });
                },
                icon: const Icon(Icons.power_settings_new),
                label: Text(widget.device.isOn ? "TURN OFF" : "TURN ON"),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  widget.device.isOn ? Colors.redAccent : Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}