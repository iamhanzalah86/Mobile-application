import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../models/note.dart';
import 'auth_provider.dart';

class NotesProvider extends ChangeNotifier {
  final ApiService api = ApiService();
  List<Note> notes = [];
  bool loading = false;

  Future<void> fetchFeed(String token) async {
    loading = true; notifyListeners();
    try {
      final res = await api.get('/notes/feed', token: token);
      notes = (res as List).map((j) => Note.fromJson(j)).toList();
      loading = false; notifyListeners();
    } catch (e) {
      loading = false; notifyListeners();
      rethrow;
    }
  }
}