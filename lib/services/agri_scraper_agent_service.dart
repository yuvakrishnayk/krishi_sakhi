import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:krishi_sakhi/models/home_feed_models.dart';
import 'package:xml/xml.dart';

class AgriScraperAgentService {
  AgriScraperAgentService._();

  static const Duration _timeout = Duration(seconds: 18);

  static const List<_RssSource> _sources = [
    _RssSource(
      url:
          'https://news.google.com/rss/search?q=agriculture+india+schemes+loans+irrigation+farmers&hl=en-IN&gl=IN&ceid=IN:en',
      languageTag: 'en',
      defaultCategory: 'general',
      sourceTag: 'Google News',
    ),
    _RssSource(
      url:
          'https://news.google.com/rss/search?q=Tamil+agriculture+news+farmers+scheme+loan&hl=ta&gl=IN&ceid=IN:ta',
      languageTag: 'ta',
      defaultCategory: 'general',
      sourceTag: 'Google News',
    ),
    _RssSource(
      url:
          'https://news.google.com/rss/search?q=தமிழ்+விவசாயம்+செய்திகள்+திட்டம்+கடன்&hl=ta&gl=IN&ceid=IN:ta',
      languageTag: 'ta',
      defaultCategory: 'general',
      sourceTag: 'Google News',
    ),
    _RssSource(
      url:
          'https://news.google.com/rss/search?q=Malayalam+agriculture+farmers+loan+scheme&hl=ml&gl=IN&ceid=IN:ml',
      languageTag: 'ml',
      defaultCategory: 'general',
      sourceTag: 'Google News',
    ),
    _RssSource(
      url:
          'https://news.google.com/rss/search?q=മലയാളം+കൃഷി+വാർത്ത+പദ്ധതി+വായ്പ&hl=ml&gl=IN&ceid=IN:ml',
      languageTag: 'ml',
      defaultCategory: 'general',
      sourceTag: 'Google News',
    ),
    _RssSource(
      url: 'https://www.thehindu.com/sci-tech/agriculture/feeder/default.rss',
      languageTag: 'en',
      defaultCategory: 'market',
      sourceTag: 'The Hindu',
    ),
    _RssSource(
      url:
          'https://news.google.com/rss/search?q=PM+Kisan+subsidy+MSP+crop+insurance+agriculture+policy&hl=en-IN&gl=IN&ceid=IN:en',
      languageTag: 'en',
      defaultCategory: 'policy',
      sourceTag: 'Google News',
    ),
    _RssSource(
      url:
          'https://news.google.com/rss/search?q=agri+loan+interest+subsidy+NABARD+cooperative+bank&hl=en-IN&gl=IN&ceid=IN:en',
      languageTag: 'en',
      defaultCategory: 'loan',
      sourceTag: 'Google News',
    ),
  ];

  static Future<List<FarmNewsItem>> fetchLiveNews({int limit = 40}) async {
    final List<FarmNewsItem> allItems = <FarmNewsItem>[];

    await Future.wait(
      _sources.map((source) async {
        try {
          final sourceItems = await _fetchFromSource(source);
          allItems.addAll(sourceItems);
        } catch (_) {
          // Ignore individual source failures and continue with others.
        }
      }),
    );

    final Map<String, FarmNewsItem> deduplicated = <String, FarmNewsItem>{};
    for (final item in allItems) {
      final key = '${item.sourceUrl}|${item.title}'.toLowerCase().trim();
      deduplicated.putIfAbsent(key, () => item);
    }

    final merged = deduplicated.values.toList(growable: false)
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    if (merged.length <= limit) {
      return merged;
    }
    return merged.take(limit).toList(growable: false);
  }

  static List<Map<String, dynamic>> asAgentJson(List<FarmNewsItem> items) {
    return items.map((item) => item.toAgentJson()).toList(growable: false);
  }

  static Future<List<FarmNewsItem>> _fetchFromSource(_RssSource source) async {
    final response = await http
        .get(
          Uri.parse(source.url),
          headers: const {
            'Accept':
                'application/rss+xml, application/xml, text/xml;q=0.9,*/*;q=0.8',
            'User-Agent':
                'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Mobile Safari/537.36',
          },
        )
        .timeout(_timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('RSS request failed: ${response.statusCode}');
    }

    final rawBody = utf8.decode(response.bodyBytes, allowMalformed: true);
    final doc = XmlDocument.parse(rawBody);
    final List<FarmNewsItem> items = <FarmNewsItem>[];

    for (final node in doc.findAllElements('item')) {
      final title = _readNode(node, 'title').trim();
      if (title.isEmpty) {
        continue;
      }

      final link = _normalizeUrl(_readNode(node, 'link').trim());
      final rawDescription = _readNode(node, 'description');
      final summary = _cleanText(rawDescription);
      final sourceName = _extractSourceName(node, title, source.sourceTag);
      final publishedAt = _parseDate(_readNode(node, 'pubDate'));
      final imageUrl = _extractImageUrl(node, rawDescription);
      final category = _detectCategory(
        '$title $summary',
        fallback: source.defaultCategory,
      );

      final tags = _extractTags(
        '$title $summary',
        languageTag: source.languageTag,
        category: category,
      );

      items.add(
        FarmNewsItem(
          id: _stableId(title, link),
          title: title,
          subtitle: summary.isEmpty ? title : summary,
          category: category,
          publishedAt: publishedAt,
          sourceName: sourceName,
          sourceUrl: link,
          imageUrl: imageUrl,
          tags: tags,
        ),
      );
    }

    return items;
  }

