import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:krishi_sakhi/models/farm_project.dart';

class DashboardScreen extends StatefulWidget {
  final FarmProject? project;
  final Map<String, dynamic>? advisoryResponse;

  const DashboardScreen({super.key, this.project, this.advisoryResponse});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  late dynamic _rawResponse;
  late Map<String, dynamic> _planData;
  late List<_WeatherAlert> _weatherAlerts;

  int _selectedMonthIndex = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _loadPlanData();
    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.advisoryResponse != widget.advisoryResponse ||
        oldWidget.project != widget.project) {
      _loadPlanData();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _loadPlanData() {
    final response = widget.advisoryResponse;
    _rawResponse = response ?? _fallbackPlan();
    final hasPlan = response != null && response['months'] is List;
    _planData =
        hasPlan ? Map<String, dynamic>.from(response!) : _fallbackPlan();
    _weatherAlerts = _collectWeatherAlerts(_planData);
    _selectedMonthIndex = 0;
  }

  Map<String, dynamic> _fallbackPlan() {
    final crop = _cropName;
    final location = _locationName;
    final today = DateTime.now();
    return {
      'crop': crop,
      'durationMonths': 1,
      'months': [
        {
          'monthId': 'month_1',
          'monthName': 'Current Month',
          'summary':
              'Local advisory plan for $crop in $location. This plan is shown when the API is unavailable.',
          'weeks': [
            {
              'weekId': 'week_1',
              'weekNumber': 1,
              'summary': 'Initial crop management and moisture monitoring',
              'days': [
                {
                  'dayId': 'day_1',
                  'dayNumber': 1,
                  'weather': {
                    'date': today.toIso8601String().split('T').first,
                    'temperature': {'min': 27, 'max': 37},
                    'humidity': 62,
                    'rainfall': 0,
                    'windSpeed': 28,
                    'condition': 'Sunny',
                    'advisory':
                        'Heat risk. Irrigate early morning and avoid midday field work.',
                  },
                  'tasks': [
                    {
                      'taskId': 'task_1',
                      'title': 'Check soil moisture',
                      'description':
                          'Measure moisture before watering and record the reading.',
                      'isCompleted': false,
                      'materials': ['Moisture meter', 'Notebook'],
                      'precautions': ['Avoid midday heat', 'Do not overwater'],
                      'steps': [
                        {
                          'stepNumber': 1,
                          'instruction':
                              'Walk the field and test moisture at 0-15 cm depth.',
                        },
                        {
                          'stepNumber': 2,
                          'instruction':
                              'Write the reading and decide if light irrigation is needed.',
                        },
                      ],
                    },
                  ],
                },
              ],
            },
          ],
        },
      ],
    };
  }

  List<_WeatherAlert> _collectWeatherAlerts(Map<String, dynamic> planData) {
    final alerts = <_WeatherAlert>[];
    final months = _asList(planData['months']);

    for (final monthEntry in months) {
      final month = _asMap(monthEntry);
      final monthName = month['monthName']?.toString() ?? 'Month';
      final weeks = _asList(month['weeks']);

      for (final weekEntry in weeks) {
        final week = _asMap(weekEntry);
        final days = _asList(week['days']);

        for (final dayEntry in days) {
          final day = _asMap(dayEntry);
          final weather = _asMap(day['weather']);
          final advisory = weather['advisory']?.toString().trim() ?? '';
          final temperature = _asMap(weather['temperature']);
          final maxTemp = (temperature['max'] as num?)?.toDouble();
          final minTemp = (temperature['min'] as num?)?.toDouble();
          final humidity = (weather['humidity'] as num?)?.toInt();
          final rainfall = (weather['rainfall'] as num?)?.toInt();
          final windSpeed = (weather['windSpeed'] as num?)?.toInt();
          final condition =
              weather['condition']?.toString() ?? 'Weather update';
          final date = weather['date']?.toString() ?? '';
          final dayNumber = day['dayNumber']?.toString() ?? '';

          final isAlert =
              advisory.isNotEmpty ||
              (maxTemp != null && maxTemp >= 37) ||
              (windSpeed != null && windSpeed >= 28) ||
              (rainfall != null && rainfall > 0);

          if (!isAlert) {
            continue;
          }

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

  List<dynamic> _asList(dynamic value) {
    if (value is List<dynamic>) return value;
    return const [];
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value as Map);
    return <String, dynamic>{};
  }

  String get _cropName {
    final responseCrop = _planData['crop']?.toString().trim();
    if (responseCrop != null && responseCrop.isNotEmpty) {
      return responseCrop;
    }
    return widget.project?.cropName.isNotEmpty == true
        ? widget.project!.cropName
        : 'Crop Advisory';
  }

  String get _locationName {
    final summary = _asMap(_planData['summary']);
    final responseLocation = summary['location']?.toString().trim();
    if (responseLocation != null && responseLocation.isNotEmpty) {
      return responseLocation;
    }
    return widget.project?.locationName.isNotEmpty == true
        ? widget.project!.locationName
        : 'Your farm';
  }

  String get _summaryText {
    final summary = _asMap(_planData['summary']);
    final value =
        summary['summary']?.toString().trim() ??
        _planData['summary']?.toString().trim();
    if (value != null && value.isNotEmpty) {
      return value;
    }

    final months = _asList(_planData['months']);
    if (months.isNotEmpty) {
      final firstMonth = _asMap(months.first);
      final monthSummary = firstMonth['summary']?.toString().trim();
      if (monthSummary != null && monthSummary.isNotEmpty) {
        return monthSummary;
      }
    }
    return 'No summary returned by the advisory service.';
  }

  int get _durationMonths {
    final value = _planData['durationMonths'];
    if (value is num) return value.toInt();
    final months = _asList(_planData['months']);
    return months.isEmpty ? 1 : months.length;
  }

  double? get _landSize {
    final summary = _asMap(_planData['summary']);
    final size = summary['land_size_acres'];
    if (size is num) return size.toDouble();
    return widget.project?.acres;
  }

  List<Map<String, dynamic>> get _months =>
      _asList(_planData['months']).map(_asMap).toList();

  Map<String, dynamic>? get _selectedMonth {
    if (_months.isEmpty) return null;
    final index = _selectedMonthIndex.clamp(0, _months.length - 1);
    return _months[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F5),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 14),
                _buildOverviewCard(),
                if (_weatherAlerts.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildWeatherAlertsSection(),
                ],
                const SizedBox(height: 16),
                _buildMonthChips(),
                const SizedBox(height: 14),
                _buildMonthPlanCard(),
                const SizedBox(height: 16),
                _buildRawResponseCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _cropName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _locationName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildHeaderChip(
                'Duration',
                '$_durationMonths month${_durationMonths == 1 ? '' : 's'}',
              ),
              const SizedBox(width: 10),
              _buildHeaderChip(
                'Land',
                _landSize == null
                    ? 'N/A'
                    : '${_landSize!.toStringAsFixed(1)} acres',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderChip(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.14)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    final months = _months;
    final weeksCount = months.fold<int>(
      0,
      (sum, month) => sum + _asList(month['weeks']).length,
    );
    final daysCount = months.fold<int>(
      0,
      (sum, month) =>
          sum +
          _asList(month['weeks']).fold<int>(
            0,
            (weekSum, week) => weekSum + _asList(_asMap(week)['days']).length,
          ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF2E7D32),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Advisory summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _summaryText,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _MetricPill(label: 'Months', value: '$_durationMonths'),
              const SizedBox(width: 8),
              _MetricPill(label: 'Weeks', value: '$weeksCount'),
              const SizedBox(width: 8),
              _MetricPill(label: 'Days', value: '$daysCount'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherAlertsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weather Alerts',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 176,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _weatherAlerts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _buildWeatherAlertCard(_weatherAlerts[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherAlertCard(_WeatherAlert alert) {
    final color =
        alert.urgent ? const Color(0xFFC62828) : const Color(0xFFEF6C00);
    final background =
        alert.urgent ? const Color(0xFFFFEBEE) : const Color(0xFFFFF3E0);

    return Container(
      width: 290,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 16,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  alert.urgent ? Icons.warning_rounded : Icons.info_rounded,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${alert.monthName} • ${alert.dayLabel}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      alert.date,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            alert.condition,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A2E1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            alert.advisory,
            style: TextStyle(
              fontSize: 12,
              height: 1.35,
              color: Colors.grey.shade700,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _miniChip(
                'Max ${alert.maxTemp?.toStringAsFixed(0) ?? '--'}°C',
                color,
              ),
              _miniChip('Wind ${alert.windSpeed ?? '--'} km/h', color),
              _miniChip('Humidity ${alert.humidity ?? '--'}%', color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthChips() {
    if (_months.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _months.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final month = _months[index];
          final isSelected = index == _selectedMonthIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedMonthIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey.shade200,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  month['monthName']?.toString() ?? 'Month ${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthPlanCard() {
    final month = _selectedMonth;
    if (month == null) {
      return _emptyState('No plan data was returned for this advisory.');
    }

    final weeks = _asList(month['weeks']);
    if (weeks.isEmpty) {
      return _emptyState('No weeks were included in the advisory response.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          month['monthName']?.toString() ?? 'Current Month',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          month['summary']?.toString() ?? '',
          style: TextStyle(
            fontSize: 13,
            height: 1.45,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 14),
        ...weeks.map((weekEntry) => _buildWeekCard(_asMap(weekEntry))),
      ],
    );
  }

  Widget _buildWeekCard(Map<String, dynamic> week) {
    final days = _asList(week['days']);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF43A047), Color(0xFF1B5E20)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'W${week['weekNumber'] ?? ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
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
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A2E1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${days.length} day${days.length == 1 ? '' : 's'} planned',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...days.map((dayEntry) => _buildDayCard(_asMap(dayEntry))),
        ],
      ),
    );
  }

  Widget _buildDayCard(Map<String, dynamic> day) {
    final weather = _asMap(day['weather']);
    final tasks = _asList(day['tasks']);
    final temperature = _asMap(weather['temperature']);
    final advisory = weather['advisory']?.toString() ?? '';
    final condition = weather['condition']?.toString() ?? 'Weather update';
    final date = weather['date']?.toString() ?? '';
    final maxTemp = temperature['max']?.toString() ?? '--';
    final minTemp = temperature['min']?.toString() ?? '--';
    final humidity = weather['humidity']?.toString() ?? '--';
    final rainfall = weather['rainfall']?.toString() ?? '--';
    final windSpeed = weather['windSpeed']?.toString() ?? '--';

    final alertColor =
        advisory.toLowerCase().contains('heat') ||
                advisory.toLowerCase().contains('high temperature')
            ? const Color(0xFFC62828)
            : const Color(0xFFEF6C00);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBF8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0EDE0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Day ${day['dayNumber'] ?? ''}',
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  date,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ),
              Icon(
                _weatherIcon(condition),
                size: 16,
                color: _weatherColor(condition),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _miniChip(condition, _weatherColor(condition)),
              const SizedBox(width: 8),
              _miniChip('$minTemp°-$maxTemp°C', const Color(0xFF1B5E20)),
            ],
          ),
          if (advisory.isNotEmpty) ...[
            const SizedBox(height: 10),
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
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      advisory,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _miniChip('Humidity $humidity%', const Color(0xFF1565C0)),
              _miniChip('Rain $rainfall mm', const Color(0xFF1565C0)),
              _miniChip('Wind $windSpeed km/h', const Color(0xFF1565C0)),
            ],
          ),
          const SizedBox(height: 12),
          ...tasks.map((taskEntry) => _buildTaskTile(_asMap(taskEntry))),
        ],
      ),
    );
  }

  Widget _buildTaskTile(Map<String, dynamic> task) {
    final materials = _asList(task['materials']);
    final precautions = _asList(task['precautions'] ?? task['safetyTips']);
    final steps = _asList(task['steps']);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAF1EA)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        title: Text(
          task['title']?.toString() ?? 'Task',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A2E1A),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            task['description']?.toString() ?? '',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ),
        children: [
          _sectionBlock(
            'Steps',
            Icons.format_list_numbered_rounded,
            steps.map((stepEntry) {
              final step = _asMap(stepEntry);
              final instruction = step['instruction']?.toString() ?? '';
              final startTime = step['startTime']?.toString();
              final endTime = step['endTime']?.toString();
              final timeRange =
                  (startTime != null && endTime != null)
                      ? '$startTime - $endTime'
                      : null;
              return timeRange == null
                  ? instruction
                  : '$instruction\n$timeRange';
            }).toList(),
          ),
          const SizedBox(height: 10),
          _sectionBlock(
            'Materials',
            Icons.handyman_rounded,
            materials.map((item) => item.toString()).toList(),
          ),
          const SizedBox(height: 10),
          _sectionBlock(
            'Precautions',
            Icons.shield_rounded,
            precautions.map((item) => item.toString()).toList(),
          ),
        ],
      ),
    );
  }

  Widget _sectionBlock(String title, IconData icon, List<String> items) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: const Color(0xFF2E7D32)),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1B5E20),
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
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 6, right: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withOpacity(0.55),
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      color: Colors.grey.shade700,
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

  Widget _buildRawResponseCard() {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(top: 8),
      title: const Text(
        'Raw Response',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1B5E20),
        ),
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1A12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: SelectableText(
            _rawResponse is String
                ? _rawResponse as String
                : JsonEncoder.withIndent('  ').convert(_rawResponse),
            style: const TextStyle(
              fontSize: 11,
              height: 1.45,
              color: Color(0xFFDCE8DD),
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  Widget _miniChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  IconData _weatherIcon(String condition) {
    final lower = condition.toLowerCase();
    if (lower.contains('cloud')) return Icons.cloud_rounded;
    if (lower.contains('rain') || lower.contains('storm')) {
      return Icons.umbrella_rounded;
    }
    if (lower.contains('mist') || lower.contains('fog')) {
      return Icons.air_rounded;
    }
    return Icons.wb_sunny_rounded;
  }

  Color _weatherColor(String condition) {
    final lower = condition.toLowerCase();
    if (lower.contains('cloud')) return Colors.blueGrey;
    if (lower.contains('rain') || lower.contains('storm')) return Colors.blue;
    if (lower.contains('mist') || lower.contains('fog')) return Colors.teal;
    return Colors.orange;
  }

  Widget _emptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.eco_rounded, size: 36, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

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

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;

  const _MetricPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FBF7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE1EBE1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1B5E20),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
