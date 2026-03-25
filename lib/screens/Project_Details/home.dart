import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Minimal stub so the file compiles standalone
class FarmProject {
  final String name;
  const FarmProject({required this.name});
}

class DashboardScreen extends StatefulWidget {
  final FarmProject? project;
  const DashboardScreen({super.key, this.project});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final today = DateTime.now();
  int _selectedDayIndex = 3;
  int _selectedPlanTab = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // ── Plan Data ──────────────────────────────────────────────────────────────
  final Map<String, dynamic> planData = {
    "planId": "plan_001",
    "crop": "Paddy",
    "durationMonths": 3,
    "months": [
      {
        "monthId": "month_1",
        "monthName": "June",
        "summary": "Land readying and sowing",
        "progress": 0.23,
        "weeks": [
          {
            "weekId": "week_1",
            "weekNumber": 1,
            "summary": "Field cleaning and ploughing",
            "days": [
              {
                "dayId": "day_1",
                "dayNumber": 1,
                "weather": {
                  "date": "2026-06-01",
                  "temperature": {"min": 26, "max": 34},
                  "humidity": 78,
                  "rainfall": 5,
                  "windSpeed": 12,
                  "condition": "Partly Cloudy",
                  "advisory":
                      "Light rain likely today. Best to skip spraying on the field.",
                },
                "tasks": [
                  {
                    "taskId": "task_1",
                    "title": "Pull out unwanted plants",
                    "description":
                        "Remove all wild grass and weeds from the field",
                    "steps": [
                      {
                        "stepNumber": 1,
                        "instruction":
                            "Walk through the field and spot any wild plants",
                      },
                      {
                        "stepNumber": 2,
                        "instruction":
                            "Use a hand tool (kudal) to pull them out from the root",
                      },
                      {
                        "stepNumber": 3,
                        "instruction":
                            "Collect the pulled plants and dump them far away from the field",
                      },
                    ],
                    "materials": ["Hand kudal (hoe)", "Gloves"],
                    "safetyTips": [
                      "Wear gloves so your hands don't get hurt",
                      "Don't leave uprooted plants lying in the field — they can grow back",
                    ],
                    "isCompleted": true,
                  },
                ],
              },
              {
                "dayId": "day_2",
                "dayNumber": 2,
                "weather": {
                  "date": "2026-06-02",
                  "temperature": {"min": 27, "max": 35},
                  "humidity": 65,
                  "rainfall": 0,
                  "windSpeed": 10,
                  "condition": "Sunny",
                  "advisory":
                      "Nice sunny day — good time to plough and loosen the soil.",
                },
                "tasks": [
                  {
                    "taskId": "task_2",
                    "title": "Plough the field",
                    "description": "Loosen the soil so seeds can go in easily",
                    "steps": [
                      {
                        "stepNumber": 1,
                        "instruction":
                            "Sprinkle a little water to slightly wet the soil",
                      },
                      {
                        "stepNumber": 2,
                        "instruction":
                            "Use tractor or bullock plough to turn the soil",
                      },
                      {
                        "stepNumber": 3,
                        "instruction":
                            "Make sure the soil is turned evenly across the whole field",
                      },
                    ],
                    "materials": ["Tractor or bullock plough"],
                    "safetyTips": [
                      "Don't plough too deep — 6 to 8 inches is enough",
                      "Check that the soil is not too dry or too wet before ploughing",
                    ],
                    "isCompleted": false,
                  },
                ],
              },
            ],
          },
          {
            "weekId": "week_2",
            "weekNumber": 2,
            "summary": "Adding goodness to the soil",
            "days": [
              {
                "dayId": "day_8",
                "dayNumber": 8,
                "weather": {
                  "date": "2026-06-08",
                  "temperature": {"min": 25, "max": 33},
                  "humidity": 70,
                  "rainfall": 0,
                  "windSpeed": 8,
                  "condition": "Sunny",
                  "advisory":
                      "Good weather to mix compost into the field today.",
                },
                "tasks": [
                  {
                    "taskId": "task_5",
                    "title": "Mix compost into the soil",
                    "description":
                        "Add cow dung compost to make the soil rich for the crop",
                    "steps": [
                      {
                        "stepNumber": 1,
                        "instruction":
                            "Spread the compost evenly all over the field",
                      },
                      {
                        "stepNumber": 2,
                        "instruction":
                            "Mix it into the top layer of soil using a plough or spade",
                      },
                    ],
                    "materials": ["Cow dung compost", "Spreader or basket"],
                    "safetyTips": [
                      "Use only well-rotted compost — fresh dung can damage young plants",
                    ],
                    "isCompleted": false,
                  },
                ],
              },
            ],
          },
        ],
      },
      {
        "monthId": "month_2",
        "monthName": "July",
        "summary": "Seedling care and moving to main field",
        "progress": 0.0,
        "weeks": [],
      },
      {
        "monthId": "month_3",
        "monthName": "August",
        "summary": "Feeding the crop and watching for insects",
        "progress": 0.0,
        "weeks": [],
      },
    ],
  };