  static String _readNode(XmlElement element, String name) {
    final direct = element.findElements(name);
    if (direct.isNotEmpty) {
      return direct.first.innerText;
    }

    final namespaced = element.findAllElements(name);
    if (namespaced.isNotEmpty) {
      return namespaced.first.innerText;
    }

    return '';
  }

  static String _extractSourceName(
    XmlElement item,
    String title,
    String fallback,
  ) {
    final sourceNode = _readNode(item, 'source').trim();
    if (sourceNode.isNotEmpty) {
      return sourceNode;
    }

    final titleParts = title.split(' - ');
    if (titleParts.length > 1) {
      return titleParts.last.trim();
    }

    return fallback;
  }

  static DateTime _parseDate(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed != null) {
      return parsed.toUtc();
    }
    return DateTime.now().toUtc();
  }

  static String _extractImageUrl(XmlElement item, String rawDescription) {
    final mediaContent = item.findAllElements('media:content');
    if (mediaContent.isNotEmpty) {
      final url = mediaContent.first.getAttribute('url') ?? '';
      if (url.isNotEmpty) {
        return _normalizeUrl(url);
      }
    }

    final enclosure = item.findElements('enclosure');
    if (enclosure.isNotEmpty) {
      final url = enclosure.first.getAttribute('url') ?? '';
      if (url.isNotEmpty) {
        return _normalizeUrl(url);
      }
    }

    final imgPattern = RegExp(
      r'''<img[^>]+src=["']([^"']+)["']''',
      caseSensitive: false,
    );
    final match = imgPattern.firstMatch(rawDescription);
    if (match != null && (match.groupCount >= 1)) {
      return _normalizeUrl(match.group(1) ?? '');
    }

    return '';
  }

  static String _normalizeUrl(String url) {
    if (url.isEmpty) {
      return '';
    }
    return url.replaceAll('&amp;', '&').trim();
  }

  static String _cleanText(String rawHtml) {
    if (rawHtml.isEmpty) {
      return '';
    }

    var text = rawHtml;
    text = text.replaceAll(RegExp(r'<!\[CDATA\[|\]\]>'), ' ');
    text = text.replaceAll(RegExp(r'<[^>]*>'), ' ');
    text = text.replaceAll('&nbsp;', ' ');
    text = text.replaceAll('&amp;', '&');
    text = text.replaceAll('&quot;', '"');
    text = text.replaceAll('&#39;', "'");
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (text.length > 260) {
      return '${text.substring(0, 257)}...';
    }

    return text;
  }

  static String _detectCategory(String text, {required String fallback}) {
    final normalized = text.toLowerCase();

    const policyWords = <String>[
      'scheme',
      'subsidy',
      'policy',
      'pm-kisan',
      'yojana',
      'tittam',
      'thittam',
      'திட்டம்',
      'പദ്ധതി',
      'grant',
    ];

    const loanWords = <String>[
      'loan',
      'credit',
      'interest',
      'bank',
      'kcc',
      'nabard',
      'വായ്പ',
      'കടം',
      'கடன்',
      'வங்கி',
    ];

    const marketWords = <String>[
      'msp',
      'price',
      'market',
      'mandi',
      'auction',
      'rate',
      'വില',
      'விலை',
      'சந்தை',
    ];

    if (policyWords.any(normalized.contains)) {
      return 'policy';
    }
    if (loanWords.any(normalized.contains)) {
      return 'loan';
    }
    if (marketWords.any(normalized.contains)) {
      return 'market';
    }

    return fallback;
  }

  static List<String> _extractTags(
    String text, {
    required String languageTag,
    required String category,
  }) {
    final normalized = text.toLowerCase();
    final Set<String> tags = <String>{category, languageTag};

    final Map<String, List<String>> topicKeywords = <String, List<String>>{
      'irrigation': [
        'irrigation',
        'drip',
        'sprinkler',
        'நீர்ப்பாசனம்',
        'ജലസേചനം',
      ],
      'scheme': ['scheme', 'subsidy', 'திட்டம்', 'പദ്ധതി'],
      'loan': ['loan', 'credit', 'வங்கி', 'bank', 'വായ്പ'],
      'market': ['market', 'price', 'mandi', 'விலை', 'വില'],
      'insurance': [
        'insurance',
        'crop insurance',
        'பயிர் காப்பீடு',
        'വിള ഇൻഷുറൻസ്',
      ],
      'weather': ['rain', 'monsoon', 'weather', 'மழை', 'മഴ'],
    };

    topicKeywords.forEach((tag, words) {
      if (words.any(normalized.contains)) {
        tags.add(tag);
      }
    });

    return tags.take(6).toList(growable: false);
  }

  static String _stableId(String title, String link) {
    final input = '$title|$link'.toLowerCase().trim();
    return sha1.convert(utf8.encode(input)).toString();
  }
}

class _RssSource {
  const _RssSource({
    required this.url,
    required this.languageTag,
    required this.defaultCategory,
    required this.sourceTag,
  });

  final String url;
  final String languageTag;
  final String defaultCategory;
  final String sourceTag;
}
