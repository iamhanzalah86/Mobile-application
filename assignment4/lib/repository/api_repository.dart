// lib/data/repository/api_repository.dart
// Updated for Node.js/Express Backend

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/activity_model.dart';

class ApiRepository {
  // ===== UPDATE THIS TO YOUR BACKEND URL =====
  // Local Testing (Android Emulator)
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // Real Device (replace with your PC IP)
  // static const String baseUrl = 'http://192.168.X.X:5000/api';

  // Production
  // static const String baseUrl = 'http://your-server.com/api';

  final http.Client _client = http.Client();

  // ========== CREATE ACTIVITY ==========
  Future<ActivityModel> createActivity(ActivityModel activity) async {
    try {
      print('Creating activity at: $baseUrl/activities');

      final response = await _client.post(
        Uri.parse('$baseUrl/activities'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(activity.toJson()),
      ).timeout(const Duration(seconds: 15));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // Handle both direct response and nested 'data' response
        if (jsonData is Map && jsonData.containsKey('data')) {
          return ActivityModel.fromJson(Map<String, dynamic>.from(jsonData['data']));
        } else {
          return ActivityModel.fromJson(Map<String, dynamic>.from(jsonData));
        }
      } else {
        throw Exception('Failed to create activity: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in createActivity: $e');
      throw Exception('API Error: $e');
    }
  }

  // ========== GET ALL ACTIVITIES ==========
  Future<List<ActivityModel>> getActivities() async {
    try {
      print('Fetching activities from: $baseUrl/activities');

      final response = await _client.get(
        Uri.parse('$baseUrl/activities'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // Handle nested 'data' response
        List<dynamic> data;
        if (jsonData is Map && jsonData.containsKey('data')) {
          data = jsonData['data'] as List<dynamic>;
        } else if (jsonData is List) {
          data = jsonData;
        } else {
          return [];
        }

        return data
            .map((json) => ActivityModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      } else {
        throw Exception('Failed to fetch activities: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getActivities: $e');
      throw Exception('API Error: $e');
    }
  }

  // ========== GET SINGLE ACTIVITY ==========
  Future<ActivityModel?> getActivityById(String id) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/activities/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData is Map && jsonData.containsKey('data')) {
          return ActivityModel.fromJson(Map<String, dynamic>.from(jsonData['data']));
        } else {
          return ActivityModel.fromJson(Map<String, dynamic>.from(jsonData));
        }
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to fetch activity');
      }
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }

  // ========== UPDATE ACTIVITY ==========
  Future<ActivityModel> updateActivity(ActivityModel activity) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/activities/${activity.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(activity.toJson()),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData is Map && jsonData.containsKey('data')) {
          return ActivityModel.fromJson(Map<String, dynamic>.from(jsonData['data']));
        } else {
          return ActivityModel.fromJson(Map<String, dynamic>.from(jsonData));
        }
      } else {
        throw Exception('Failed to update activity');
      }
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }

  // ========== DELETE ACTIVITY ==========
  Future<void> deleteActivity(String id) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl/activities/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200 &&
          response.statusCode != 204 &&
          response.statusCode != 201) {
        throw Exception('Failed to delete activity: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }

  // ========== SEARCH ACTIVITIES ==========
  Future<List<ActivityModel>> searchActivities(String query) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/activities?search=$query'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        List<dynamic> data;
        if (jsonData is Map && jsonData.containsKey('data')) {
          data = jsonData['data'] as List<dynamic>;
        } else if (jsonData is List) {
          data = jsonData;
        } else {
          return [];
        }

        return data
            .map((json) => ActivityModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      } else {
        throw Exception('Failed to search activities');
      }
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }

  // ========== GET RECENT ACTIVITIES ==========
  Future<List<ActivityModel>> getRecentActivities({int limit = 5}) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/activities/recent/$limit'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        List<dynamic> data;
        if (jsonData is Map && jsonData.containsKey('data')) {
          data = jsonData['data'] as List<dynamic>;
        } else if (jsonData is List) {
          data = jsonData;
        } else {
          return [];
        }

        return data
            .map((json) => ActivityModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      } else {
        throw Exception('Failed to fetch recent activities');
      }
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }

  // ========== HEALTH CHECK ==========
  Future<bool> healthCheck() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }
}