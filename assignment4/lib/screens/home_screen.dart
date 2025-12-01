import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business_logic/providers/activity_provider.dart';
import '../../business_logic/providers/location_provider.dart';
import 'map_screen.dart';
import 'camera_screen.dart';
import 'activity_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ActivityProvider>().fetchActivities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartTracker'),
        elevation: 0,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          MapScreen(),
          CameraScreen(),
          ActivityListScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Capture'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}