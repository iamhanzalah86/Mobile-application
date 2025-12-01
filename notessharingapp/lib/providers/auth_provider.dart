import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_services.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService api = ApiService();
  final storage = FlutterSecureStorage();
  String? token;
  String? userId;
  String? name;
  bool loading = false;

  Future<void> loadToken() async {
    token = await storage.read(key: 'jwt');
    userId = await storage.read(key: 'userId');
    name = await storage.read(key: 'name');
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    loading = true; notifyListeners();
    try {
      final res = await api.post('/auth/login', {'email': email, 'password': password});
      token = res['token'];
      userId = res['user']['id'];
      name = res['user']['name'];
      await storage.write(key: 'jwt', value: token);
      await storage.write(key: 'userId', value: userId);
      await storage.write(key: 'name', value: name);
      loading = false; notifyListeners();
      return true;
    } catch (e) {
      loading = false; notifyListeners();
      rethrow;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    loading = true; notifyListeners();
    try {
      final res = await api.post('/auth/register', {'name': name, 'email': email, 'password': password});
      token = res['token'];
      userId = res['user']['id'];
      this.name = res['user']['name'];
      await storage.write(key: 'jwt', value: token);
      await storage.write(key: 'userId', value: userId);
      await storage.write(key: 'name', value: this.name);
      loading = false; notifyListeners();
      return true;
    } catch (e) {
      loading = false; notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    token = null; userId = null; name = null;
    await storage.deleteAll();
    notifyListeners();
  }


}