  int _selectedMonthIndex = 0;
  int _selectedWeekIndex = 0;
  int _selectedDayPlanIndex = 0;
  bool _showTaskDetail = false;
  Map<String, dynamic>? _expandedTask;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F0),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildWeatherHeroCard(),
                  _buildDateStrip(),
                  _buildFarmerStatsRow(),
                  _buildPlanTabsSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── App Bar ────────────────────────────────────────────────────────────────

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      snap: true,
      backgroundColor: const Color(0xFF1B5E20),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.eco, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Krishi Sakhi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Your Smart Farming Helper',
                style: TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Text(
              'RK',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Weather Hero Card ──────────────────────────────────────────────────────

  Widget _buildWeatherHeroCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF388E3C), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Morning, Ramesh! 🌾',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Madurai, Tamil Nadu',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.wb_sunny_rounded,
                      color: Colors.yellow,
                      size: 32,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '32°C',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Sunny',
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeatherStat(
                Icons.water_drop_rounded,
                '68%',
                'Air Moisture',
              ),
              _buildWeatherStat(Icons.air_rounded, '12 km/h', 'Wind'),
              _buildWeatherStat(Icons.umbrella_rounded, '5%', 'Rain Chance'),
              _buildWeatherStat(Icons.wb_twilight_rounded, 'Clear', 'Sky'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.greenAccent,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Good day to water your field today 💧',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
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

  Widget _buildWeatherStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 10),
        ),
      ],
    );
  }

  // ── Date Strip ─────────────────────────────────────────────────────────────

  Widget _buildDateStrip() {
    final dates = List.generate(
      7,
      (i) => DateTime(today.year, today.month, today.day + (i - 3)),
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_rounded,
            color: Color(0xFF2E7D32),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 72,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dates.length,
                itemBuilder: (context, index) {
                  final date = dates[index];
                  final isToday = index == 3;
                  final isSelected = index == _selectedDayIndex;
                  final isFuture = index > 3;

                  return GestureDetector(
                    onTap:
                        isFuture
                            ? null
                            : () => setState(() => _selectedDayIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 48,
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? const Color(0xFF2E7D32)
                                : isToday
                                ? const Color(0xFFE8F5E9)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border:
                            isToday && !isSelected
                                ? Border.all(
                                  color: const Color(0xFF2E7D32),
                                  width: 1.5,
                                )
                                : null,
                      ),
                      child: Opacity(
                        opacity: isFuture ? 0.4 : 1.0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ['M', 'T', 'W', 'T', 'F', 'S', 'S'][date.weekday -
                                  1],
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                    isSelected
                                        ? Colors.white70
                                        : Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color:
                                    isSelected
                                        ? Colors.white
                                        : Colors.grey.shade800,
                              ),
                            ),
                            if (isToday)
                              Container(
                                width: 4,
                                height: 4,
                                margin: const EdgeInsets.only(top: 3),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : const Color(0xFF2E7D32),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Farmer Stats Row ───────────────────────────────────────────────────────
  // Replaced technical terms (pH, NPK) with plain farmer-friendly labels

  Widget _buildFarmerStatsRow() {
    final stats = [
      {
        'label': 'Soil Health',
        'value': 'Good',
        'icon': Icons.yard_rounded,
        'color': const Color(0xFF2E7D32),
        'bg': const Color(0xFFE8F5E9),
        'trend': '✓ Healthy',
        'good': true,
      },
      {
        'label': 'Water Need',
        'value': 'Normal',
        'icon': Icons.water_drop_rounded,
        'color': const Color(0xFF1565C0),
        'bg': const Color(0xFFE3F2FD),
        'trend': 'On track',
        'good': true,
      },
      {
        'label': 'Harvest Est.',
        'value': '4.2 T',
        'icon': Icons.agriculture_rounded,
        'color': const Color(0xFFE65100),
        'bg': const Color(0xFFFFF3E0),
        'trend': '+12% good',
        'good': true,
      },
      {
        'label': 'Pest Alert',
        'value': 'High',
        'icon': Icons.pest_control_rounded,
        'color': const Color(0xFFC62828),
        'bg': const Color(0xFFFFEBEE),
        'trend': '⚠ Act now',
        'good': false,
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children:
            stats.map((s) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: s['bg'] as Color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          s['icon'] as IconData,
                          color: s['color'] as Color,
                          size: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s['value'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: s['color'] as Color,
                        ),
                      ),
                      Text(
                        s['label'] as String,
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s['trend'] as String,
                        style: TextStyle(
                          fontSize: 9,
                          color:
                              (s['good'] as bool)
                                  ? Colors.green.shade600
                                  : Colors.red.shade600,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  // ── Plan Tabs ──────────────────────────────────────────────────────────────

  Widget _buildPlanTabsSection() {
    final tabs = ['Daily', 'Weekly', 'Monthly'];
    final icons = [
      Icons.today_rounded,
      Icons.view_week_rounded,
      Icons.calendar_month_rounded,
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF43A047), Color(0xFF1B5E20)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Farm Work Plan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A2E1A),
                    ),
                  ),
                  Text(
                    'Paddy crop • 3-month plan',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Tab selector
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children:
                  tabs.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final label = entry.value;
                    final isSelected = _selectedPlanTab == idx;
                    return Expanded(
                      child: GestureDetector(
                        onTap:
                            () => setState(() {
                              _selectedPlanTab = idx;
                              _selectedMonthIndex = 0;
                              _selectedWeekIndex = 0;
                              _selectedDayPlanIndex = 0;
                              _showTaskDetail = false;
                              _expandedTask = null;
                            }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            gradient:
                                isSelected
                                    ? const LinearGradient(
                                      colors: [
                                        Color(0xFF2E7D32),
                                        Color(0xFF1B5E20),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                    : null,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                icons[idx],
                                size: 14,
                                color:
                                    isSelected
                                        ? Colors.white
                                        : Colors.grey.shade500,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder:
                (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.04, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
            child: _buildSelectedPlanContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedPlanContent() {
    switch (_selectedPlanTab) {
      case 0:
        return _buildDailyPlanView();
      case 1:
        return _buildWeeklyPlanView();
      case 2:
        return _buildMonthlyPlanView();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Daily View ─────────────────────────────────────────────────────────────

  Widget _buildDailyPlanView() {
    final months = planData['months'] as List;
    final month = months[_selectedMonthIndex] as Map<String, dynamic>;
    final weeks = month['weeks'] as List;
    if (weeks.isEmpty) {
      return _buildEmptyState('No work planned for this month yet.');
    }
    final week = weeks[_selectedWeekIndex] as Map<String, dynamic>;
    final days = week['days'] as List;
    final day = days[_selectedDayPlanIndex] as Map<String, dynamic>;
    final tasks = day['tasks'] as List;
    final weather = day['weather'] as Map<String, dynamic>;

    return Column(
      key: ValueKey(
        'daily_${_selectedMonthIndex}_${_selectedWeekIndex}_$_selectedDayPlanIndex',
      ),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDaySelectorStrip(days),
        const SizedBox(height: 14),
        _buildDayWeatherCard(weather),
        const SizedBox(height: 14),
        ...tasks.asMap().entries.map(
          (e) => _buildTaskCard(e.value as Map<String, dynamic>, e.key),
        ),
      ],
    );
  }

  Widget _buildDaySelectorStrip(List days) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index] as Map<String, dynamic>;
          final isSelected = _selectedDayPlanIndex == index;
          final dayTasks = day['tasks'] as List;
          final completedCount =
              dayTasks.where((t) => (t as Map)['isCompleted'] == true).length;

          return GestureDetector(
            onTap:
                () => setState(() {
                  _selectedDayPlanIndex = index;
                  _showTaskDetail = false;
                  _expandedTask = null;
                }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Day ${day['dayNumber']}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color:
                          isSelected ? Colors.white : const Color(0xFF1A2E1A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$completedCount/${dayTasks.length} done',
                    style: TextStyle(
                      fontSize: 9,
                      color: isSelected ? Colors.white70 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayWeatherCard(Map<String, dynamic> weather) {
    final temp = weather['temperature'] as Map<String, dynamic>;
    final condition = weather['condition'] as String;
    final advisory = weather['advisory'] as String;

    IconData weatherIcon = Icons.wb_sunny_rounded;
    Color weatherColor = Colors.orange;
    if (condition.toLowerCase().contains('cloud')) {
      weatherIcon = Icons.cloud_rounded;
      weatherColor = Colors.blueGrey;
    } else if (condition.toLowerCase().contains('rain')) {
      weatherIcon = Icons.umbrella_rounded;
      weatherColor = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: weatherColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: weatherColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(weatherIcon, color: weatherColor, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      condition,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: weatherColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${temp['min']}° – ${temp['max']}°C',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.water_drop_rounded,
                      size: 11,
                      color: Colors.blue.shade400,
                    ),
                    Text(
                      ' ${weather['humidity']}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  advisory,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task, int taskIndex) {
    final isCompleted = task['isCompleted'] as bool;
    final steps = task['steps'] as List;
    final materials = task['materials'] as List;
    final safetyTips = task['safetyTips'] as List;
    final isExpanded =
        _expandedTask != null && _expandedTask!['taskId'] == task['taskId'];

    return GestureDetector(
      onTap:
          () => setState(() {
            _expandedTask = isExpanded ? null : task;
          }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isCompleted
                    ? Colors.green.shade200
                    : isExpanded
                    ? const Color(0xFF2E7D32)
                    : Colors.transparent,
            width: isExpanded ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Task Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap:
                        () => setState(() {
                          task['isCompleted'] = !isCompleted;
                        }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color:
                            isCompleted
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isCompleted
                            ? Icons.check_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color:
                            isCompleted
                                ? Colors.white
                                : const Color(0xFF2E7D32),
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task['title'] as String,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color:
                                isCompleted
                                    ? Colors.grey.shade400
                                    : const Color(0xFF1A2E1A),
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          task['description'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isCompleted
                                  ? const Color(0xFFE8F5E9)
                                  : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isCompleted ? 'Done ✓' : '${steps.length} steps',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color:
                                isCompleted
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFFE65100),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Icon(
                        isExpanded
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Expandable Detail
            if (isExpanded) ...[
              Container(
                width: double.infinity,
                height: 1,
                color: const Color(0xFFE8F5E9),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Steps — clear numbered instructions
                    _buildDetailSection(
                      Icons.format_list_numbered_rounded,
                      'How to do it — step by step',
                      const Color(0xFF1565C0),
                      const Color(0xFFE3F2FD),
                      steps.map((s) {
                        final step = s as Map<String, dynamic>;
                        return '${step['stepNumber']}. ${step['instruction']}';
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    // Materials — items needed
                    _buildDetailSection(
                      Icons.handyman_rounded,
                      'Things you will need',
                      const Color(0xFFE65100),
                      const Color(0xFFFFF3E0),
                      materials.cast<String>(),
                    ),
                    const SizedBox(height: 12),
                    // Safety tips — plain language
                    _buildDetailSection(
                      Icons.shield_rounded,
                      'Be careful — safety tips',
                      const Color(0xFFD32F2F),
                      const Color(0xFFFFEBEE),
                      safetyTips.cast<String>(),
                    ),
                    const SizedBox(height: 12),
                    // Mark done button
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap:
                            () => setState(() {
                              task['isCompleted'] = !isCompleted;
                            }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors:
                                  isCompleted
                                      ? [
                                        Colors.grey.shade300,
                                        Colors.grey.shade200,
                                      ]
                                      : [
                                        const Color(0xFF2E7D32),
                                        const Color(0xFF1B5E20),
                                      ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isCompleted
                                    ? Icons.close_rounded
                                    : Icons.check_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isCompleted
                                    ? 'Mark as Not Done Yet'
                                    : 'I Have Done This ✓',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(
    IconData icon,
    String title,
    Color color,
    Color bg,
    List<String> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 13),
            ),
            const SizedBox(width: 7),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.only(top: 5, right: 8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      height: 1.4,
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

  // ── Weekly View ────────────────────────────────────────────────────────────

  Widget _buildWeeklyPlanView() {
    final months = planData['months'] as List;
    final month = months[_selectedMonthIndex] as Map<String, dynamic>;
    final weeks = month['weeks'] as List;

    if (weeks.isEmpty) {
      return _buildEmptyState('No weeks planned for this month yet.');
    }

    return Column(
      key: ValueKey('weekly_$_selectedMonthIndex'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMonthSelectorChips(),
        const SizedBox(height: 14),
        ...weeks.asMap().entries.map((wEntry) {
          final wIdx = wEntry.key;
          final week = wEntry.value as Map<String, dynamic>;
          final days = week['days'] as List;
          final totalTasks = days.fold<int>(
            0,
            (sum, d) => sum + ((d as Map)['tasks'] as List).length,
          );
          final completedTasks = days.fold<int>(0, (sum, d) {
            final tasks = (d as Map)['tasks'] as List;
            return sum +
                tasks.where((t) => (t as Map)['isCompleted'] == true).length;
          });
          final progress = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;
          final isExpanded = _selectedWeekIndex == wIdx;

          return GestureDetector(
            onTap:
                () => setState(() {
                  _selectedWeekIndex = isExpanded ? -1 : wIdx;
                }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isExpanded ? const Color(0xFF2E7D32) : Colors.transparent,
                  width: isExpanded ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient:
                                    isExpanded
                                        ? const LinearGradient(
                                          colors: [
                                            Color(0xFF43A047),
                                            Color(0xFF1B5E20),
                                          ],
                                        )
                                        : LinearGradient(
                                          colors: [
                                            Colors.grey.shade100,
                                            Colors.grey.shade50,
                                          ],
                                        ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'W${week['weekNumber']}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color:
                                        isExpanded
                                            ? Colors.white
                                            : Colors.grey.shade600,
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
                                    'Week ${week['weekNumber']}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1A2E1A),
                                    ),
                                  ),
                                  Text(
                                    week['summary'] as String,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$completedTasks/$totalTasks',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color:
                                        progress == 1.0
                                            ? const Color(0xFF2E7D32)
                                            : Colors.grey.shade700,
                                  ),
                                ),
                                Text(
                                  'tasks',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isExpanded
                                  ? Icons.expand_less_rounded
                                  : Icons.expand_more_rounded,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progress == 1.0
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFF66BB6A),
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isExpanded) ...[
                    Container(height: 1, color: const Color(0xFFE8F5E9)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            days.map((d) {
                              final day = d as Map<String, dynamic>;
                              final dayTasks = day['tasks'] as List;
                              final weather =
                                  day['weather'] as Map<String, dynamic>;
                              return _buildWeekDayRow(day, dayTasks, weather);
                            }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWeekDayRow(
    Map<String, dynamic> day,
    List dayTasks,
    Map<String, dynamic> weather,
  ) {
    final condition = weather['condition'] as String;
    final temp = weather['temperature'] as Map<String, dynamic>;

    IconData weatherIcon = Icons.wb_sunny_rounded;
    Color weatherColor = Colors.orange;
    if (condition.toLowerCase().contains('cloud')) {
      weatherIcon = Icons.cloud_rounded;
      weatherColor = Colors.blueGrey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8F5E9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Day ${day['dayNumber']}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(weatherIcon, size: 13, color: weatherColor),
              Text(
                ' ${temp['min']}°–${temp['max']}°C',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              const Spacer(),
              Text(
                '${dayTasks.length} task${dayTasks.length > 1 ? 's' : ''}',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...dayTasks.map((t) {
            final task = t as Map<String, dynamic>;
            final done = task['isCompleted'] as bool;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    done
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 14,
                    color:
                        done ? const Color(0xFF2E7D32) : Colors.grey.shade400,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      task['title'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            done
                                ? Colors.grey.shade400
                                : const Color(0xFF1A2E1A),
                        decoration: done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Monthly View ───────────────────────────────────────────────────────────

  Widget _buildMonthlyPlanView() {
    final months = planData['months'] as List;

    return Column(
      key: const ValueKey('monthly'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: months.length,
            itemBuilder: (context, index) {
              final month = months[index] as Map<String, dynamic>;
              final isSelected = _selectedMonthIndex == index;
              final progress = (month['progress'] as double?) ?? 0.0;
              final weeks = month['weeks'] as List;
              final totalDays = weeks.fold<int>(
                0,
                (sum, w) => sum + ((w as Map)['days'] as List).length,
              );

              return GestureDetector(
                onTap:
                    () => setState(() {
                      _selectedMonthIndex = index;
                      _selectedWeekIndex = 0;
                    }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 180,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient:
                        isSelected
                            ? const LinearGradient(
                              colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                            : LinearGradient(
                              colors: [Colors.white, Colors.grey.shade50],
                            ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color:
                            isSelected
                                ? const Color(0xFF2E7D32).withOpacity(0.3)
                                : Colors.black.withOpacity(0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            month['monthName'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color:
                                  isSelected
                                      ? Colors.white
                                      : const Color(0xFF1A2E1A),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? Colors.white.withOpacity(0.2)
                                      : const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${(progress * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color:
                                    isSelected
                                        ? Colors.white
                                        : const Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        month['summary'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color:
                              isSelected
                                  ? Colors.white70
                                  : Colors.grey.shade500,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor:
                              isSelected
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isSelected
                                ? Colors.greenAccent
                                : const Color(0xFF66BB6A),
                          ),
                          minHeight: 5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$totalDays working days • ${weeks.length} weeks',
                        style: TextStyle(
                          fontSize: 10,
                          color:
                              isSelected
                                  ? Colors.white60
                                  : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 18),

        _buildMonthDetailView(
          months[_selectedMonthIndex] as Map<String, dynamic>,
        ),
      ],
    );
  }

  Widget _buildMonthDetailView(Map<String, dynamic> month) {
    final weeks = month['weeks'] as List;

    if (weeks.isEmpty) {
      return _buildEmptyState(
        'No work scheduled for ${month['monthName']} yet.\nCheck back soon!',
      );
    }

    int totalTasks = 0, completedTasks = 0;
    for (final w in weeks) {
      final days = (w as Map)['days'] as List;
      for (final d in days) {
        final tasks = (d as Map)['tasks'] as List;
        totalTasks += tasks.length;
        completedTasks +=
            tasks.where((t) => (t as Map)['isCompleted'] == true).length as int;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMonthStatCard(
                'Total Weeks',
                '${weeks.length}',
                Icons.view_week_rounded,
                const Color(0xFF1565C0),
                const Color(0xFFE3F2FD),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMonthStatCard(
                'Total Tasks',
                '$totalTasks',
                Icons.task_alt_rounded,
                const Color(0xFF2E7D32),
                const Color(0xFFE8F5E9),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMonthStatCard(
                'Finished',
                '$completedTasks',
                Icons.check_circle_rounded,
                const Color(0xFFE65100),
                const Color(0xFFFFF3E0),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        const Text(
          'Week by Week Breakdown',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A2E1A),
          ),
        ),
        const SizedBox(height: 10),

        ...weeks.asMap().entries.map((entry) {
          final week = entry.value as Map<String, dynamic>;
          final days = week['days'] as List;
          final wTotalTasks = days.fold<int>(
            0,
            (s, d) => s + ((d as Map)['tasks'] as List).length,
          );
          final wDone = days.fold<int>(0, (s, d) {
            final tasks = (d as Map)['tasks'] as List;
            return s +
                    tasks.where((t) => (t as Map)['isCompleted'] == true).length
                as int;
          });
          final wProgress = wTotalTasks == 0 ? 0.0 : wDone / wTotalTasks;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color:
                        wProgress > 0
                            ? const Color(0xFFE8F5E9)
                            : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'W${week['weekNumber']}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color:
                            wProgress > 0
                                ? const Color(0xFF2E7D32)
                                : Colors.grey.shade500,
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
                        week['summary'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A2E1A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${days.length} days • $wDone/$wTotalTasks tasks finished',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: wProgress,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            wProgress == 1.0
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFF66BB6A),
                          ),
                          minHeight: 5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  wProgress == 1.0
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color:
                      wProgress == 1.0
                          ? const Color(0xFF2E7D32)
                          : Colors.grey.shade300,
                  size: 22,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMonthStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    Color bg,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelectorChips() {
    final months = planData['months'] as List;
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: months.length,
        itemBuilder: (context, index) {
          final month = months[index] as Map<String, dynamic>;
          final isSelected = _selectedMonthIndex == index;
          return GestureDetector(
            onTap:
                () => setState(() {
                  _selectedMonthIndex = index;
                  _selectedWeekIndex = 0;
                  _selectedDayPlanIndex = 0;
                }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  month['monthName'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.eco_rounded, size: 40, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
