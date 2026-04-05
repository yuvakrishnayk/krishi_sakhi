import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:krishi_sakhi/components/drawer.dart';
import 'package:krishi_sakhi/l10n/app_localizations.dart';
import 'package:krishi_sakhi/models/home_feed_models.dart';
import 'package:krishi_sakhi/screens/form_screen.dart';
import 'package:krishi_sakhi/screens/news_list_screen.dart';
import 'package:krishi_sakhi/screens/projects_list_screen.dart';
import 'package:krishi_sakhi/services/home_feed_local_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static const String _weatherApiUrl = String.fromEnvironment(
    'WEATHER_API_URL',
    defaultValue: 'http://api.weatherapi.com/v1/current.json',
  );
  static const String _weatherApiKey = String.fromEnvironment(
    'WEATHER_API_KEY',
    defaultValue: '762c1e6ce536412aa8b71612261803',
  );
  static const String _defaultWeatherQuery = 'Thrissur';

  late Future<_WeatherData> _weatherFuture;
  late Future<List<FarmNewsItem>> _newsPreviewFuture;
  late Future<List<FarmProjectItem>> _projectsPreviewFuture;

  @override
  void initState() {
    super.initState();
    _weatherFuture = _fetchWeather();
    _newsPreviewFuture = _loadNewsPreview();
    _projectsPreviewFuture = _loadProjectsPreview();
  }

  Future<List<FarmNewsItem>> _loadNewsPreview() async {
    await HomeFeedLocalStorage.ensureSeedData();
    final items = await HomeFeedLocalStorage.getNews();
    items.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return items.take(2).toList(growable: false);
  }

  Future<List<FarmProjectItem>> _loadProjectsPreview() async {
    await HomeFeedLocalStorage.ensureSeedData();
    final items = await HomeFeedLocalStorage.getProjects();
    return items.take(2).toList(growable: false);
  }

  void _toggleDrawer() {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeDrawer();
    } else {
      _scaffoldKey.currentState?.openDrawer();
    }
  }

  Future<String> _resolveWeatherQuery() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _defaultWeatherQuery;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return _defaultWeatherQuery;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return '${position.latitude},${position.longitude}';
    } catch (_) {
      return _defaultWeatherQuery;
    }
  }

  Future<_WeatherData> _fetchWeather() async {
    final query = await _resolveWeatherQuery();
    final uri = Uri.parse(_weatherApiUrl).replace(
      queryParameters: {'key': _weatherApiKey, 'q': query, 'aqi': 'no'},
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load weather data (${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return _WeatherData.fromJson(body);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: Text(
          l10n.appTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
          onPressed: _toggleDrawer,
          tooltip: l10n.openNavigationMenu,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.settings_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              splashRadius: 24,
              tooltip: l10n.settings,
              onPressed: () {},
            ),
          ),
        ],
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildDailyTipCard(context, l10n),
                    const SizedBox(height: 24),
                    _buildWeatherSection(context, l10n),
                    const SizedBox(height: 28),
                    _buildSectionHeader(context, 'Crop Calendar', ''),
                    const SizedBox(height: 14),
                    _buildCropCalendarSection(),
                    const SizedBox(height: 28),
                    _buildSectionHeader(
                      context,
                      l10n.latestNews,
                      'View All',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NewsListScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildNewsPreviewSection(),
                    const SizedBox(height: 28),
                    _buildSectionHeader(
                      context,
                      l10n.projects,
                      'View All',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProjectsListScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildProjectsPreviewSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1).animate(
          CurvedAnimation(
            parent:
                ModalRoute.of(context)?.animation ?? AlwaysStoppedAnimation(1),
            curve: Curves.elasticOut,
          ),
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FormScreens()),
            );
          },
          backgroundColor: const Color(0xFF2E7D32),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildDailyTipCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF1F8E9),
            const Color(0xFFC8E6C9).withOpacity(0.7),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF4CAF50).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF4CAF50).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.lightbulb_rounded,
                    color: Color(0xFF2E7D32),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dailyTip,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Color(0xFF1B5E20),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.monsoonAlert,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              l10n.monsoonMessage,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Color(0xFF424242),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_circle_outline_rounded, size: 20),
              label: Text(
                l10n.playAudio,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherSection(BuildContext context, AppLocalizations l10n) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      _WeatherFullscreenPage(loadWeather: _fetchWeather),
            ),
          );
        },
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1565C0).withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FutureBuilder<_WeatherData>(
            future: _weatherFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: _WeatherLoadingScene(
                    headline: 'Fetching live weather...',
                    compact: true,
                  ),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.thrissurLocation,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Unable to fetch weather right now.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _weatherFuture = _fetchWeather();
                        });
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                );
              }

              final weather = snapshot.data!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              weather.locationName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                weather.conditionText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            weather.isDay
                                ? Icons.wb_sunny_rounded
                                : Icons.nights_stay_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${weather.tempC.round()}°',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildWeatherMetricChip(
                        icon: Icons.thermostat_rounded,
                        label: 'Feels Like',
                        value: '${weather.feelsLikeC.round()}°',
                      ),
                      _buildWeatherMetricChip(
                        icon: Icons.water_drop_rounded,
                        label: 'Humidity',
                        value: '${weather.humidity}%',
                      ),
                      _buildWeatherMetricChip(
                        icon: Icons.air_rounded,
                        label: 'Wind',
                        value: '${weather.windKph.round()} km/h',
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherMetricChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String action, {
    VoidCallback? onPressed,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B5E20),
            letterSpacing: 0.3,
          ),
        ),
        if (action.isNotEmpty)
          TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              action,
              style: const TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCropCalendarSection() {
    return FutureBuilder<List<FarmProjectItem>>(
      future: _projectsPreviewFuture,
      builder: (context, snapshot) {
        final projects = snapshot.data ?? const <FarmProjectItem>[];
        final cropName = projects.isNotEmpty ? projects.first.crop : 'Rice';
        final calendar = _buildCalendarActivities(cropName);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.event_note_rounded,
                      size: 20,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$cropName season timeline',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Upcoming 4-week task plan',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...calendar.map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item['bg'] as Color,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: (item['color'] as Color).withOpacity(0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: (item['color'] as Color).withOpacity(0.16),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: item['color'] as Color,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] as String,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['subtitle'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                                height: 1.3,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item['date'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, Object>> _buildCalendarActivities(String cropName) {
    final now = DateTime.now();
    final crop = cropName.toLowerCase();

    final String week1Title;
    final String week2Title;
    final String week3Title;
    final String week4Title;

    if (crop.contains('rice') || crop.contains('paddy')) {
      week1Title = 'Nursery and water-level check';
      week2Title = 'Transplanting and spacing';
      week3Title = 'Top-dressing and weed control';
      week4Title = 'Pest scouting and field drainage';
    } else if (crop.contains('wheat')) {
      week1Title = 'Land prep and seed treatment';
      week2Title = 'Sowing depth and first irrigation';
      week3Title = 'Weed check and nutrient split dose';
      week4Title = 'Rust and aphid monitoring';
    } else {
      week1Title = 'Field prep and soil moisture check';
      week2Title = 'Sowing and germination monitoring';
      week3Title = 'Nutrient top-up and weed cleanup';
      week4Title = 'Pest scouting and growth review';
    }

    return [
      {
        'title': week1Title,
        'subtitle': 'Prepare tools and complete baseline field inspection.',
        'date': _shortDate(now),
        'icon': Icons.agriculture_rounded,
        'color': const Color(0xFF2E7D32),
        'bg': const Color(0xFFE8F5E9),
      },
      {
        'title': week2Title,
        'subtitle': 'Focus on uniform crop stand and irrigation rhythm.',
        'date': _shortDate(now.add(const Duration(days: 7))),
        'icon': Icons.water_drop_rounded,
        'color': const Color(0xFF1565C0),
        'bg': const Color(0xFFE3F2FD),
      },
      {
        'title': week3Title,
        'subtitle': 'Track growth and resolve early nutrient stress signs.',
        'date': _shortDate(now.add(const Duration(days: 14))),
        'icon': Icons.spa_rounded,
        'color': const Color(0xFF6A1B9A),
        'bg': const Color(0xFFF3E5F5),
      },
      {
        'title': week4Title,
        'subtitle': 'Review alerts and plan next month activities.',
        'date': _shortDate(now.add(const Duration(days: 21))),
        'icon': Icons.analytics_rounded,
        'color': const Color(0xFFE65100),
        'bg': const Color(0xFFFFF3E0),
      },
    ];
  }

  String _shortDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  Widget _buildNewsPreviewSection() {
    return FutureBuilder<List<FarmNewsItem>>(
      future: _newsPreviewFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 110,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2.2)),
          );
        }

        final news = snapshot.data ?? const <FarmNewsItem>[];
        if (news.isEmpty) {
          return _buildEmptyPreviewCard(
            icon: Icons.feed_outlined,
            title: 'No local news yet',
            subtitle: 'Open News page to refresh and view offline items.',
          );
        }

        return Column(
          children: news
              .map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          item.category == 'market'
                              ? const Color(0xFF388E3C).withOpacity(0.2)
                              : const Color(0xFF3949AB).withOpacity(0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: (item.category == 'market'
                              ? const Color(0xFF388E3C)
                              : const Color(0xFF3949AB))
                          .withOpacity(0.15),
                      child: Icon(
                        item.category == 'market'
                            ? Icons.trending_up_rounded
                            : Icons.policy_outlined,
                        color:
                            item.category == 'market'
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFF3949AB),
                      ),
                    ),
                    title: Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    subtitle: Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NewsListScreen(),
                        ),
                      );
                    },
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }

  Widget _buildProjectsPreviewSection() {
    return FutureBuilder<List<FarmProjectItem>>(
      future: _projectsPreviewFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 110,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2.2)),
          );
        }

        final projects = snapshot.data ?? const <FarmProjectItem>[];
        if (projects.isEmpty) {
          return _buildEmptyPreviewCard(
            icon: Icons.agriculture_rounded,
            title: 'No local projects yet',
            subtitle: 'Open Projects page to refresh and view offline items.',
          );
        }

        return Column(
          children: projects
              .map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: const Color(0xFF4CAF50).withOpacity(0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    leading: const CircleAvatar(
                      backgroundColor: Color(0x1F2E7D32),
                      child: Icon(
                        Icons.grass_rounded,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    title: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    subtitle: Text(
                      '${item.crop} | ${(item.progress * 100).toInt()}% complete',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey.shade500,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProjectsListScreen(),
                        ),
                      );
                    },
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }

  Widget _buildEmptyPreviewCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2E7D32), size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherData {
  const _WeatherData({
    required this.locationName,
    required this.conditionText,
    required this.tempC,
    required this.humidity,
    required this.windKph,
    required this.feelsLikeC,
    required this.isDay,
    required this.uvIndex,
    required this.precipitationMm,
    required this.pressureMb,
    required this.visibilityKm,
    required this.gustKph,
    required this.windDirection,
    required this.cloudCover,
    required this.lastUpdated,
  });

  final String locationName;
  final String conditionText;
  final double tempC;
  final int humidity;
  final double windKph;
  final double feelsLikeC;
  final bool isDay;
  final double uvIndex;
  final double precipitationMm;
  final double pressureMb;
  final double visibilityKm;
  final double gustKph;
  final String windDirection;
  final int cloudCover;
  final String lastUpdated;

  factory _WeatherData.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;
    final current = json['current'] as Map<String, dynamic>?;
    final condition = current?['condition'] as Map<String, dynamic>?;

    return _WeatherData(
      locationName:
          (location?['name'] as String?) ??
          _HomeScreenState._defaultWeatherQuery,
      conditionText: (condition?['text'] as String?) ?? 'N/A',
      tempC: (current?['temp_c'] as num?)?.toDouble() ?? 0,
      humidity: (current?['humidity'] as num?)?.toInt() ?? 0,
      windKph: (current?['wind_kph'] as num?)?.toDouble() ?? 0,
      feelsLikeC: (current?['feelslike_c'] as num?)?.toDouble() ?? 0,
      isDay: (current?['is_day'] as num?) == 1,
      uvIndex: (current?['uv'] as num?)?.toDouble() ?? 0,
      precipitationMm: (current?['precip_mm'] as num?)?.toDouble() ?? 0,
      pressureMb: (current?['pressure_mb'] as num?)?.toDouble() ?? 0,
      visibilityKm: (current?['vis_km'] as num?)?.toDouble() ?? 0,
      gustKph: (current?['gust_kph'] as num?)?.toDouble() ?? 0,
      windDirection: (current?['wind_dir'] as String?) ?? 'N/A',
      cloudCover: (current?['cloud'] as num?)?.toInt() ?? 0,
      lastUpdated: (current?['last_updated'] as String?) ?? 'N/A',
    );
  }
}

