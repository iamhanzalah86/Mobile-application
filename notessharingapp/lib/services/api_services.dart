import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl = "http://10.0.2.2:5000/api"; // emulator Android; use localhost for iOS/simulator adjustments
  final storage = FlutterSecureStorage();

  Map<String, String> headers([String? token]) {
    final h = <String, String>{'Accept': 'application/json'};
    if (token != null) h['Authorization'] = 'Bearer $token';
    return h;
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body, {String? token}) async {
    final res = await http.post(Uri.parse('$baseUrl$endpoint'),
        headers: {...headers(token), 'Content-Type': 'application/json'},
        body: json.encode(body));
    return _process(res);
  }

  Future<dynamic> get(String endpoint, {String? token}) async {
    final res = await http.get(Uri.parse('$baseUrl$endpoint'), headers: headers(token));
    return _process(res);
  }

  Future<dynamic> multipartPost(String endpoint, Map<String, String> fields, String filePath, String fileKey, String token) async {
    var uri = Uri.parse('$baseUrl$endpoint');
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll(headers(token));
    fields.forEach((k, v) => request.fields[k] = v);
    request.files.add(await http.MultipartFile.fromPath(fileKey, filePath));
    var streamed = await request.send();
    var res = await http.Response.fromStream(streamed);
    return _process(res);
  }
  Future<dynamic> postAuth(String endpoint, String token) async {
    final res = await http.post(Uri.parse('$baseUrl$endpoint'), headers: headers(token));
    return _process(res);
  }

  dynamic _process(http.Response res) {
    final code = res.statusCode;
    if (code >= 200 && code < 300) {
      if (res.body.isEmpty) return null;
      return json.decode(res.body);
    } else {
      // try parse error message
      try {
        final body = json.decode(res.body);
        throw Exception(body['message'] ?? body);
      } catch (e) {
        throw Exception('Request failed: ${res.statusCode}');
      }
    }
  }
}