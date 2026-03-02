import 'package:flutter/material.dart';

/// Post data model for the forum/discussion feature
class PostData {
  final String id;
  final String title;
  final String author;
  final String timeAgo;
  final String category;
  int likes;
  final int comments;
  bool isBookmarked;
  bool isLiked;
  final String imageUrl;
  final IconData icon;
  final String description;
  final String avatarUrl;

  PostData({
    required this.id,
    required this.title,
    required this.author,
    required this.timeAgo,
    required this.category,
    required this.likes,
    required this.comments,
    this.isBookmarked = false,
    this.isLiked = false,
    this.imageUrl = '',
    required this.icon,
    this.description = '',
    this.avatarUrl = '',
  });
}

/// Comment data model for post comments
class CommentData {
  final String id;
  final String author;
  final String content;
  final String timeAgo;
  final int likes;
  final bool isExpert;

  CommentData({
    required this.id,
    required this.author,
    required this.content,
    required this.timeAgo,
    required this.likes,
    required this.isExpert,
  });
}
