import 'package:hive/hive.dart';

part "activity_model.g.dart";

@HiveType(typeId: 0)
class ActivityModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double latitude;

  @HiveField(2)
  final double longitude;

  @HiveField(3)
  final String imagePath;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final String address;

  @HiveField(6)
  final bool synced;

  ActivityModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.imagePath,
    required this.timestamp,
    required this.address,
    this.synced = false,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      imagePath: json['imagePath'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      address: json['address'] as String? ?? '',
      synced: json['synced'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'latitude': latitude,
    'longitude': longitude,
    'imagePath': imagePath,
    'timestamp': timestamp.toIso8601String(),
    'address': address,
    'synced': synced,
  };

  @override
  String toString() => 'Activity($id, $latitude, $longitude, $address)';
}