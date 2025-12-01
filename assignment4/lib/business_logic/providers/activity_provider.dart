import 'package:flutter/material.dart';
import 'package:assignment4/models/activity_model.dart';
import 'package:assignment4/repository/api_repository.dart';
import 'package:assignment4/repository/local_storage_repository.dart';

class ActivityProvider extends ChangeNotifier {
  final ApiRepository _apiRepository = ApiRepository();
  final LocalStorageRepository _localRepository = LocalStorageRepository();

  List<ActivityModel> _activities = [];
  bool _isLoading = false;
  String? _error;

  List<ActivityModel> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> createActivity(ActivityModel activity) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _localRepository.saveActivity(activity);

      try {
        final syncedActivity = await _apiRepository.createActivity(activity);
        await _localRepository.saveActivity(syncedActivity);
      } catch (e) {
        _error = 'Will sync when online: $e';
      }

      await fetchActivities();
    } catch (e) {
      _error = 'Error creating activity: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchActivities() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activities = await _apiRepository.getActivities();
      _error = null;
    } catch (e) {
      _error = 'Fetching local data: $e';
      final recent = await _localRepository.getRecentActivities(limit: 5);
      _activities = recent;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteActivity(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiRepository.deleteActivity(id);
      await _localRepository.deleteActivity(id);
      _activities.removeWhere((a) => a.id == id);
    } catch (e) {
      _error = 'Error deleting activity: $e';
      await _localRepository.deleteActivity(id);
      _activities.removeWhere((a) => a.id == id);
    }

    _isLoading = false;
    notifyListeners();
  }

  List<ActivityModel> searchActivities(String query) {
    if (query.isEmpty) return _activities;
    return _activities
        .where((a) => a.address.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}