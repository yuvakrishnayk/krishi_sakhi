import 'dart:convert';

class FarmNewsItem {
  const FarmNewsItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.publishedAt,
    this.sourceName = '',
    this.sourceUrl = '',
    this.imageUrl = '',
    this.tags = const <String>[],
  });

  final String id;
  final String title;
  final String subtitle;
  final String category;
  final DateTime publishedAt;
  final String sourceName;
  final String sourceUrl;
  final String imageUrl;
  final List<String> tags;

  factory FarmNewsItem.fromMap(Map<String, dynamic> map) {
    final dynamic tagsRaw = map['tags'];
    final List<String> parsedTags =
        tagsRaw is List
            ? tagsRaw.map((tag) => tag.toString()).toList(growable: false)
            : const <String>[];

    return FarmNewsItem(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      subtitle: map['summary'] as String? ?? map['subtitle'] as String? ?? '',
      category: map['category'] as String? ?? 'general',
      publishedAt:
          DateTime.tryParse(
            map['published_at'] as String? ??
                map['publishedAt'] as String? ??
                '',
          ) ??
          DateTime.now(),
      sourceName:
          map['source_name'] as String? ?? map['sourceName'] as String? ?? '',
      sourceUrl:
          map['source_url'] as String? ?? map['sourceUrl'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? map['imageUrl'] as String? ?? '',
      tags: parsedTags,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'summary': subtitle,
      'subtitle': subtitle,
      'category': category,
      'published_at': publishedAt.toIso8601String(),
      'publishedAt': publishedAt.toIso8601String(),
      'source_name': sourceName,
      'sourceName': sourceName,
      'source_url': sourceUrl,
      'sourceUrl': sourceUrl,
      'image_url': imageUrl,
      'imageUrl': imageUrl,
      'tags': tags,
    };
  }

  Map<String, dynamic> toAgentJson() {
    return {
      'title': title,
      'summary': subtitle,
      'category': category,
      'published_at': publishedAt.toUtc().toIso8601String(),
      'source_name': sourceName,
      'source_url': sourceUrl,
      'image_url': imageUrl,
      'tags': tags,
    };
  }

  static List<FarmNewsItem> decodeList(String rawJson) {
    final list = jsonDecode(rawJson) as List<dynamic>;
    return list
        .map((item) => FarmNewsItem.fromMap(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  static String encodeList(List<FarmNewsItem> items) {
    return jsonEncode(
      items.map((item) => item.toMap()).toList(growable: false),
    );
  }
}

class FarmProjectItem {
  const FarmProjectItem({
    required this.id,
    required this.name,
    required this.crop,
    required this.startedLabel,
    required this.progress,
    required this.status,
    required this.irrigationNote,
    required this.priority,
  });

  final String id;
  final String name;
  final String crop;
  final String startedLabel;
  final double progress;
  final String status;
  final String irrigationNote;
  final String priority;

  factory FarmProjectItem.fromMap(Map<String, dynamic> map) {
    return FarmProjectItem(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      crop: map['crop'] as String? ?? '',
      startedLabel: map['startedLabel'] as String? ?? '',
      progress: (map['progress'] as num?)?.toDouble() ?? 0,
      status: map['status'] as String? ?? 'On Track',
      irrigationNote: map['irrigationNote'] as String? ?? '',
      priority: map['priority'] as String? ?? 'normal',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'crop': crop,
      'startedLabel': startedLabel,
      'progress': progress,
      'status': status,
      'irrigationNote': irrigationNote,
      'priority': priority,
    };
  }

  static List<FarmProjectItem> decodeList(String rawJson) {
    final list = jsonDecode(rawJson) as List<dynamic>;
    return list
        .map((item) => FarmProjectItem.fromMap(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  static String encodeList(List<FarmProjectItem> items) {
    return jsonEncode(
      items.map((item) => item.toMap()).toList(growable: false),
    );
  }
}
