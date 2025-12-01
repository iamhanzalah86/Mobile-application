import 'package:flutter/material.dart';
import '../services/api_services.dart';

class UserProvider extends ChangeNotifier {
  final ApiService api = ApiService();

  bool loading = false;
  String? error;
  List<Map<String, dynamic>> searchResults = [];
  List<Map<String, dynamic>> following = [];
  Map<String, dynamic>? currentUserProfile;
  List<dynamic> currentUserNotes = [];

  /// -----------------------------
  /// 🔍 SEARCH USERS
  /// -----------------------------
  Future<void> searchUsers(String query, String token) async {
    if (query.trim().isEmpty) {
      searchResults = [];
      notifyListeners();
      return;
    }

    loading = true;
    error = null;
    notifyListeners();

    try {
      final res = await api.get("/users/search?q=$query", token: token);

      if (res is List) {
        searchResults = List<Map<String, dynamic>>.from(res);
      } else if (res["users"] != null) {
        searchResults = List<Map<String, dynamic>>.from(res["users"]);
      } else {
        searchResults = [];
      }
    } catch (e) {
      searchResults = [];
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  /// -----------------------------
  /// ➕ FOLLOW USER
  /// -----------------------------
  Future<void> followUser(String userId, String token) async {
    loading = true;
    notifyListeners();

    try {
      await api.postAuth("/users/follow/$userId", token);
      _updateFollowStatus(userId, true);
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  /// -----------------------------
  /// ➖ UNFOLLOW USER
  /// -----------------------------
  Future<void> unfollowUser(String userId, String token) async {
    loading = true;
    notifyListeners();

    try {
      await api.postAuth("/users/unfollow/$userId", token);
      _updateFollowStatus(userId, false);
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }

  /// -----------------------------
  /// 🔧 INTERNAL HELPER
  /// -----------------------------
  void _updateFollowStatus(String userId, bool isFollowing) {
    // Update search results
    for (var user in searchResults) {
      if (user["_id"] == userId) {
        user["isFollowing"] = isFollowing;
        user["name"] = user["name"] ?? '';
      }
    }

    // Update following list
    if (isFollowing) {
      if (!following.any((u) => u["_id"] == userId)) {
        final user = searchResults.firstWhere(
              (u) => u["_id"] == userId,
          orElse: () => {},
        );
        if (user.isNotEmpty) following.add(user);
      }
    } else {
      following.removeWhere((u) => u["_id"] == userId);
    }

    notifyListeners();
  }

  /// -----------------------------
  /// 👤 GET USER PROFILE
  /// -----------------------------
  Future<void> fetchUserProfile(String userId, String token) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      // Fetch profile
      final profileRes = await api.get("/users/$userId", token: token);
      currentUserProfile = {
        ...profileRes,

        'followers': List<String>.from(
            (profileRes['followers'] ?? []).map((e) => e.toString())),
        'following': List<String>.from((profileRes['following']?? []).map((e) => e.toString()))

      };

      // Fetch notes safely
      final notesRes = await api.get("/notes/user/$userId", token: token);
      if (notesRes is List) {
        currentUserNotes = notesRes;
      } else if (notesRes['notes'] is List) {
        currentUserNotes = notesRes['notes'];
      } else {
        currentUserNotes = [];
      }
    } catch (e) {
      currentUserProfile = null;
      currentUserNotes = [];
      error = e.toString();
    }

    loading = false;
    notifyListeners();
  }
}