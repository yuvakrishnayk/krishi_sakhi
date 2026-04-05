import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:krishi_sakhi/models/farm_project.dart';
import 'package:krishi_sakhi/screens/Project_Details/widgets/project_hero_app_bar.dart';

class AnalyticsScreen extends StatefulWidget {
  final FarmProject? project;
  final Map<String, dynamic>? advisoryResponse;

  const AnalyticsScreen({super.key, this.project, this.advisoryResponse});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  static const String _weatherApiUrl = String.fromEnvironment(
    'WEATHER_API_URL',
    defaultValue: 'http://api.weatherapi.com/v1/current.json',
  );
  static const String _weatherApiKey = String.fromEnvironment(
    'WEATHER_API_KEY',
    defaultValue: '',
  );
  static const String _llmBaseUrl = String.fromEnvironment(
    'LLM_BASE_URL',
    defaultValue: 'https://api.groq.com/openai/v1',
  );
  static const String _llmModel = String.fromEnvironment(
    'LLM_MODEL',
    defaultValue: 'openai/gpt-oss-120b',
  );
  static const String _llmApiKey = String.fromEnvironment(
    'LLM_API_KEY',
    defaultValue: '',
  );

  late TabController _tabController;
  Map<String, dynamic> _planData = {};
  List<_PlanWeatherAlert> _planWeatherAlerts = [];
  late Future<_LiveWeatherData?> _weatherFuture;
  late Future<_AiExpenseBreakdown> _expensesFuture;

