import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl;

  /// The base URL of your backend server.
  ///
  /// When running on an Android emulator, `127.0.0.1` refers to the
  /// emulated device itself.  To reach the host machine use `10.0.2.2`.
  ///
  /// The default here is set accordingly, but you can always provide a
  /// custom value when constructing the service (e.g. during testing or
  /// when using a physical device).
  AuthService({this.baseUrl = 'https://krishi-sakhi-backend-app.onrender.com'});

  Future<http.Response> register({
    required String name,
    required String mobile,
    required String pin,
    required String confirmPin,
    String? imagePath,
  }) async {
    final uri = Uri.parse('$baseUrl/register');

    final request = http.MultipartRequest('POST', uri);
    request.fields['name'] = name;
    request.fields['mobile'] = mobile;
    request.fields['pin'] = pin;
    request.fields['confirm_pin'] = confirmPin;

    if (imagePath != null && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (await file.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imagePath),
        );
      }
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return response;
  }

  /// Request login by mobile/pin.  The server will send an OTP to the
  /// provided number if the credentials are valid.  No token is returned at
  /// this stage.
  Future<http.Response> requestLoginOtp({
    required String mobile,
    required String pin,
  }) async {
    final uri = Uri.parse('$baseUrl/login');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mobile': mobile, 'pin': pin}),
    );
    return response;
  }

  /// Verify an OTP that was previously sent during the signup process.  If
  /// successful the user account will be marked verified on the backend.
  Future<http.Response> verifySignup({
    required String mobile,
    required String code,
  }) async {
    final uri = Uri.parse('$baseUrl/verify_signup');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mobile': mobile, 'code': code}),
    );
    return response;
  }

  /// Verify an OTP sent as part of a login request.  On success the response
  /// will include a JWT token in the `data` field.
  Future<http.Response> verifyLogin({
    required String mobile,
    required String code,
  }) async {
    final uri = Uri.parse('$baseUrl/verify_login');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mobile': mobile, 'code': code}),
    );
    return response;
  }

  Future<http.Response> getProfile({required String token}) async {
    final uri = Uri.parse('$baseUrl/profile');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }
}
