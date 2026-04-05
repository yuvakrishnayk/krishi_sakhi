import 'package:krishi_sakhi/models/home_feed_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeFeedLocalStorage {
  HomeFeedLocalStorage._();

  static const String _newsKey = 'home_news_items_v1';
  static const String _projectsKey = 'home_project_items_v1';
  static const String _aiResponsesKey = 'home_ai_responses_v1';

  static List<FarmNewsItem>? _memoryNews;
  static List<FarmProjectItem>? _memoryProjects;
  static List<AiResponseItem>? _memoryAiResponses;

  static Future<SharedPreferences?> _safePrefs() async {
    try {
      return await SharedPreferences.getInstance();
    } on PlatformException catch (e) {
      // Fallback for plugin channel issues (e.g. hot reload after adding plugin).
      // This keeps app features working for the current runtime.
      debugPrint('SharedPreferences unavailable (PlatformException): $e');
      return null;
    } on MissingPluginException catch (e) {
      debugPrint('SharedPreferences unavailable (MissingPluginException): $e');
      return null;
    }
  }

  static Future<void> ensureSeedData() async {
    final prefs = await _safePrefs();

    if (prefs == null) {
      _memoryNews ??= List<FarmNewsItem>.from(_defaultNews);
      _memoryProjects ??= List<FarmProjectItem>.from(_defaultProjects);
      return;
    }

    if (!prefs.containsKey(_newsKey)) {
      await prefs.setString(_newsKey, FarmNewsItem.encodeList(_defaultNews));
    }

    if (!prefs.containsKey(_projectsKey)) {
      await prefs.setString(
        _projectsKey,
        FarmProjectItem.encodeList(_defaultProjects),
      );
    }
  }

  static Future<List<FarmNewsItem>> getNews() async {
    final prefs = await _safePrefs();
    if (prefs == null) {
      _memoryNews ??= List<FarmNewsItem>.from(_defaultNews);
      return List<FarmNewsItem>.from(_memoryNews!);
    }

    final raw = prefs.getString(_newsKey);
    if (raw == null || raw.isEmpty) {
      return _defaultNews;
    }
    try {
      return FarmNewsItem.decodeList(raw);
    } catch (_) {
      return _defaultNews;
    }
  }

  static Future<List<FarmProjectItem>> getProjects() async {
    final prefs = await _safePrefs();
    if (prefs == null) {
      _memoryProjects ??= List<FarmProjectItem>.from(_defaultProjects);
      return List<FarmProjectItem>.from(_memoryProjects!);
    }

    final raw = prefs.getString(_projectsKey);
    if (raw == null || raw.isEmpty) {
      return _defaultProjects;
    }
    try {
      return FarmProjectItem.decodeList(raw);
    } catch (_) {
      return _defaultProjects;
    }
  }

  static Future<List<AiResponseItem>> getAiResponses() async {
    final prefs = await _safePrefs();
    if (prefs == null) {
      _memoryAiResponses ??= <AiResponseItem>[];
      return List<AiResponseItem>.from(_memoryAiResponses!);
    }

    final raw = prefs.getString(_aiResponsesKey);
    if (raw == null || raw.isEmpty) {
      return const <AiResponseItem>[];
    }
    try {
      return AiResponseItem.decodeList(raw);
    } catch (_) {
      return const <AiResponseItem>[];
    }
  }

  static Future<void> saveNews(List<FarmNewsItem> items) async {
    _memoryNews = List<FarmNewsItem>.from(items);

    final prefs = await _safePrefs();
    if (prefs == null) {
      return;
    }

    await prefs.setString(_newsKey, FarmNewsItem.encodeList(items));
  }

  static Future<void> saveProjects(List<FarmProjectItem> items) async {
    _memoryProjects = List<FarmProjectItem>.from(items);

    final prefs = await _safePrefs();
    if (prefs == null) {
      return;
    }

    await prefs.setString(_projectsKey, FarmProjectItem.encodeList(items));
  }

  static Future<void> saveAiResponses(List<AiResponseItem> items) async {
    _memoryAiResponses = List<AiResponseItem>.from(items);

    final prefs = await _safePrefs();
    if (prefs == null) {
      return;
    }

    await prefs.setString(_aiResponsesKey, AiResponseItem.encodeList(items));
  }

  static Future<void> addAiResponse(AiResponseItem item) async {
    final existing = await getAiResponses();
    final updated = <AiResponseItem>[item, ...existing];
    // Prevent unbounded growth in SharedPreferences.
    final bounded = updated.length > 200 ? updated.sublist(0, 200) : updated;
    await saveAiResponses(bounded);
  }

  static Future<void> clearAiResponses() async {
    _memoryAiResponses = <AiResponseItem>[];

    final prefs = await _safePrefs();
    if (prefs == null) {
      return;
    }

    await prefs.remove(_aiResponsesKey);
  }

  static Future<void> removeAiResponseById(String id) async {
    final existing = await getAiResponses();
    final updated = existing.where((item) => item.id != id).toList();
    await saveAiResponses(updated);
  }

  static final List<FarmNewsItem> _defaultNews = [
    FarmNewsItem(
      id: 'news_1',
      title: 'Rice MSP Updated for 2026 Kharif Season',
      subtitle:
          'Revised MSP will be effective from 1st July in procurement centers.',
      category: 'market',
      publishedAt: DateTime(2026, 4, 3),
    ),
    FarmNewsItem(
      id: 'news_2',
      title: 'PM-Kisan Verification Window Open',
      subtitle:
          'Farmer profile verification is open till 30th April for next installment.',
      category: 'scheme',
      publishedAt: DateTime(2026, 4, 2),
    ),
    FarmNewsItem(
      id: 'news_3',
      title: 'Coconut Price Sees Upward Movement',
      subtitle: 'Regional markets reported improved coconut rates this week.',
      category: 'market',
      publishedAt: DateTime(2026, 3, 30),
    ),
    FarmNewsItem(
      id: 'news_4',
      title: 'Irrigation Subsidy Applications Active',
      subtitle:
          'Micro-irrigation subsidy applications are open under state scheme.',
      category: 'scheme',
      publishedAt: DateTime(2026, 3, 28),
    ),
  ];

  static final List<FarmProjectItem> _defaultProjects = [
    const FarmProjectItem(
      id: 'project_1',
      name: 'Kizhakkekara Main Field',
      crop: 'Rice',
      startedLabel: 'Started in May',
      progress: 0.7,
      status: 'On Track',
      irrigationNote: 'Watered today',
      priority: 'normal',
    ),
    const FarmProjectItem(
      id: 'project_2',
      name: 'Canal Side Plot',
      crop: 'Vegetables',
      startedLabel: 'Started in June',
      progress: 0.35,
      status: 'Needs Attention',
      irrigationNote: 'Irrigation needed',
      priority: 'high',
    ),
    const FarmProjectItem(
      id: 'project_3',
      name: 'West Coconut Block',
      crop: 'Coconut',
      startedLabel: 'Started in April',
      progress: 0.9,
      status: 'On Track',
      irrigationNote: 'Moisture level stable',
      priority: 'normal',
    ),
  ];
}
