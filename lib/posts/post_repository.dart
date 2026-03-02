import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'post_service.dart';

class PostResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  const PostResult({required this.success, required this.message, this.data});
}

class PostRepository {
  final PostService service;
  final FlutterSecureStorage _storage;

  static const _tokenKey = 'auth_token';

  PostRepository({PostService? service, FlutterSecureStorage? storage})
    : service = service ?? PostService(),
      _storage = storage ?? const FlutterSecureStorage();

  Future<PostResult> createPost({
    required String title,
    List<String>? tags,
    String? description,
    File? imageFile,
    Uint8List? imageBytes,
    String imageFileName = 'image.jpg',
  }) async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null || token.isEmpty) {
      return const PostResult(
        success: false,
        message: 'You are not logged in. Please sign in and try again.',
      );
    }

    try {
      final response = await service.createPost(
        token: token,
        title: title,
        tags: tags,
        description: description,
        imageFile: imageFile,
        imageBytes: imageBytes,
        imageFileName: imageFileName,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        return PostResult(
          success: true,
          message: 'Post created successfully!',
          data: body is Map<String, dynamic> ? body : null,
        );
      } else {
        // Try to parse a message from the JSON error body
        String errorMessage = 'Failed to create post (${response.statusCode}).';
        try {
          final body = jsonDecode(response.body);
          if (body is Map && body['message'] != null) {
            errorMessage = body['message'].toString();
          } else if (body is Map && body['error'] != null) {
            errorMessage = body['error'].toString();
          }
        } catch (_) {}
        return PostResult(success: false, message: errorMessage);
      }
    } catch (e) {
      return PostResult(
        success: false,
        message: 'Network error. Please check your connection and try again.',
      );
    }
  }
}
