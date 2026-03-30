import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:krishi_sakhi/components/drawer.dart';
import 'package:krishi_sakhi/l10n/app_localizations.dart';
import 'package:krishi_sakhi/screens/Project_Details/bottom_nav_proj.dart';
import 'package:krishi_sakhi/screens/form_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _weatherFuture = _fetchWeather();
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
                    _buildSectionHeader(context, l10n.latestNews, ''),
                    const SizedBox(height: 14),
                    _buildAnnouncementSection(context, l10n),
                    const SizedBox(height: 28),
                    _buildSectionHeader(context, l10n.projects, ''),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildProjectCard(context, index, l10n),
                  childCount: 3,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
    String action,
  ) {
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
            onPressed: () {},
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

  Widget _buildProjectCard(
    BuildContext context,
    int index,
    AppLocalizations l10n,
  ) {
    final crops = [l10n.rice, l10n.vegetables, l10n.coconut];
    final dates = [l10n.startedMay, l10n.startedJun, l10n.startedApr];
    final progress = [0.7, 0.35, 0.9];
    final bgColors = [
      const Color(0xFFE8F5E9),
      const Color(0xFFF1F8E9),
      const Color(0xFFDCEDC8),
    ];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProjectScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: bgColors[index],
          border: Border.all(
            color: const Color(0xFF4CAF50).withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProjectScreen()),
              );
            },
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF4CAF50).withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.grass_rounded,
                          color: Color(0xFF2E7D32),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              index == 0
                                  ? l10n.riceField
                                  : '${crops[index]} ${l10n.fieldSuffix}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Color(0xFF1B5E20),
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dates[index],
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF689F38),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              index == 1
                                  ? Colors.orange.withOpacity(0.15)
                                  : const Color(0xFF2E7D32).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                index == 1
                                    ? Colors.orange.withOpacity(0.3)
                                    : const Color(0xFF2E7D32).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          index == 1 ? l10n.needsAttention : l10n.onTrack,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                index == 1
                                    ? Colors.orange.shade800
                                    : const Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.progress,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF424242),
                            ),
                          ),
                          Text(
                            '${(progress[index] * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: progress[index],
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            index == 1
                                ? Colors.orange.shade400
                                : const Color(0xFF4CAF50),
                          ),
                          minHeight: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            index == 1
                                ? Colors.orange.withOpacity(0.2)
                                : const Color(0xFF4CAF50).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.water_drop_rounded,
                          color:
                              index == 1
                                  ? Colors.orange.shade700
                                  : const Color(0xFF2E7D32),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          index == 1
                              ? l10n.irrigationNeeded
                              : l10n.wateredToday,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color:
                                index == 1
                                    ? Colors.orange.shade800
                                    : const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementSection(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final announcements = [
      {
        'title': l10n.riceMSPUpdate,
        'type': 'market',
        'subtitle': l10n.mspEffectiveDate,
      },
      {
        'title': l10n.pmKisanUpdate,
        'type': 'scheme',
        'subtitle': l10n.schemeDeadline,
      },
      {
        'title': l10n.marketUpdate,
        'type': 'market',
        'subtitle': l10n.marketSubtitle,
      },
      {
        'title': l10n.schemeSubsidy,
        'type': 'scheme',
        'subtitle': l10n.schemeSubsidySubtitle,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: announcements.length,
          separatorBuilder:
              (context, index) => Divider(
                height: 1,
                color: Colors.grey.shade200,
                indent: 16,
                endIndent: 16,
              ),
          itemBuilder: (context, index) {
            final item = announcements[index];
            final isMarket = item['type'] == 'market';

            return Material(
              color:
                  isMarket
                      ? const Color(0xFFE8F5E9).withOpacity(0.5)
                      : const Color(0xFFE8EAF6).withOpacity(0.5),
              child: InkWell(
                onTap: () {},
                splashColor: (isMarket
                        ? const Color(0xFF388E3C)
                        : const Color(0xFF3949AB))
                    .withOpacity(0.12),
                highlightColor: (isMarket
                        ? const Color(0xFF388E3C)
                        : const Color(0xFF3949AB))
                    .withOpacity(0.06),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 18,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              isMarket
                                  ? const Color(0xFFE8F5E9)
                                  : const Color(0xFFE8EAF6),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: (isMarket
                                    ? const Color(0xFF388E3C)
                                    : const Color(0xFF3949AB))
                                .withOpacity(0.25),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isMarket
                                      ? const Color(0xFF388E3C)
                                      : const Color(0xFF3949AB))
                                  .withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isMarket
                              ? Icons.trending_up_rounded
                              : Icons.policy_outlined,
                          size: 20,
                          color:
                              isMarket
                                  ? const Color(0xFF388E3C)
                                  : const Color(0xFF3949AB),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title']!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color:
                                    isMarket
                                        ? const Color(0xFF1B5E20)
                                        : const Color(0xFF283593),
                                letterSpacing: 0.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item['subtitle']!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
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
        title: const Text(
          'Weather Insights',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
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
                      Text(
                        weather.locationName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        weather.conditionText,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            weather.isDay
                                ? Icons.wb_sunny_rounded
                                : Icons.nightlight_round,
                            color: Colors.white,
                            size: 64,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${weather.tempC.round()}°C',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 64,
                              fontWeight: FontWeight.w700,
                              height: 0.95,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
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
                                  Icons.spa_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Farmer Advisory',
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
                              icon: Icons.grass_rounded,
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
        color: Colors.white.withOpacity(0.14),
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
