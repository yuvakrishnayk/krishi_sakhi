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
      // registration does not return a token; the client should proceed to the
      // OTP verification screen before attempting to sign in.
      return null;
    }
    throw Exception('Register failed: ${res.statusCode} ${res.body}');
  }

  /// Request an OTP for login.  The call will succeed if the mobile/pin
  /// combination is valid.  No token is stored at this point.
  Future<void> requestLoginOtp({
    required String mobile,
    required String pin,
  }) async {
    final http.Response res = await service.requestLoginOtp(
      mobile: mobile,
      pin: pin,
    );
    if (res.statusCode == 200) {
      return;
    }
    throw Exception('Login request failed: ${res.statusCode} ${res.body}');
  }

  Future<void> verifySignup({
    required String mobile,
    required String code,
  }) async {
    final http.Response res = await service.verifySignup(
      mobile: mobile,
      code: code,
    );
    if (res.statusCode == 200) {
      return;
    }
    throw Exception(
      'OTP verification (signup) failed: ${res.statusCode} ${res.body}',
    );
  }

  Future<void> verifyLogin({
    required String mobile,
    required String code,
  }) async {
    final http.Response res = await service.verifyLogin(
      mobile: mobile,
      code: code,
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      if (body is Map<String, dynamic> && body['data'] != null) {
        final token = body['data'].toString();
        await _storage.write(key: _tokenKey, value: token);
        // optionally fetch profile
        try {
          final profileRes = await service.getProfile(token: token);
          if (profileRes.statusCode == 200) {
            final profBody = jsonDecode(profileRes.body);
            if (profBody is Map<String, dynamic> && profBody['data'] != null) {
              await _storage.write(
                key: _userKey,
                value: jsonEncode(profBody['data']),
              );
            }
          }
        } catch (_) {}
        return;
      }
    }
    throw Exception(
      'OTP verification (login) failed: ${res.statusCode} ${res.body}',
    );
  }

  Future<User> login({required String mobile, required String pin}) async {
    // TODO: Implement actual login logic, e.g., API call
    // For now, return a dummy user or throw an error if needed
    if (mobile == "1234567890" && pin == "1234") {
      return User(name: "Test User", mobile: mobile);
    } else {
      throw Exception("Invalid credentials");
    }
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
