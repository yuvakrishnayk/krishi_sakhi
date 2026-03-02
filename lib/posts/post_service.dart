import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PostService {
  final String baseUrl;

  PostService({this.baseUrl = 'https://krishi-sakhi-backend-app.onrender.com'});

  /// Creates a community post.
  ///
  /// [token]       – JWT bearer token (required).
  /// [title]       – Post title (required).
  /// [tags]        – List of tag strings (optional).
  /// [description] – Post description (optional).
  /// [imageFile]   – Image file on mobile/desktop (optional on web).
  /// [imageBytes]  – Raw image bytes on web (optional on non-web).
  /// [imageFileName] – Filename to use for the web image upload.
  Future<http.Response> createPost({
    required String token,
    required String title,
    List<String>? tags,
    String? description,
    File? imageFile,
    Uint8List? imageBytes,
    String imageFileName = 'image.jpg',
  }) async {
    final uri = Uri.parse('$baseUrl/posts');

    final request = http.MultipartRequest('POST', uri);

    // Authorization header
    request.headers['Authorization'] = 'Bearer $token';

    // Required fields
    request.fields['title'] = title;

    // Optional tags – send as a JSON array string that matches the API
    if (tags != null && tags.isNotEmpty) {
      request.fields['tags'] = jsonEncode(tags);
    }

    // Optional description
    if (description != null && description.isNotEmpty) {
      request.fields['description'] = description;
    }

    // Image – pick the right source based on platform
    if (kIsWeb && imageBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: imageFileName,
        ),
      );
    } else if (!kIsWeb && imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return response;
  }
}