  List<dynamic> _asList(dynamic value) => value is List ? value : const [];

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPlanData();
    _refreshIntegrations();
  }

  @override
  void didUpdateWidget(covariant AnalyticsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.advisoryResponse != widget.advisoryResponse ||
        oldWidget.project != widget.project) {
      _loadPlanData();
      _refreshIntegrations();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadPlanData() {
    final response = widget.advisoryResponse;
    _planData = response != null ? Map<String, dynamic>.from(response) : {};
    _planWeatherAlerts = _collectPlanWeatherAlerts();
  }

  void _refreshIntegrations() {
    _weatherFuture = _fetchLiveWeather();
    _expensesFuture = _fetchAiExpenseBreakdown();
  }

  List<Map<String, dynamic>> get _months =>
      _asList(_planData['months']).map(_asMap).toList();

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

  String get _cropName {
    final fromSummary = _asMap(_planData['summary'])['crop']?.toString().trim();
    if (fromSummary != null && fromSummary.isNotEmpty) return fromSummary;
    final crop = widget.project?.cropName.trim();
    if (crop == null || crop.isEmpty) return 'Samba Rice';
    return crop;
  }

  String get _locationName {
    final summary = _asMap(_planData['summary']);
    final responseLocation = summary['location']?.toString().trim();
    if (responseLocation != null && responseLocation.isNotEmpty) {
      return responseLocation;
    }

    if (widget.project?.locationName.isNotEmpty == true) {
      return widget.project!.locationName;
    }

    return 'Your farm';
  }

  double get _areaAcres {
    final fromSummary = _asMap(_planData['summary'])['land_size_acres'];
    if (fromSummary is num && fromSummary.toDouble() > 0) {
      return fromSummary.toDouble();
    }
    final projectArea = widget.project?.calculatedAreaAcres ?? 0;
    if (projectArea > 0) return projectArea;
    return 1.0;
  }

  double get _estimatedYieldTonPerAcre {
    if (_flattenedDays.isEmpty) {
      final estimate = 3.3 + (_areaAcres * 0.2);
      return estimate.clamp(2.0, 6.0);
    }

    final weatherRichDays =
        _flattenedDays.where((day) {
          final weather = _asMap(day['weather']);
          final advisory = weather['advisory']?.toString().trim() ?? '';
          return advisory.isNotEmpty;
        }).length;

    final stressFactor = (weatherRichDays / _flattenedDays.length).clamp(
      0.0,
      0.5,
    );
    final estimate = 4.5 - (stressFactor * 1.2) + (_areaAcres * 0.08);
    return estimate.clamp(2.0, 6.0);
  }

  int get _estimatedRevenue => (_areaAcres * 85000).round();

  int get _estimatedProfit => _estimatedRevenue - (_areaAcres * 33500).round();

  String _formatCurrency(int amount) {
    final abs = amount.abs();
    final normalized = abs.toString();
    if (normalized.length <= 3) {
      return amount < 0 ? '-₹$normalized' : '₹$normalized';
    }

    final regex = RegExp(r'(\d{1,2})(?=(\d{2})+(?!\d))');
    final lastThree = normalized.substring(normalized.length - 3);
    final otherNumbers = normalized.substring(0, normalized.length - 3);
    final formatted =
        '${otherNumbers.replaceAllMapped(regex, (m) => '${m[1]},')}$lastThree';
    return amount < 0 ? '-₹$formatted' : '₹$formatted';
  }

  List<_PlanWeatherAlert> _collectPlanWeatherAlerts() {
    final alerts = <_PlanWeatherAlert>[];
    for (final month in _months) {
      final monthName = month['monthName']?.toString() ?? 'Month';
      for (final weekEntry in _asList(month['weeks'])) {
        final week = _asMap(weekEntry);
        for (final dayEntry in _asList(week['days'])) {
          final day = _asMap(dayEntry);
          final weather = _asMap(day['weather']);
          final advisory = weather['advisory']?.toString().trim() ?? '';
          final rain = (weather['rainfall'] as num?)?.toDouble() ?? 0;
          final wind = (weather['windSpeed'] as num?)?.toDouble() ?? 0;
          final maxTemp =
              (_asMap(weather['temperature'])['max'] as num?)?.toDouble() ?? 0;

          final isAlert =
              advisory.isNotEmpty || rain > 0 || wind >= 28 || maxTemp >= 37;
          if (!isAlert) continue;

          alerts.add(
            _PlanWeatherAlert(
              monthName: monthName,
              date: weather['date']?.toString() ?? '',
              condition: weather['condition']?.toString() ?? 'Weather watch',
              message:
                  advisory.isNotEmpty
                      ? advisory
                      : 'Weather conditions need attention before field work.',
              urgent: maxTemp >= 38 || wind >= 30,
            ),
          );
        }
      }
    }
    return alerts;
  }

  Future<_LiveWeatherData?> _fetchLiveWeather() async {
    if (_weatherApiKey.trim().isEmpty) return null;

    final uri = Uri.parse(_weatherApiUrl).replace(
      queryParameters: {'key': _weatherApiKey, 'q': _locationName, 'aqi': 'no'},
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed weather fetch (${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final current = _asMap(body['current']);
    final condition = _asMap(current['condition']);
    final location = _asMap(body['location']);

    return _LiveWeatherData(
      locationName: location['name']?.toString().trim() ?? _locationName,
      conditionText: condition['text']?.toString().trim() ?? 'Unknown',
      tempC: (current['temp_c'] as num?)?.toDouble() ?? 0,
      feelsLikeC: (current['feelslike_c'] as num?)?.toDouble() ?? 0,
      humidity: (current['humidity'] as num?)?.toInt() ?? 0,
      windKph: (current['wind_kph'] as num?)?.toDouble() ?? 0,
      rainMm: (current['precip_mm'] as num?)?.toDouble() ?? 0,
      lastUpdated: current['last_updated']?.toString().trim() ?? '-',
    );
  }

  Future<_AiExpenseBreakdown> _fetchAiExpenseBreakdown() async {
    if (_llmApiKey.trim().isEmpty) {
      return _heuristicExpenseBreakdown(source: 'fallback');
    }

    final uri = Uri.parse(_llmBaseUrl).resolve('chat/completions');
    final prompt = '''
Generate farm expenses as strict JSON.
Crop: $_cropName
Area acres: ${_areaAcres.toStringAsFixed(2)}
Location: $_locationName
Expected revenue INR: $_estimatedRevenue

Return ONLY a JSON object with this exact schema:
{
  "summary": "short line under 18 words",
  "items": [
    {"category":"Seeds","amount":12000,"reason":"short reason"}
  ]
}
Rules:
- 5 to 7 categories.
- Amounts are positive integers in INR.
- Total expenses should be realistic for the area.
- No markdown fences.
''';

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_llmApiKey',
      },
      body: jsonEncode({
        'model': _llmModel,
        'temperature': 0.2,
        'messages': [
          {
            'role': 'system',
            'content': 'You are an expert Indian agriculture cost planner.',
          },
          {'role': 'user', 'content': prompt},
        ],
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return _heuristicExpenseBreakdown(source: 'fallback');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = _asList(payload['choices']);
    if (choices.isEmpty) return _heuristicExpenseBreakdown(source: 'fallback');

    final message = _asMap(choices.first)['message'];
    final content = _asMap(message)['content']?.toString().trim() ?? '';
    if (content.isEmpty) return _heuristicExpenseBreakdown(source: 'fallback');

    final parsed = _decodePossibleJson(content);
    if (parsed == null) return _heuristicExpenseBreakdown(source: 'fallback');

    final rawItems = _asList(parsed['items']);
    final items =
        rawItems
            .map(_asMap)
            .map(
              (e) => _ExpenseItem(
                category:
                    e['category']?.toString().trim().isNotEmpty == true
                        ? e['category'].toString().trim()
                        : 'Other',
                amount: (e['amount'] as num?)?.toInt() ?? 0,
                reason: e['reason']?.toString().trim() ?? '',
              ),
            )
            .where((e) => e.amount > 0)
            .toList();

    if (items.isEmpty) return _heuristicExpenseBreakdown(source: 'fallback');

    final total = items.fold<int>(0, (sum, item) => sum + item.amount);
    return _AiExpenseBreakdown(
      items: items,
      totalExpenses: total,
      estimatedRevenue: _estimatedRevenue,
      estimatedProfit: _estimatedRevenue - total,
      summary:
          parsed['summary']?.toString().trim().isNotEmpty == true
              ? parsed['summary'].toString().trim()
              : 'AI-estimated spending for your farm size and crop.',
      source: 'ai',
    );
  }

  Map<String, dynamic>? _decodePossibleJson(String content) {
    try {
      final direct = jsonDecode(content);
      if (direct is Map<String, dynamic>) return direct;
      if (direct is Map) return Map<String, dynamic>.from(direct);
    } catch (_) {
      // Try extracting the first valid JSON object from mixed content.
    }

    final start = content.indexOf('{');
    final end = content.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) return null;

    final sub = content.substring(start, end + 1);
    try {
      final decoded = jsonDecode(sub);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return null;
    }
    return null;
  }

  _AiExpenseBreakdown _heuristicExpenseBreakdown({required String source}) {
    final areaMultiplier = _areaAcres.clamp(0.5, 8.0);
    final items = [
      _ExpenseItem(
        category: 'Seeds',
        amount: (4200 * areaMultiplier).round(),
        reason: 'Crop-specific seed procurement',
      ),
      _ExpenseItem(
        category: 'Fertilizers',
        amount: (8600 * areaMultiplier).round(),
        reason: 'NPK and micronutrient schedule',
      ),
      _ExpenseItem(
        category: 'Pesticides',
        amount: (3600 * areaMultiplier).round(),
        reason: 'Preventive and curative sprays',
      ),
      _ExpenseItem(
        category: 'Labour',
        amount: (12500 * areaMultiplier).round(),
        reason: 'Sowing, weeding, and harvest labor',
      ),
      _ExpenseItem(
        category: 'Irrigation',
        amount: (5700 * areaMultiplier).round(),
        reason: 'Pump energy and water application',
      ),
      _ExpenseItem(
        category: 'Transport',
        amount: (2200 * areaMultiplier).round(),
        reason: 'Input logistics and mandi transport',
      ),
    ];

    final total = items.fold<int>(0, (sum, e) => sum + e.amount);
    return _AiExpenseBreakdown(
      items: items,
      totalExpenses: total,
      estimatedRevenue: _estimatedRevenue,
      estimatedProfit: _estimatedRevenue - total,
      summary:
          'Estimated expenses based on crop, area, and local farm pattern.',
      source: source,
    );
  }

  List<_MonthYieldPoint> get _yieldSeries {
    if (_months.isEmpty) {
      final peak = _estimatedYieldTonPerAcre;
      const labels = ['M1', 'M2', 'M3', 'M4', 'M5', 'M6'];
      final values = [
        peak * 0.45,
        peak * 0.62,
        peak * 0.76,
        peak * 0.87,
        peak * 0.95,
        peak,
      ];
      return List.generate(
        labels.length,
        (i) => _MonthYieldPoint(label: labels[i], tonsPerAcre: values[i]),
      );
    }

    final totalMonths = _months.length;
    return _months.asMap().entries.map((entry) {
      final month = _asMap(entry.value);
      final label =
          month['monthName']?.toString().trim().isNotEmpty == true
              ? month['monthName'].toString().trim().split(' ').first
              : 'M${entry.key + 1}';
      final progress = (entry.key + 1) / totalMonths;
      final weatherPenalty = (_planWeatherAlerts.length * 0.03).clamp(0.0, 0.4);
      final value =
          (_estimatedYieldTonPerAcre * (0.45 + (progress * 0.55))) -
          weatherPenalty;
      return _MonthYieldPoint(label: label, tonsPerAcre: value.clamp(1.8, 6.2));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F0),
      body: Column(
        children: [
          ProjectHeroAppBar(
            title: 'Analytics',
            subtitle: '$_cropName • $_locationName',
            leadingIcon: Icons.analytics_rounded,
            chips: const [
              ProjectHeroChipData(
                icon: Icons.trending_up_rounded,
                value: 'Yield',
              ),
              ProjectHeroChipData(icon: Icons.cloud_rounded, value: 'Weather'),
              ProjectHeroChipData(
                icon: Icons.currency_rupee_rounded,
                value: 'Expenses',
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: const Color(0xFF1B5E20),
              unselectedLabelColor: Colors.grey.shade600,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Yield'),
                Tab(text: 'Weather'),
                Tab(text: 'Expenses'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildYieldTab(),
                _buildWeatherTab(),
                _buildExpensesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYieldTab() {
    final yield = _estimatedYieldTonPerAcre;
    final series = _yieldSeries;
    final maxVal = series
        .map((point) => point.tonsPerAcre)
        .fold<double>(4.5, (max, value) => value > max ? value : max);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFarmerTipCard(
            title: 'Yield intelligence from advisory plan',
            message:
                'This chart combines home dashboard plan data, weather stress, and farm area to project monthly yield.',
            icon: Icons.lightbulb_rounded,
            color: const Color(0xFF2E7D32),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expected Yield • $_cropName',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      yield.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Tons/Acre',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Area: ${_areaAcres.toStringAsFixed(1)} acres • Alerts: ${_planWeatherAlerts.length}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Plan-based Growth Curve',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A2E1A),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 150,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(series.length, (i) {
                      final value = series[i].tonsPerAcre;
                      final barHeight = (value / maxVal) * 120;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            value.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 260 + i * 90),
                            width: 30,
                            height: barHeight,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4CAF50), Color(0xFF1B5E20)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            series[i].label,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildComparisonCard(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildComparisonCard() {
    final crops = [
      {
        'name': _cropName,
        'yield': _estimatedYieldTonPerAcre,
        'profit': _formatCurrency(_estimatedProfit),
      },
      {'name': 'Ponni Rice', 'yield': 3.8, 'profit': '₹72,000'},
      {'name': 'Millet', 'yield': 2.9, 'profit': '₹95,000'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Crop Comparison',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A2E1A),
            ),
          ),
          const SizedBox(height: 16),
          ...crops.map(
            (crop) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.grass_rounded,
                      color: Color(0xFF2E7D32),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          crop['name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ((crop['yield'] as num).toDouble() / 5.0)
                                .clamp(0.0, 1.0),
                            backgroundColor: Colors.grey.shade100,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF4CAF50),
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${(crop['yield'] as num).toDouble().toStringAsFixed(1)}T',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      Text(
                        crop['profit'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherTab() {
    return FutureBuilder<_LiveWeatherData?>(
      future: _weatherFuture,
      builder: (context, snapshot) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildFarmerTipCard(
                title: 'Live + advisory weather',
                message:
                    'Live weather comes from API and actionable alerts are pulled from your home advisory plan.',
                icon: Icons.cloud_rounded,
                color: const Color(0xFF1565C0),
              ),
              const SizedBox(height: 12),
              if (snapshot.connectionState == ConnectionState.waiting)
                _buildLoadingCard('Loading current weather...')
              else if (snapshot.hasError)
                _buildErrorCard(
                  'Unable to fetch weather now. Showing plan alerts.',
                )
              else if (snapshot.data != null)
                _buildLiveWeatherCard(snapshot.data!),
              const SizedBox(height: 16),
              _buildPlanWeatherAlertsCard(),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLiveWeatherCard(_LiveWeatherData weather) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.wb_sunny_rounded,
                  color: Color(0xFF1565C0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.locationName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A2E1A),
                      ),
                    ),
                    Text(
                      weather.conditionText,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${weather.tempC.round()}°',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1565C0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _metricChip('Feels', '${weather.feelsLikeC.round()}°'),
              _metricChip('Humidity', '${weather.humidity}%'),
              _metricChip('Wind', '${weather.windKph.round()} km/h'),
              _metricChip('Rain', '${weather.rainMm.toStringAsFixed(1)} mm'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Updated: ${weather.lastUpdated}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanWeatherAlertsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Plan Weather Alerts',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A2E1A),
            ),
          ),
          const SizedBox(height: 12),
          if (_planWeatherAlerts.isEmpty)
            Text(
              'No alert-level weather entries found in your generated plan.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            )
          else
            ..._planWeatherAlerts
                .take(5)
                .map(
                  (alert) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            alert.urgent
                                ? const Color(0xFFFFEBEE)
                                : const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              alert.urgent
                                  ? const Color(0xFFFFCDD2)
                                  : const Color(0xFFFFE082),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            alert.urgent
                                ? Icons.warning_rounded
                                : Icons.info_outline_rounded,
                            color:
                                alert.urgent
                                    ? const Color(0xFFD32F2F)
                                    : const Color(0xFFF57F17),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${alert.monthName}${alert.date.isNotEmpty ? ' • ${alert.date}' : ''}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${alert.condition}: ${alert.message}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    height: 1.3,
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
        ],
      ),
    );
  }

  Widget _buildExpensesTab() {
    return FutureBuilder<_AiExpenseBreakdown>(
      future: _expensesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildFarmerTipCard(
                  title: 'AI expense planner',
                  message:
                      'Generating an expense breakdown for $_cropName on ${_areaAcres.toStringAsFixed(1)} acres...',
                  icon: Icons.auto_awesome_rounded,
                  color: const Color(0xFF1B5E20),
                ),
                const SizedBox(height: 12),
                _buildLoadingCard('Generating AI cost sheet...'),
              ],
            ),
          );
        }

        final data =
            snapshot.data ?? _heuristicExpenseBreakdown(source: 'fallback');
        final total = data.totalExpenses;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildFarmerTipCard(
                title: 'Expense intelligence (${data.source.toUpperCase()})',
                message: data.summary,
                icon: Icons.account_balance_wallet_rounded,
                color: const Color(0xFF1B5E20),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Expenses',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCurrency(total),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '${_areaAcres.toStringAsFixed(1)} acres • $_cropName',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Revenue',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        Text(
                          _formatCurrency(data.estimatedRevenue),
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Profit: ${_formatCurrency(data.estimatedProfit)}',
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Expense Breakdown',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A2E1A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...data.items.map((item) {
                      final pct = total <= 0 ? 0.0 : (item.amount / total);
                      final color = _expenseColor(item.category);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _expenseIcon(item.category),
                                color: color,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.category,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        _formatCurrency(item.amount),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                          color: color,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    item.reason,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: pct.clamp(0.0, 1.0),
                                      backgroundColor: Colors.grey.shade100,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        color,
                                      ),
                                      minHeight: 6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _metricChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1B5E20),
        ),
      ),
    );
  }

  Widget _buildLoadingCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFCC80)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFFE65100),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _expenseColor(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('seed')) return const Color(0xFF2E7D32);
    if (lower.contains('fert')) return const Color(0xFF1565C0);
    if (lower.contains('pest')) return const Color(0xFFD32F2F);
    if (lower.contains('labour')) return const Color(0xFFF57F17);
    if (lower.contains('irrig')) return const Color(0xFF0097A7);
    return const Color(0xFF6D4C41);
  }

  IconData _expenseIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('seed')) return Icons.grass_rounded;
    if (lower.contains('fert')) return Icons.science_rounded;
    if (lower.contains('pest')) return Icons.pest_control_rounded;
    if (lower.contains('labour')) return Icons.people_rounded;
    if (lower.contains('irrig')) return Icons.water_drop_rounded;
    if (lower.contains('transport')) return Icons.local_shipping_rounded;
    return Icons.account_balance_wallet_rounded;
  }

  Widget _buildFarmerTipCard({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.35,
                    color: Color(0xFF2C3E2D),
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

class _MonthYieldPoint {
  final String label;
  final double tonsPerAcre;

  const _MonthYieldPoint({required this.label, required this.tonsPerAcre});
}

class _PlanWeatherAlert {
  final String monthName;
  final String date;
  final String condition;
  final String message;
  final bool urgent;

  const _PlanWeatherAlert({
    required this.monthName,
    required this.date,
    required this.condition,
    required this.message,
    required this.urgent,
  });
}

class _LiveWeatherData {
  final String locationName;
  final String conditionText;
  final double tempC;
  final double feelsLikeC;
  final int humidity;
  final double windKph;
  final double rainMm;
  final String lastUpdated;

  const _LiveWeatherData({
    required this.locationName,
    required this.conditionText,
    required this.tempC,
    required this.feelsLikeC,
    required this.humidity,
    required this.windKph,
    required this.rainMm,
    required this.lastUpdated,
  });
}

class _ExpenseItem {
  final String category;
  final int amount;
  final String reason;

  const _ExpenseItem({
    required this.category,
    required this.amount,
    required this.reason,
  });
}

class _AiExpenseBreakdown {
  final List<_ExpenseItem> items;
  final int totalExpenses;
  final int estimatedRevenue;
  final int estimatedProfit;
  final String summary;
  final String source;

  const _AiExpenseBreakdown({
    required this.items,
    required this.totalExpenses,
    required this.estimatedRevenue,
    required this.estimatedProfit,
    required this.summary,
    required this.source,
  });
}
