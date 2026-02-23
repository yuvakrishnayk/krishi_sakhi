import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'auth_service.dart';
import 'models/user.dart';

class AuthRepository {
  final AuthService service;
  final FlutterSecureStorage _storage;

  AuthRepository({required this.service, FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  Future<User?> register({
    required String name,
    required String mobile,
    required String pin,
    required String confirmPin,
    String? imagePath,
  }) async {
    final http.Response res = await service.register(
      name: name,
      mobile: mobile,
      pin: pin,
      confirmPin: confirmPin,
      imagePath: imagePath,
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      final body = jsonDecode(res.body);
      // If API returns token and user
      if (body is Map<String, dynamic>) {
        if (body['token'] != null) {
          await _storage.write(key: _tokenKey, value: body['token'].toString());
        }
        if (body['user'] != null) {
          await _storage.write(key: _userKey, value: jsonEncode(body['user']));
          return User.fromJson(Map<String, dynamic>.from(body['user']));
        }
        // fallback: try parse body as user
        return User.fromJson(body);
      }
    }

    throw Exception('Register failed: ${res.statusCode} ${res.body}');
  }

  Future<User?> login({required String mobile, required String pin}) async {
    final http.Response res = await service.login(mobile: mobile, pin: pin);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      if (body is Map<String, dynamic>) {
        if (body['token'] != null) {
          await _storage.write(key: _tokenKey, value: body['token'].toString());
        }
        if (body['user'] != null) {
          await _storage.write(key: _userKey, value: jsonEncode(body['user']));
          return User.fromJson(Map<String, dynamic>.from(body['user']));
        }
        return User.fromJson(body);
      }
    }
    throw Exception('Login failed: ${res.statusCode} ${res.body}');
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  Future<String?> get token async => await _storage.read(key: _tokenKey);

  Future<User?> get currentUser async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null) return null;
    final map = jsonDecode(raw);
    return User.fromJson(Map<String, dynamic>.from(map));
  }
}
