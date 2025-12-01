import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../business_logic/providers/activity_provider.dart';
import '../../business_logic/providers/location_provider.dart';
import '../models/activity_model.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _captureImage() async {
    final XFile? photo =
    await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() => _selectedImage = File(photo.path));
    }
  }

  Future<void> _pickImage() async {
    final XFile? photo =
    await _picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      setState(() => _selectedImage = File(photo.path));
    }
  }

  Future<void> _logActivity() async {
    final locationProvider = context.read<LocationProvider>();
    final activityProvider = context.read<ActivityProvider>();

    if (_selectedImage == null || locationProvider.currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture image and enable location')),
      );
      return;
    }

    final activity = ActivityModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      latitude: locationProvider.currentPosition!.latitude,
      longitude: locationProvider.currentPosition!.longitude,
      imagePath: _selectedImage!.path,
      timestamp: DateTime.now(),
      address: locationProvider.address,
      synced: false,
    );

    await activityProvider.createActivity(activity);
    setState(() => _selectedImage = null);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity logged successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_selectedImage != null)
            Container(
              height: 300,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_selectedImage!, fit: BoxFit.cover),
              ),
            )
          else
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.image, size: 64),
            ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _captureImage,
                icon: const Icon(Icons.camera),
                label: const Text('Capture'),
              ),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo),
                label: const Text('Gallery'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _logActivity,
              icon: const Icon(Icons.save),
              label: const Text('Log Activity'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}