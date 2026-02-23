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
  AuthService({this.baseUrl = 'http://10.0.2.2:8000'});

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

  Future<http.Response> login({
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
