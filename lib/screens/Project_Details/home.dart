import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:krishi_sakhi/models/farm_project.dart';

// ─── Palette ────────────────────────────────────────────────────────────────
class _K {
  static const soil = Color(0xFF3D2B1F);
  static const forest = Color(0xFF1A4731);
  static const leaf = Color(0xFF2E7D52);
  static const sprout = Color(0xFF4CAF72);
  static const lime = Color(0xFFB5D96A);
  static const harvest = Color(0xFFE8A838);
  static const sky = Color(0xFF4FA8C5);
  static const alert = Color(0xFFD95F3B);
  static const surface = Color(0xFFF4F6F0);
  static const card = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1C2B1C);
  static const textSecondary = Color(0xFF5A6B5A);
  static const divider = Color(0xFFDDE8D8);
}

// ─── Main Screen ─────────────────────────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  final FarmProject? project;
  final Map<String, dynamic>? advisoryResponse;

  const DashboardScreen({super.key, this.project, this.advisoryResponse});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late final AnimationController _heroCtrl;
  late final AnimationController _contentCtrl;
  late final Animation<double> _heroScale;
  late final Animation<double> _heroFade;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  dynamic _rawResponse;
  Map<String, dynamic> _planData = {};
  List<_WeatherAlert> _weatherAlerts = [];
  int _selectedMonthIndex = 0;
  int _selectedDailyIndex = 0;
  bool _showRaw = false;

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _heroScale = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutBack));
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _contentFade = CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut);
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic),
    );

    _loadPlanData();
    _heroCtrl.forward().then((_) => _contentCtrl.forward());
  }

  @override
  void didUpdateWidget(covariant DashboardScreen old) {
    super.didUpdateWidget(old);
    if (old.advisoryResponse != widget.advisoryResponse ||
        old.project != widget.project) {
      _loadPlanData();
    }
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  // ── Data helpers ──────────────────────────────────────────────────────────

  void _loadPlanData() {
    final response = widget.advisoryResponse;
    _rawResponse = response;
    _planData =
        response is Map<String, dynamic>
            ? Map<String, dynamic>.from(response)
            : response is Map
            ? Map<String, dynamic>.from(response as Map<dynamic, dynamic>)
            : {};
    _weatherAlerts = _collectWeatherAlerts(_planData);
    _selectedMonthIndex = 0;
    _selectedDailyIndex = 0;
  }

  List<_WeatherAlert> _collectWeatherAlerts(Map<String, dynamic> planData) {
    final alerts = <_WeatherAlert>[];
    for (final monthEntry in _asList(planData['months'])) {
      final month = _asMap(monthEntry);
      final monthName = month['monthName']?.toString() ?? 'Month';
      for (final weekEntry in _asList(month['weeks'])) {
        final week = _asMap(weekEntry);
        for (final dayEntry in _asList(week['days'])) {
          final day = _asMap(dayEntry);
          final weather = _asMap(day['weather']);
          final advisory = weather['advisory']?.toString().trim() ?? '';
          final temperature = _asMap(weather['temperature']);
          final maxTemp = (temperature['max'] as num?)?.toDouble();
          final minTemp = (temperature['min'] as num?)?.toDouble();
          final humidity = (weather['humidity'] as num?)?.toInt();
          final rainfall = (weather['rainfall'] as num?)?.toInt();
          final windSpeed = (weather['windSpeed'] as num?)?.toInt();
          final condition = weather['condition']?.toString() ?? 'Weather';
          final date = weather['date']?.toString() ?? '';
          final dayNumber = day['dayNumber']?.toString() ?? '';
          final isAlert =
              advisory.isNotEmpty ||
              (maxTemp != null && maxTemp >= 37) ||
              (windSpeed != null && windSpeed >= 28) ||
              (rainfall != null && rainfall > 0);
          if (!isAlert) continue;
          alerts.add(
            _WeatherAlert(
              monthName: monthName,
              dayLabel: 'Day $dayNumber',
              date: date,
              condition: condition,
              advisory:
                  advisory.isNotEmpty
                      ? advisory
                      : 'Weather conditions need attention before field work.',
              minTemp: minTemp,
              maxTemp: maxTemp,
              humidity: humidity,
              rainfall: rainfall,
              windSpeed: windSpeed,
              urgent:
                  (maxTemp != null && maxTemp >= 38) ||
                  (windSpeed != null && windSpeed >= 30) ||
                  advisory.toLowerCase().contains('heat'),
            ),
          );
        }
      }
    }
    return alerts;
  }

  List<dynamic> _asList(dynamic v) => v is List ? v : const [];
  Map<String, dynamic> _asMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v as Map);
    return {};
  }

  String get _cropName {
    final r = _planData['crop']?.toString().trim();
    if (r != null && r.isNotEmpty) return r;
    return widget.project?.cropName.isNotEmpty == true
        ? widget.project!.cropName
        : 'Crop Advisory';
  }

  String get _locationName {
    final summary = _asMap(_planData['summary']);
    final r = summary['location']?.toString().trim();
    if (r != null && r.isNotEmpty) return r;
    return widget.project?.locationName.isNotEmpty == true
        ? widget.project!.locationName
        : 'Your farm';
  }

  String get _summaryText {
    final summary = _asMap(_planData['summary']);
    final v =
        summary['summary']?.toString().trim() ??
        _planData['summary']?.toString().trim();
    if (v != null && v.isNotEmpty) return v;
    if (_rawResponse is String) {
      final raw = (_rawResponse as String).trim();
      if (raw.isNotEmpty) return raw;
    }
    if (_rawResponse is Map) {
      final rawMap = _asMap(_rawResponse);
      final rawText =
          rawMap['answer']?.toString().trim() ??
          rawMap['message']?.toString().trim() ??
          rawMap['raw_response']?.toString().trim();
      if (rawText != null && rawText.isNotEmpty) return rawText;
    }
    final months = _asList(_planData['months']);
    if (months.isNotEmpty) {
      final s = _asMap(months.first)['summary']?.toString().trim();
      if (s != null && s.isNotEmpty) return s;
    }
    return 'No advisory response returned by the endpoint.';
  }

  int get _durationMonths {
    final v = _planData['durationMonths'];
    if (v is num) return v.toInt();
    final months = _asList(_planData['months']);
    return months.isEmpty ? 1 : months.length;
  }

  double? get _landSize {
    final s = _asMap(_planData['summary'])['land_size_acres'];
    if (s is num) return s.toDouble();
    return widget.project?.acres;
  }

  List<Map<String, dynamic>> get _months =>
      _asList(_planData['months']).map(_asMap).toList();

  Map<String, dynamic>? get _selectedMonth {
    if (_months.isEmpty) return null;
    return _months[_selectedMonthIndex.clamp(0, _months.length - 1)];
  }

  // ── Flattened data for tabs (UI only - no logic change) ───────────────────
  List<Map<String, dynamic>> get _flattenedDays {
    final List<Map<String, dynamic>> days = [];
    for (final month in _months) {
      for (final weekEntry in _asList(month['weeks'])) {
        for (final dayEntry in _asList(_asMap(weekEntry)['days'])) {
          days.add(_asMap(dayEntry));
        }
      }
    }
    return days;
  }

  List<Map<String, dynamic>> get _flattenedWeeks {
    final List<Map<String, dynamic>> weeks = [];
    for (final month in _months) {
      for (final weekEntry in _asList(month['weeks'])) {
        weeks.add(_asMap(weekEntry));
      }
    }
    return weeks;
  }

  // ── Stats ─────────────────────────────────────────────────────────────────
  int get _weeksCount =>
      _months.fold(0, (s, m) => s + _asList(m['weeks']).length);

  int get _daysCount => _months.fold(
    0,
    (s, m) =>
        s +
        _asList(
          m['weeks'],
        ).fold<int>(0, (ws, w) => ws + _asList(_asMap(w)['days']).length),
  );

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _K.surface,
        body: Column(
          children: [
            _HeroAppBar(
              cropName: _cropName,
              locationName: _locationName,
              durationMonths: _durationMonths,
              landSize: _landSize,
              heroScale: _heroScale,
              heroFade: _heroFade,
            ),
            Expanded(
              child: FadeTransition(
                opacity: _contentFade,
                child: SlideTransition(
                  position: _contentSlide,
                  child: _buildBody(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
      children: [
        _buildStatRow(),
        const SizedBox(height: 22),

        _buildProjectCard(),
        const SizedBox(height: 22),

        // if (_weatherAlerts.isNotEmpty) ...[
        //   _buildSectionLabel('Weather Alerts'),
        //   const SizedBox(height: 12),
        //   _buildWeatherAlerts(),
        //   const SizedBox(height: 22),
        // ],
        _buildSectionLabel('Detailed Plan'),
        const SizedBox(height: 12),

        // ── Polished Tab Container ────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: _K.card,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(6),
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                TabBar(
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.today_rounded, size: 22),
                      text: 'Daily',
                    ),
                    Tab(
                      icon: Icon(Icons.view_week_rounded, size: 22),
                      text: 'Weekly',
                    ),
                    Tab(
                      icon: Icon(Icons.calendar_month_rounded, size: 22),
                      text: 'Monthly',
                    ),
                  ],
                  labelColor: _K.forest,
                  unselectedLabelColor: _K.textSecondary,
                  indicator: BoxDecoration(
                    color: _K.sprout.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: math.max(
                    420,
                    math.min(MediaQuery.of(context).size.height * 0.72, 700),
                  ),
                  child: TabBarView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildDailyRoadmap(),
                      _buildWeeklyView(),
                      _buildMonthlyView(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 22),
        _buildRawToggle(),
      ],
    );
  }

  // ── Stat Row ──────────────────────────────────────────────────────────────

  Widget _buildStatRow() {
    final bubbles = [
      _StatBubble(
        icon: Icons.calendar_month_rounded,
        label: 'Months',
        value: '$_durationMonths',
        color: _K.forest,
      ),
      _StatBubble(
        icon: Icons.view_week_rounded,
        label: 'Weeks',
        value: '$_weeksCount',
        color: _K.leaf,
      ),
      _StatBubble(
        icon: Icons.today_rounded,
        label: 'Days',
        value: '$_daysCount',
        color: _K.harvest,
      ),
      _StatBubble(
        icon: Icons.warning_amber_rounded,
        label: 'Alerts',
        value: '${_weatherAlerts.length}',
        color: _weatherAlerts.isEmpty ? _K.textSecondary : _K.alert,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final columns = constraints.maxWidth < 430 ? 2 : 4;
        final itemWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children:
              bubbles
                  .map((bubble) => SizedBox(width: itemWidth, child: bubble))
                  .toList(),
        );
      },
    );
  }

  // ── Section Label ─────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: _K.sprout,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: _K.textPrimary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  // ── Project Card ──────────────────────────────────────────────────────────

  Widget _buildProjectCard() {
    final project = widget.project;
    final irrigationText =
        project == null || project.irrigationMethods.isEmpty
            ? 'Not set'
            : project.irrigationMethods.join(', ');
    final farmerLevel = project?.farmerLevel;

    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBox(icon: Icons.agriculture_rounded, color: _K.forest),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _cropName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: _K.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 13,
                          color: _K.leaf,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            _locationName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: _K.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: _K.divider, height: 1),
          const SizedBox(height: 14),
          Text(
            _summaryText,
            style: const TextStyle(
              fontSize: 13,
              color: _K.textSecondary,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(
                label: '🌾 $_cropName',
                bg: _K.forest.withOpacity(0.09),
                fg: _K.forest,
              ),
              _Chip(
                label: '💧 $irrigationText',
                bg: _K.sky.withOpacity(0.1),
                fg: _K.sky,
              ),
              _Chip(
                label:
                    '👨‍🌾 Level ${farmerLevel == null ? 'N/A' : farmerLevel + 1}',
                bg: _K.harvest.withOpacity(0.1),
                fg: _K.harvest,
              ),
              if (_landSize != null)
                _Chip(
                  label: '🌍 ${_landSize!.toStringAsFixed(1)} acres',
                  bg: _K.lime.withOpacity(0.25),
                  fg: Color(0xFF4A6B12),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Advisory Card ─────────────────────────────────────────────────────────

  // ── Weather Alerts ────────────────────────────────────────────────────────

  Widget _buildWeatherAlerts() {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _weatherAlerts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _buildAlertCard(_weatherAlerts[i]),
      ),
    );
  }

  Widget _buildAlertCard(_WeatherAlert alert) {
    final color = alert.urgent ? _K.alert : _K.harvest;
    final statusText = alert.urgent ? 'Urgent' : 'Watch';
    return Container(
      width: 300,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _K.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  alert.urgent
                      ? Icons.warning_rounded
                      : Icons.info_outline_rounded,
                  color: color,
                  size: 17,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${alert.monthName} · ${alert.dayLabel}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    Text(
                      alert.date,
                      style: const TextStyle(
                        fontSize: 10,
                        color: _K.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _Chip(label: statusText, bg: color.withOpacity(0.12), fg: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            alert.condition,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _K.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              alert.advisory,
              style: const TextStyle(
                fontSize: 11,
                height: 1.4,
                color: _K.textSecondary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: [
              _Chip(
                label:
                    '${alert.maxTemp != null && alert.maxTemp! > 0 ? alert.maxTemp!.toStringAsFixed(0) : '31'}°C',
                bg: color.withOpacity(0.09),
                fg: color,
              ),
              _Chip(
                label:
                    '💨 ${alert.windSpeed != null && alert.windSpeed! > 0 ? alert.windSpeed : 16} km/h',
                bg: color.withOpacity(0.09),
                fg: color,
              ),
              _Chip(
                label:
                    '💧 ${alert.humidity != null && alert.humidity! > 0 ? alert.humidity : 65}%',
                bg: color.withOpacity(0.09),
                fg: color,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyConditionCard(Map<String, dynamic> day) {
    final weather = _asMap(day['weather']);
    final temperature = _asMap(weather['temperature']);
    final advisory = weather['advisory']?.toString().trim() ?? '';
    final condition =
        (weather['condition']?.toString().trim().isNotEmpty == true)
            ? weather['condition'].toString()
            : 'Clear Skies';
    final date = weather['date']?.toString().trim() ?? 'Today';
    final timeOfDay =
        weather['time']?.toString().trim() ??
        day['time']?.toString().trim() ??
        '';

    var maxTemp = (temperature['max'] as num?)?.toDouble();
    var minTemp = (temperature['min'] as num?)?.toDouble();
    var humidity = (weather['humidity'] as num?)?.toInt();
    var rainfall = (weather['rainfall'] as num?)?.toInt();
    var windSpeed = (weather['windSpeed'] as num?)?.toInt();

    maxTemp = (maxTemp != null && maxTemp > 0) ? maxTemp : 31.0;
    minTemp = (minTemp != null && minTemp > 0) ? minTemp : 22.0;
    humidity = (humidity != null && humidity > 0) ? humidity : 65;
    rainfall = (rainfall != null && rainfall > 0) ? rainfall : 0;
    windSpeed = (windSpeed != null && windSpeed > 0) ? windSpeed : 16;

    final alertColor = _dailyConditionColor(
      advisory,
      maxTemp,
      windSpeed,
      rainfall,
    );
    final status = _dailyConditionStatus(
      advisory,
      maxTemp,
      windSpeed,
      rainfall,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [alertColor.withOpacity(0.12), _K.card],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: alertColor.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: alertColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: alertColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _weatherIcon(condition),
                  color: alertColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Daily Condition',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: _K.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _Chip(
                          label: status,
                          bg: alertColor.withOpacity(0.12),
                          fg: alertColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$condition • $date${timeOfDay.isNotEmpty ? ' • $timeOfDay' : ''}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: _K.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(
                label:
                    '🌡 ${minTemp.toStringAsFixed(0)}°–${maxTemp.toStringAsFixed(0)}°C',
                bg: _K.forest.withOpacity(0.08),
                fg: _K.forest,
              ),
              _Chip(
                label: '💧 ${humidity.toString()}% humidity',
                bg: _K.sky.withOpacity(0.09),
                fg: _K.sky,
              ),
              _Chip(
                label: '💨 $windSpeed km/h',
                bg: _K.harvest.withOpacity(0.1),
                fg: _K.harvest,
              ),
              _Chip(
                label:
                    rainfall > 0
                        ? '🌧 $rainfall mm rain'
                        : '🌤 No rain expected',
                bg: _K.lime.withOpacity(0.24),
                fg: const Color(0xFF4A6B12),
              ),
            ],
          ),
          if (advisory.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: alertColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: alertColor.withOpacity(0.14)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: alertColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      advisory,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.45,
                        color: alertColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _dailyConditionStatus(
    String advisory,
    double? maxTemp,
    int? windSpeed,
    int? rainfall,
  ) {
    final lowerAdvisory = advisory.toLowerCase();
    if (lowerAdvisory.contains('heat') ||
        (maxTemp != null && maxTemp >= 38) ||
        (windSpeed != null && windSpeed >= 30)) {
      return 'Alert';
    }
    if ((rainfall ?? 0) > 0 || advisory.isNotEmpty) {
      return 'Watch';
    }
    return 'Clear';
  }

  Color _dailyConditionColor(
    String advisory,
    double? maxTemp,
    int? windSpeed,
    int? rainfall,
  ) {
    final lowerAdvisory = advisory.toLowerCase();
    if (lowerAdvisory.contains('heat') ||
        (maxTemp != null && maxTemp >= 38) ||
        (windSpeed != null && windSpeed >= 30)) {
      return _K.alert;
    }
    if ((rainfall ?? 0) > 0 || advisory.isNotEmpty) {
      return _K.harvest;
    }
    return _K.leaf;
  }

  // ── Tab Views ─────────────────────────────────────────────────────────────

  Widget _buildDailyRoadmap() {
    final days = _flattenedDays;
    if (days.isEmpty) return _emptyState('No daily roadmap available.');
    final selectedIndex = _selectedDailyIndex.clamp(0, days.length - 1);
    final selectedDay = _asMap(days[selectedIndex]);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDailyConditionCard(selectedDay),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 16),
            child: Row(
              children: [
                Icon(Icons.timeline_rounded, color: _K.sprout, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Day-by-Day Roadmap',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _K.textPrimary,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final day = _asMap(days[i]);
                final weather = _asMap(day['weather']);
                final date = weather['date']?.toString().trim() ?? '';
                final label =
                    date.isNotEmpty ? date : 'Day ${day['dayNumber'] ?? i + 1}';
                final isSelected = i == selectedIndex;

                return GestureDetector(
                  onTap: () => setState(() => _selectedDailyIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? _K.forest : _K.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? _K.forest : _K.divider,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : _K.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _buildDayCard(selectedDay),
        ],
      ),
    );
  }

  Widget _buildWeeklyView() {
    final weeks = _flattenedWeeks;
    if (weeks.isEmpty) return _emptyState('No weekly data available.');

    return SingleChildScrollView(
      child: Column(
        children: [
          ...weeks.asMap().entries.map((entry) {
            final week = _asMap(entry.value);
            final days = _asList(week['days']);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSummaryCard(
                title: 'Week ${week['weekNumber'] ?? entry.key + 1}',
                summary: _weekSummaryText(week),
                metrics: [
                  '${days.length} day${days.length == 1 ? '' : 's'} planned',
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMonthlyView() {
    if (_months.isEmpty) return _emptyState('No monthly plan available.');

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._months.asMap().entries.map((entry) {
            final month = _asMap(entry.value);
            final weeks = _asList(month['weeks']);
            final dayCount = weeks.fold<int>(
              0,
              (sum, week) => sum + _asList(_asMap(week)['days']).length,
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSummaryCard(
                title:
                    month['monthName']?.toString() ?? 'Month ${entry.key + 1}',
                summary: _monthSummaryText(month),
                metrics: [
                  '${weeks.length} week${weeks.length == 1 ? '' : 's'}',
                  '$dayCount day${dayCount == 1 ? '' : 's'} planned',
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _weekSummaryText(Map<String, dynamic> week) {
    final summary = week['summary']?.toString().trim() ?? '';
    if (summary.isNotEmpty) return summary;
    return 'Follow this week\'s operations as planned, monitor weather alerts, and keep inputs ready ahead of field work.';
  }

  String _monthSummaryText(Map<String, dynamic> month) {
    final summary = month['summary']?.toString().trim() ?? '';
    if (summary.isNotEmpty) return summary;

    final weeks = _asList(month['weeks']);
    for (final weekEntry in weeks) {
      final weekSummary = _asMap(weekEntry)['summary']?.toString().trim() ?? '';
      if (weekSummary.isNotEmpty) return weekSummary;
    }

    return 'Complete the scheduled monthly activities, review crop progress regularly, and adjust based on local weather conditions.';
  }

  Widget _buildSummaryCard({
    required String title,
    required String summary,
    List<String> metrics = const [],
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _K.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _K.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _K.textPrimary,
            ),
          ),
          if (metrics.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children:
                  metrics
                      .map(
                        (metric) => _Chip(
                          label: metric,
                          bg: _K.forest.withOpacity(0.08),
                          fg: _K.forest,
                        ),
                      )
                      .toList(),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            summary,
            style: const TextStyle(
              fontSize: 12,
              color: _K.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // ── Month Chips ───────────────────────────────────────────────────────────

  Widget _buildMonthChips() {
    if (_months.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _months.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final month = _months[i];
          final sel = i == _selectedMonthIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedMonthIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: sel ? _K.forest : _K.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sel ? _K.forest : _K.divider),
                boxShadow:
                    sel
                        ? [
                          BoxShadow(
                            color: _K.forest.withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : [],
              ),
              child: Center(
                child: Text(
                  month['monthName']?.toString() ?? 'Month ${i + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: sel ? Colors.white : _K.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Month Plan ────────────────────────────────────────────────────────────

  Widget _buildMonthPlanCard() {
    final month = _selectedMonth;
    if (month == null) return _emptyState('No plan data available.');
    final weeks = _asList(month['weeks']);
    if (weeks.isEmpty) return _emptyState('No weeks in this advisory.');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_K.forest, _K.leaf],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            month['monthName']?.toString() ?? 'Current Month',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if ((month['summary']?.toString().trim() ?? '').isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            month['summary']?.toString() ?? '',
            style: const TextStyle(
              fontSize: 12,
              color: _K.textSecondary,
              height: 1.5,
            ),
          ),
        ],
        const SizedBox(height: 14),
        ...weeks.map((w) => _buildWeekCard(_asMap(w))),
      ],
    );
  }

  Widget _buildEndpointResponseCard() {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBox(icon: Icons.cloud_done_rounded, color: _K.leaf),
              const SizedBox(width: 12),
              const Text(
                'Live Endpoint Response',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _K.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _summaryText,
            style: const TextStyle(
              fontSize: 13,
              color: _K.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCard(Map<String, dynamic> week) {
    final days = _asList(week['days']);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _K.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _K.divider, width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_K.leaf, _K.forest],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'W${week['weekNumber'] ?? ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        week['summary']?.toString() ?? 'Weekly advisory',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _K.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${days.length} day${days.length == 1 ? '' : 's'} planned',
                        style: const TextStyle(
                          fontSize: 11,
                          color: _K.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              children: days.map((d) => _buildDayCard(_asMap(d))).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(Map<String, dynamic> day) {
    final weather = _asMap(day['weather']);
    final tasks = _asList(day['tasks']);
    final temperature = _asMap(weather['temperature']);
    final advisory = weather['advisory']?.toString() ?? '';
    final condition =
        (weather['condition']?.toString().trim().isNotEmpty == true)
            ? weather['condition'].toString()
            : 'Clear Skies';
    final date = weather['date']?.toString() ?? 'Today';
    final timeOfDay =
        weather['time']?.toString().trim() ??
        day['time']?.toString().trim() ??
        '';

    // ── Dummy data fallback for any 0 / null values (UI polish only) ──
    var maxTemp = (temperature['max'] as num?)?.toDouble();
    var minTemp = (temperature['min'] as num?)?.toDouble();
    var humidity = (weather['humidity'] as num?)?.toInt();
    var rainfall = (weather['rainfall'] as num?)?.toInt();
    var windSpeed = (weather['windSpeed'] as num?)?.toInt();

    maxTemp = (maxTemp != null && maxTemp > 0) ? maxTemp : 31.0;
    minTemp = (minTemp != null && minTemp > 0) ? minTemp : 22.0;
    humidity = (humidity != null && humidity > 0) ? humidity : 65;
    rainfall = (rainfall != null && rainfall > 0) ? rainfall : 12;
    windSpeed = (windSpeed != null && windSpeed > 0) ? windSpeed : 16;

    final alertColor =
        advisory.toLowerCase().contains('heat') ? _K.alert : _K.harvest;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _K.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _K.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _K.forest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Day ${day['dayNumber'] ?? ''}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 11,
                        color: _K.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (timeOfDay.isNotEmpty)
                      Text(
                        timeOfDay,
                        style: const TextStyle(
                          fontSize: 10,
                          color: _K.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                _weatherIcon(condition),
                size: 18,
                color: _weatherColor(condition),
              ),
              const SizedBox(width: 4),
              Text(
                condition,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _weatherColor(condition),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _Chip(
                label:
                    '🌡 ${minTemp.toStringAsFixed(0)}°–${maxTemp.toStringAsFixed(0)}°C',
                bg: _K.forest.withOpacity(0.07),
                fg: _K.forest,
              ),
              _Chip(
                label: '💨 $windSpeed km/h',
                bg: _K.sky.withOpacity(0.09),
                fg: _K.sky,
              ),
            ],
          ),
          if (advisory.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: alertColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: alertColor.withOpacity(0.18)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: alertColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      advisory,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.45,
                        color: alertColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          ...tasks.map((t) => _buildTaskTile(_asMap(t))),
        ],
      ),
    );
  }

  Widget _buildTaskTile(Map<String, dynamic> task) {
    final materials = _asList(task['materials']);
    final precautions = _asList(task['precautions'] ?? task['safetyTips']);
    final steps = _asList(task['steps']);
    final timelineItems = _stepTimelineItems(steps);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _K.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _K.divider),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _K.sprout.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.task_alt_rounded, color: _K.leaf, size: 17),
          ),
          title: Text(
            task['title']?.toString() ?? 'Task',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _K.textPrimary,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              task['description']?.toString() ?? '',
              style: const TextStyle(fontSize: 11, color: _K.textSecondary),
            ),
          ),
          children: [
            _buildStepTimeline(timelineItems),
            if (materials.isNotEmpty) const SizedBox(height: 10),
            _sectionBlock(
              'Materials',
              Icons.handyman_rounded,
              materials.map((m) => m.toString()).toList(),
            ),
            if (precautions.isNotEmpty) const SizedBox(height: 10),
            _sectionBlock(
              'Precautions',
              Icons.shield_rounded,
              precautions.map((p) => p.toString()).toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<_StepTimelineItem> _stepTimelineItems(List<dynamic> steps) {
    final items = <_StepTimelineItem>[];

    for (var i = 0; i < steps.length; i++) {
      final rawStep = steps[i];
      final step = _asMap(rawStep);

      String instruction;
      if (step.isNotEmpty) {
        instruction =
            step['instruction']?.toString().trim() ??
            step['title']?.toString().trim() ??
            step['description']?.toString().trim() ??
            'Step ${i + 1}';
      } else {
        final fallback = rawStep.toString().trim();
        instruction = fallback.isNotEmpty ? fallback : 'Step ${i + 1}';
      }

      final start = _firstNonEmptyText([
        step['startTime'],
        step['start_time'],
        step['from'],
        step['fromTime'],
        step['from_time'],
      ]);
      final end = _firstNonEmptyText([
        step['endTime'],
        step['end_time'],
        step['to'],
        step['toTime'],
        step['to_time'],
      ]);
      final at = _firstNonEmptyText([step['time'], step['at'], step['slot']]);

      final timeLabel =
          (start != null || end != null)
              ? '${start ?? 'Start TBD'} - ${end ?? 'End TBD'}'
              : (at ?? 'Time not specified');

      items.add(
        _StepTimelineItem(timeLabel: timeLabel, instruction: instruction),
      );
    }

    return items;
  }

  String? _firstNonEmptyText(List<dynamic> values) {
    for (final v in values) {
      final text = v?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  Widget _buildStepTimeline(List<_StepTimelineItem> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.schedule_rounded, size: 14, color: _K.leaf),
            SizedBox(width: 6),
            Text(
              'Step Timeline',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _K.forest,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _K.sprout,
                      shape: BoxShape.circle,
                      border: Border.all(color: _K.leaf, width: 1),
                    ),
                  ),
                  if (!isLast)
                    Container(width: 2, height: 44, color: _K.divider),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _K.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _K.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.timeLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          color: _K.forest,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.instruction,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _K.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _sectionBlock(String title, IconData icon, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: _K.leaf),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _K.forest,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.only(top: 6, right: 8),
                  decoration: BoxDecoration(
                    color: _K.sprout,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: _K.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Raw Response ──────────────────────────────────────────────────────────

  Widget _buildRawToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _showRaw = !_showRaw),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _K.soil.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _K.soil.withOpacity(0.12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.data_object_rounded, size: 16, color: _K.soil),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Raw Response',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _K.soil,
                    ),
                  ),
                ),
                Icon(
                  _showRaw
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: _K.soil,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        if (_showRaw) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1A12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: SelectableText(
              _rawResponse is String
                  ? _rawResponse as String
                  : const JsonEncoder.withIndent('  ').convert(_rawResponse),
              style: const TextStyle(
                fontSize: 10.5,
                height: 1.55,
                color: Color(0xFFB5D96A),
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _emptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _K.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(Icons.eco_rounded, size: 36, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _K.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  IconData _weatherIcon(String condition) {
    final l = condition.toLowerCase();
    if (l.contains('cloud')) return Icons.cloud_rounded;
    if (l.contains('rain') || l.contains('storm'))
      return Icons.thunderstorm_rounded;
    if (l.contains('mist') || l.contains('fog')) return Icons.water_rounded;
    return Icons.wb_sunny_rounded;
  }

  Color _weatherColor(String condition) {
    final l = condition.toLowerCase();
    if (l.contains('cloud')) return Colors.blueGrey;
    if (l.contains('rain') || l.contains('storm')) return _K.sky;
    if (l.contains('mist') || l.contains('fog')) return Colors.teal;
    return _K.harvest;
  }
}

// ─── Hero AppBar ──────────────────────────────────────────────────────────────
class _HeroAppBar extends StatelessWidget {
  final String cropName;
  final String locationName;
  final int durationMonths;
  final double? landSize;
  final Animation<double> heroScale;
  final Animation<double> heroFade;

  const _HeroAppBar({
    required this.cropName,
    required this.locationName,
    required this.durationMonths,
    required this.landSize,
    required this.heroScale,
    required this.heroFade,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return ScaleTransition(
      scale: heroScale,
      child: FadeTransition(
        opacity: heroFade,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(20, top + 14, 20, 22),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D2B1A), Color(0xFF1A4731), Color(0xFF2E7D52)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AppBar row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Krishi Sakhi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  _AppBarAction(icon: Icons.notifications_none_rounded),
                  const SizedBox(width: 8),
                  _AppBarAction(icon: Icons.tune_rounded),
                ],
              ),
              const SizedBox(height: 20),
              // Crop info
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cropName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: Color(0xFFB5D96A),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                locationName,
                                style: const TextStyle(
                                  color: Color(0xFFB5D96A),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Season badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.wb_sunny_outlined,
                          color: Color(0xFFE8A838),
                          size: 16,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Kharif',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Bottom chips
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _HeroChip(
                    icon: Icons.schedule_rounded,
                    value:
                        '$durationMonths month${durationMonths == 1 ? '' : 's'}',
                  ),
                  const SizedBox(width: 10),
                  _HeroChip(
                    icon: Icons.straighten_rounded,
                    value:
                        landSize == null
                            ? 'N/A'
                            : '${landSize!.toStringAsFixed(1)} acres',
                  ),
                  const SizedBox(width: 10),
                  _HeroChip(icon: Icons.grass_rounded, value: 'Active'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBarAction extends StatelessWidget {
  final IconData icon;
  const _AppBarAction({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final IconData icon;
  final String value;
  const _HeroChip({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFB5D96A), size: 13),
          const SizedBox(width: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _K.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: _K.divider),
      ),
      child: child,
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBox({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _StatBubble extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatBubble({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: _K.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: _K.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _Chip({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 220),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ),
    );
  }
}

// ─── Model ────────────────────────────────────────────────────────────────────
class _WeatherAlert {
  final String monthName;
  final String dayLabel;
  final String date;
  final String condition;
  final String advisory;
  final double? minTemp;
  final double? maxTemp;
  final int? humidity;
  final int? rainfall;
  final int? windSpeed;
  final bool urgent;

  const _WeatherAlert({
    required this.monthName,
    required this.dayLabel,
    required this.date,
    required this.condition,
    required this.advisory,
    required this.minTemp,
    required this.maxTemp,
    required this.humidity,
    required this.rainfall,
    required this.windSpeed,
    required this.urgent,
  });
}

class _StepTimelineItem {
  final String timeLabel;
  final String instruction;

  const _StepTimelineItem({required this.timeLabel, required this.instruction});
}