class _WeatherFullscreenPage extends StatefulWidget {
  const _WeatherFullscreenPage({required this.loadWeather});

  final Future<_WeatherData> Function() loadWeather;

  @override
  State<_WeatherFullscreenPage> createState() => _WeatherFullscreenPageState();
}

class _WeatherFullscreenPageState extends State<_WeatherFullscreenPage> {
  late Future<_WeatherData> _weatherFuture;

  @override
  void initState() {
    super.initState();
    _weatherFuture = widget.loadWeather();
  }

  void _reload() {
    setState(() {
      _weatherFuture = widget.loadWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0D47A1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Row(
          children: [
            Icon(Icons.agriculture_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Farm Weather Hub',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: _WeatherWaveBackground()),
          SafeArea(
            child: FutureBuilder<_WeatherData>(
              future: _weatherFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: _WeatherLoadingScene(
                        headline: 'Preparing detailed weather insights...',
                      ),
                    ),
                  );
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_off_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Unable to load weather data.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              onPressed: _reload,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Try Again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final weather = snapshot.data!;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroPanel(weather),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _FullscreenMetricChip(
                            icon: Icons.thermostat_rounded,
                            title: 'Feels Like',
                            value: '${weather.feelsLikeC.round()}°C',
                          ),
                          _FullscreenMetricChip(
                            icon: Icons.water_drop_rounded,
                            title: 'Humidity',
                            value: '${weather.humidity}%',
                          ),
                          _FullscreenMetricChip(
                            icon: Icons.air_rounded,
                            title: 'Wind Speed',
                            value: '${weather.windKph.round()} km/h',
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _buildAgriImpactBoard(weather),
                      const SizedBox(height: 16),
                      _buildActionPlan(weather),
                      const SizedBox(height: 16),
                      _DetailedWeatherPanel(weather: weather),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withOpacity(0.25),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.eco_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Agriculture Advisory',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _buildAdvisory(weather),
                              style: const TextStyle(
                                color: Colors.white,
                                height: 1.5,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _AdvisoryBullet(
                              icon: Icons.biotech_rounded,
                              text: _diseaseRiskAdvice(weather),
                            ),
                            const SizedBox(height: 8),
                            _AdvisoryBullet(
                              icon: Icons.wb_sunny_outlined,
                              text: _uvProtectionAdvice(weather),
                            ),
                            const SizedBox(height: 8),
                            _AdvisoryBullet(
                              icon: Icons.water_drop_outlined,
                              text: _irrigationAdvice(weather),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: _reload,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Refresh Weather'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroPanel(_WeatherData weather) {
    final score = _fieldReadinessScore(weather);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0A2C66), Color(0xFF125DA2), Color(0xFF1E88D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.22), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D47A1).withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.locationName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      weather.conditionText,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  weather.isDay ? 'Day Mode' : 'Night Mode',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                weather.isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                color: Colors.white,
                size: 58,
              ),
              const SizedBox(width: 10),
              Text(
                '${weather.tempC.round()}°C',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.w700,
                  height: 0.95,
                ),
              ),
              const Spacer(),
              _ReadinessRing(score: score),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  color: Colors.white70,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Last update: ${weather.lastUpdated}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  _sprayWindow(weather),
                  style: const TextStyle(
                    color: Color(0xFFA5D6A7),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgriImpactBoard(_WeatherData weather) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Agriculture Impact Board',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ImpactTile(
                icon: Icons.opacity_rounded,
                label: 'Irrigation',
                value: _irrigationUrgency(weather),
              ),
              _ImpactTile(
                icon: Icons.biotech_rounded,
                label: 'Disease Pressure',
                value: _diseasePressure(weather),
              ),
              _ImpactTile(
                icon: Icons.sanitizer_rounded,
                label: 'Spray Window',
                value: _sprayWindow(weather),
              ),
              _ImpactTile(
                icon: Icons.pets_rounded,
                label: 'Livestock Comfort',
                value: _livestockComfort(weather),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionPlan(_WeatherData weather) {
    final actions = _priorityActions(weather);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0C3A7A).withOpacity(0.45),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Priority Field Action Plan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          for (final action in actions) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFFA5D6A7),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    action,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  int _fieldReadinessScore(_WeatherData weather) {
    var score = 100;

    if (weather.windKph > 25) score -= 20;
    if (weather.humidity > 85) score -= 15;
    if (weather.tempC > 35) score -= 18;
    if (weather.precipitationMm > 5) score -= 20;
    if (weather.uvIndex > 8) score -= 10;

    return score.clamp(25, 100);
  }

  String _sprayWindow(_WeatherData weather) {
    if (weather.windKph > 18 || weather.precipitationMm > 1.5) {
      return 'Avoid Spray';
    }
    if (weather.uvIndex >= 7) {
      return 'Spray Early AM';
    }
    return 'Good Spray Window';
  }

  String _irrigationUrgency(_WeatherData weather) {
    if (weather.precipitationMm >= 4) return 'Low today';
    if (weather.tempC >= 34 && weather.humidity < 55) return 'High';
    if (weather.tempC >= 31) return 'Moderate';
    return 'Normal';
  }

  String _diseasePressure(_WeatherData weather) {
    if (weather.humidity >= 85 && weather.cloudCover >= 60) return 'High';
    if (weather.humidity >= 70) return 'Moderate';
    return 'Low';
  }

  String _livestockComfort(_WeatherData weather) {
    if (weather.tempC >= 35) return 'Heat stress risk';
    if (weather.tempC <= 18 && !weather.isDay) return 'Cool night care';
    return 'Comfortable';
  }

  List<String> _priorityActions(_WeatherData weather) {
    final actions = <String>[];

    if (weather.precipitationMm >= 3) {
      actions.add(
        'Reduce irrigation for the next cycle and inspect low-lying zones for water stagnation.',
      );
    } else if (weather.tempC >= 33) {
      actions.add(
        'Plan split irrigation in early morning and evening to reduce crop heat stress.',
      );
    }

    if (weather.humidity >= 80) {
      actions.add(
        'Increase canopy ventilation and scout for early fungal symptoms in dense crop sections.',
      );
    }

    if (weather.windKph > 20) {
      actions.add(
        'Postpone pesticide spraying and secure young plants or trellis-supported crops.',
      );
    }

    if (weather.uvIndex >= 8) {
      actions.add(
        'Shift labor-intensive tasks to before 11 AM or after 4 PM and ensure hydration breaks.',
      );
    }

    if (actions.isEmpty) {
      actions.add(
        'Field conditions are favorable. Continue routine irrigation, scouting, and nutrient scheduling.',
      );
      actions.add(
        'Use this stable window for weeding, light nutrient application, and preventive crop care.',
      );
    }

    return actions;
  }

  String _buildAdvisory(_WeatherData weather) {
    if (weather.humidity > 80) {
      return 'High humidity detected. Prefer early-morning irrigation and monitor crops for fungal infection signs.';
    }
    if (weather.tempC > 34) {
      return 'High heat expected. Increase mulching and provide light irrigation to reduce water stress on crops.';
    }
    if (weather.windKph > 20) {
      return 'Wind speed is high. Avoid pesticide spray now and secure young plants with support if needed.';
    }
    return 'Weather is stable for regular field activities. Keep monitoring soil moisture and continue scheduled crop care.';
  }

  String _diseaseRiskAdvice(_WeatherData weather) {
    if (weather.humidity >= 85 && weather.cloudCover >= 60) {
      return 'Disease risk: High. Inspect lower leaves for fungal spots and avoid evening overhead watering.';
    }
    if (weather.humidity >= 70) {
      return 'Disease risk: Moderate. Improve field ventilation and keep foliage dry during irrigation.';
    }
    return 'Disease risk: Low. Continue routine crop scouting and sanitation practices.';
  }

  String _uvProtectionAdvice(_WeatherData weather) {
    if (weather.uvIndex >= 8) {
      return 'UV level is very high. Schedule labor-intensive tasks before 11 AM or after 4 PM.';
    }
    if (weather.uvIndex >= 6) {
      return 'UV level is high. Ensure workers use hats and keep drinking water available in the field.';
    }
    return 'UV level is manageable for regular daytime operations.';
  }

  String _irrigationAdvice(_WeatherData weather) {
    if (weather.precipitationMm >= 3) {
      return 'Recent rainfall detected. Reduce today\'s irrigation cycle to avoid waterlogging.';
    }
    if (weather.tempC >= 34 && weather.humidity <= 55) {
      return 'Dry heat conditions. Consider split irrigation in early morning and late evening.';
    }
    return 'Maintain normal irrigation schedule while checking soil moisture before each cycle.';
  }
}

class _DetailedWeatherPanel extends StatelessWidget {
  const _DetailedWeatherPanel({required this.weather});

  final _WeatherData weather;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weather Insight Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _DetailTile(
                icon: Icons.shield_outlined,
                label: 'UV Index',
                value: weather.uvIndex.toStringAsFixed(1),
              ),
              _DetailTile(
                icon: Icons.grain_rounded,
                label: 'Rainfall',
                value: '${weather.precipitationMm.toStringAsFixed(1)} mm',
              ),
              _DetailTile(
                icon: Icons.speed_rounded,
                label: 'Pressure',
                value: '${weather.pressureMb.toStringAsFixed(0)} mb',
              ),
              _DetailTile(
                icon: Icons.remove_red_eye_outlined,
                label: 'Visibility',
                value: '${weather.visibilityKm.toStringAsFixed(1)} km',
              ),
              _DetailTile(
                icon: Icons.air,
                label: 'Wind Gust',
                value: '${weather.gustKph.toStringAsFixed(0)} km/h',
              ),
              _DetailTile(
                icon: Icons.explore_outlined,
                label: 'Wind Dir',
                value: weather.windDirection,
              ),
              _DetailTile(
                icon: Icons.filter_drama_outlined,
                label: 'Cloud Cover',
                value: '${weather.cloudCover}%',
              ),
              _DetailTile(
                icon: Icons.update_rounded,
                label: 'Updated',
                value: weather.lastUpdated,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.16), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvisoryBullet extends StatelessWidget {
  const _AdvisoryBullet({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              height: 1.4,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _WeatherLoadingScene extends StatefulWidget {
  const _WeatherLoadingScene({required this.headline, this.compact = false});

  final String headline;
  final bool compact;

  @override
  State<_WeatherLoadingScene> createState() => _WeatherLoadingSceneState();
}

class _WeatherLoadingSceneState extends State<_WeatherLoadingScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sceneHeight = widget.compact ? 96.0 : 128.0;
    final titleSize = widget.compact ? 13.0 : 15.0;
    final subtitleSize = widget.compact ? 11.0 : 12.0;
    final horizontalPadding = widget.compact ? 10.0 : 16.0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final cloudShiftA = math.sin(t * math.pi * 2) * 9;
        final cloudShiftB = math.sin((t * math.pi * 2) + 1.3) * 11;
        final rainPulse = (math.sin((t * math.pi * 2) + 0.8) + 1) / 2;
        final sunRotation = t * math.pi * 2;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: sceneHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    right: widget.compact ? 18 : 24,
                    top: widget.compact ? 4 : 2,
                    child: Transform.rotate(
                      angle: sunRotation,
                      child: Icon(
                        Icons.wb_sunny_rounded,
                        size: widget.compact ? 30 : 40,
                        color: const Color(0xFFFFF176),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10 + cloudShiftA,
                    top: widget.compact ? 24 : 28,
                    child: _CloudBlob(
                      width: widget.compact ? 84 : 102,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  Positioned(
                    right: 10 + cloudShiftB,
                    top: widget.compact ? 36 : 46,
                    child: _CloudBlob(
                      width: widget.compact ? 64 : 78,
                      color: Colors.white.withOpacity(0.72),
                    ),
                  ),
                  Positioned(
                    left: widget.compact ? 24 : 30,
                    bottom: widget.compact ? 2 : 4,
                    child: Row(
                      children: [
                        _RainDrop(opacity: 0.3 + (rainPulse * 0.6), height: 14),
                        const SizedBox(width: 6),
                        _RainDrop(
                          opacity: 0.3 + ((1 - rainPulse) * 0.6),
                          height: 18,
                        ),
                        const SizedBox(width: 6),
                        _RainDrop(opacity: 0.3 + (rainPulse * 0.5), height: 12),
                        const SizedBox(width: 6),
                        _RainDrop(
                          opacity: 0.3 + ((1 - rainPulse) * 0.55),
                          height: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                children: [
                  Text(
                    widget.headline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: titleSize,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Checking location, clouds, and wind patterns...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.84),
                      fontWeight: FontWeight.w500,
                      fontSize: subtitleSize,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      minHeight: widget.compact ? 6 : 7,
                      value: null,
                      backgroundColor: Colors.white.withOpacity(0.18),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFA5D6A7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CloudBlob extends StatelessWidget {
  const _CloudBlob({required this.width, required this.color});

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final height = width * 0.48;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned(
            left: width * 0.08,
            top: height * 0.24,
            child: Container(
              width: width * 0.38,
              height: height * 0.58,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          Positioned(
            left: width * 0.28,
            top: 0,
            child: Container(
              width: width * 0.42,
              height: height * 0.74,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          Positioned(
            right: width * 0.08,
            top: height * 0.2,
            child: Container(
              width: width * 0.34,
              height: height * 0.54,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: height * 0.52,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(height),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RainDrop extends StatelessWidget {
  const _RainDrop({required this.opacity, required this.height});

  final double opacity;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF80DEEA).withOpacity(opacity),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _FullscreenMetricChip extends StatelessWidget {
  const _FullscreenMetricChip({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 160),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.18),
            Colors.white.withOpacity(0.09),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.22), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeatherWaveBackground extends StatelessWidget {
  const _WeatherWaveBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0B2E73), Color(0xFF0F4FA8), Color(0xFF1D7BC6)],
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _WavePainter(
              color: const Color(0xFF80DEEA).withOpacity(0.24),
              amplitude: 26,
              frequency: 1.3,
              shift: 0,
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _WavePainter(
              color: const Color(0xFFA5D6A7).withOpacity(0.2),
              amplitude: 34,
              frequency: 0.9,
              shift: 80,
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _WavePainter(
              color: Colors.white.withOpacity(0.08),
              amplitude: 18,
              frequency: 1.8,
              shift: 190,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReadinessRing extends StatelessWidget {
  const _ReadinessRing({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final progress = score / 100;

    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 6,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFA5D6A7),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$score',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const Text(
                'Ready',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImpactTile extends StatelessWidget {
  const _ImpactTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 155),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.16), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({
    required this.color,
    required this.amplitude,
    required this.frequency,
    required this.shift,
  });

  final Color color;
  final double amplitude;
  final double frequency;
  final double shift;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    final baseline = size.height * 0.58;

    path.moveTo(0, size.height);
    path.lineTo(0, baseline);

    for (double x = 0; x <= size.width; x++) {
      final y =
          baseline +
          amplitude *
              math.sin((x / size.width) * math.pi * 2 * frequency + shift);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.frequency != frequency ||
        oldDelegate.shift != shift;
  }
}
