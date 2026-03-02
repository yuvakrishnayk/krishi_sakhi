import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────
// MAIN NAVIGATION
// ─────────────────────────────────────────────
class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabController;

  final List<Widget> _screens = const [
    DashboardScreen(),
    FieldMapScreen(),
    AnalyticsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    const items = [
      {'icon': Icons.dashboard_rounded, 'label': 'Dashboard'},
      {'icon': Icons.map_rounded, 'label': 'Fields'},
      {'icon': Icons.bar_chart_rounded, 'label': 'Analytics'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isSelected = _currentIndex == index;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _currentIndex = index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected ? 20 : 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? const Color(0xFF2E7D32)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        items[index]['icon'] as IconData,
                        color: isSelected ? Colors.white : Colors.grey.shade500,
                        size: 22,
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Text(
                          items[index]['label'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// DASHBOARD SCREEN
// ─────────────────────────────────────────────
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final today = DateTime.now();
  int _selectedDayIndex = 3;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

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
                  _buildQuickStatsRow(),
                  _buildMiniLandMapCard(),
                  _buildAdvisoryCard(),
                  _buildRoadmapTimeline(),
                  _buildTasksSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                'Smart Farm Manager',
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
                child: Column(
                  children: const [
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
              _buildWeatherStat(Icons.water_drop_rounded, '68%', 'Humidity'),
              _buildWeatherStat(Icons.air_rounded, '12 km/h', 'Wind'),
              _buildWeatherStat(Icons.umbrella_rounded, '5%', 'Rain'),
              _buildWeatherStat(
                Icons.visibility_rounded,
                '10 km',
                'Visibility',
              ),
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
                  'Ideal conditions for irrigation today',
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

  Widget _buildDateStrip() {
    final dates = List.generate(7, (i) {
      return DateTime(today.year, today.month, today.day + (i - 3));
    });

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

  Widget _buildQuickStatsRow() {
    final stats = [
      {
        'label': 'Soil pH',
        'value': '6.8',
        'icon': Icons.science_rounded,
        'color': const Color(0xFF1565C0),
        'bg': const Color(0xFFE3F2FD),
        'trend': '+0.2',
        'good': true,
      },
      {
        'label': 'NPK Level',
        'value': 'Optimal',
        'icon': Icons.grass_rounded,
        'color': const Color(0xFF2E7D32),
        'bg': const Color(0xFFE8F5E9),
        'trend': 'Good',
        'good': true,
      },
      {
        'label': 'Yield Est.',
        'value': '4.2 T',
        'icon': Icons.agriculture_rounded,
        'color': const Color(0xFFE65100),
        'bg': const Color(0xFFFFF3E0),
        'trend': '+12%',
        'good': true,
      },
      {
        'label': 'Pest Risk',
        'value': 'High',
        'icon': Icons.pest_control_rounded,
        'color': const Color(0xFFC62828),
        'bg': const Color(0xFFFFEBEE),
        'trend': '⚠ Act',
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

  Widget _buildMiniLandMapCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.map_rounded, color: Color(0xFF2E7D32), size: 18),
                    SizedBox(width: 8),
                    Text(
                      'My Land Map',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A2E1A),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '3.2 acres',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.zero),
            child: _LandMapCanvas(),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildLandLegend(const Color(0xFF4CAF50), 'Rice Field'),
                const SizedBox(width: 12),
                _buildLandLegend(const Color(0xFF2196F3), 'Water Channel'),
                const SizedBox(width: 12),
                _buildLandLegend(const Color(0xFFFF9800), 'Storage Area'),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                  ),
                  child: const Text(
                    'Full Map →',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 9, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildAdvisoryCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.tips_and_updates_rounded,
                  color: Color(0xFFF57F17),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'AI Advisory',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A2E1A),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFD32F2F),
                      size: 12,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Alert',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD32F2F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAdvisoryItem(
            Icons.pest_control_rounded,
            'Leaf Folder Detected',
            'High risk spotted in the north plot. Apply Chlorpyrifos 2.5ml/L immediately.',
            const Color(0xFFD32F2F),
            const Color(0xFFFFEBEE),
          ),
          const SizedBox(height: 10),
          _buildAdvisoryItem(
            Icons.water_drop_rounded,
            'Irrigation Optimal Today',
            'Moisture at 72%. Best time: 6-8 AM or 5-7 PM.',
            const Color(0xFF1565C0),
            const Color(0xFFE3F2FD),
          ),
          const SizedBox(height: 10),
          _buildAdvisoryItem(
            Icons.grass_rounded,
            'Fertilizer Window Open',
            'Week 6 – Apply 45kg Urea/acre to boost tiller production.',
            const Color(0xFF2E7D32),
            const Color(0xFFE8F5E9),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvisoryItem(
    IconData icon,
    String title,
    String desc,
    Color color,
    Color bg,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
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

  Widget _buildRoadmapTimeline() {
    final phases = [
      {
        'week': 'W1-2',
        'title': 'Land Prep & Nursery',
        'done': true,
        'current': false,
      },
      {'week': 'W3', 'title': 'Transplanting', 'done': false, 'current': true},
      {
        'week': 'W6',
        'title': 'Fertilizer Application',
        'done': false,
        'current': false,
      },
      {
        'week': 'W10',
        'title': 'Pest Monitoring',
        'done': false,
        'current': false,
      },
      {
        'week': 'W14',
        'title': 'Pre-Harvest Prep',
        'done': false,
        'current': false,
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
              const Icon(
                Icons.timeline_rounded,
                color: Color(0xFF2E7D32),
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'Crop Roadmap',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A2E1A),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Week 3 / 14',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children:
                phases.asMap().entries.map((entry) {
                  final i = entry.key;
                  final p = entry.value;
                  final done = p['done'] as bool;
                  final current = p['current'] as bool;
                  return Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 4,
                                decoration: BoxDecoration(
                                  color:
                                      (done || current)
                                          ? const Color(0xFF2E7D32)
                                          : Colors.grey.shade200,
                                  borderRadius:
                                      i == 0
                                          ? const BorderRadius.horizontal(
                                            left: Radius.circular(2),
                                          )
                                          : i == phases.length - 1
                                          ? const BorderRadius.horizontal(
                                            right: Radius.circular(2),
                                          )
                                          : null,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color:
                                      done
                                          ? const Color(0xFF2E7D32)
                                          : current
                                          ? const Color(0xFF66BB6A)
                                          : Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                  border:
                                      current
                                          ? Border.all(
                                            color: const Color(0xFF2E7D32),
                                            width: 2,
                                          )
                                          : null,
                                ),
                                child: Icon(
                                  done
                                      ? Icons.check_rounded
                                      : current
                                      ? Icons.play_arrow_rounded
                                      : Icons.circle_outlined,
                                  size: 14,
                                  color:
                                      done || current
                                          ? Colors.white
                                          : Colors.grey.shade400,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                p['week'] as String,
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      current
                                          ? const Color(0xFF2E7D32)
                                          : Colors.grey.shade500,
                                ),
                              ),
                              Text(
                                p['title'] as String,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 8,
                                  color:
                                      current
                                          ? const Color(0xFF1A2E1A)
                                          : Colors.grey.shade500,
                                  fontWeight:
                                      current
                                          ? FontWeight.w700
                                          : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksSection() {
    final tasks = [
      {
        'title': 'Irrigation Check',
        'time': '11:30 AM',
        'icon': Icons.water_drop_rounded,
        'done': false,
        'priority': 'High',
      },
      {
        'title': 'Pest Monitoring',
        'time': '2:00 PM',
        'icon': Icons.pest_control_rounded,
        'done': false,
        'priority': 'Critical',
      },
      {
        'title': 'Apply Fertilizer',
        'time': '9:00 AM',
        'icon': Icons.grass_rounded,
        'done': true,
        'priority': 'Done',
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Tasks",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A2E1A),
                ),
              ),
              Text(
                '${tasks.where((t) => !(t['done'] as bool)).length} remaining',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tasks.map((task) {
            final done = task['done'] as bool;
            final priority = task['priority'] as String;
            Color priorityColor =
                priority == 'Critical'
                    ? const Color(0xFFD32F2F)
                    : priority == 'High'
                    ? const Color(0xFFF57F17)
                    : const Color(0xFF2E7D32);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: done ? Colors.grey.shade50 : const Color(0xFFF9FBF9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: done ? Colors.grey.shade200 : const Color(0xFFE8F5E9),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          done ? Colors.grey.shade100 : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      task['icon'] as IconData,
                      color:
                          done ? Colors.grey.shade400 : const Color(0xFF2E7D32),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task['title'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            decoration:
                                done ? TextDecoration.lineThrough : null,
                            color:
                                done
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          task['time'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      priority,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: priorityColor,
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
}

// ─────────────────────────────────────────────
// LAND MAP CANVAS (Custom Painter)
// ─────────────────────────────────────────────
class _LandMapCanvas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFE8F5E9),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: _LandMapPainter(),
          child: Stack(
            children: [
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFF2E7D32),
                        size: 12,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'North Plot',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '⚠ Pest Alert Zone',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD32F2F),
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.my_location_rounded,
                    color: Color(0xFF2E7D32),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LandMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background
    final bgPaint = Paint()..color = const Color(0xFFDCEDC8);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Main rice field (green polygon)
    final fieldPaint =
        Paint()..color = const Color(0xFF81C784).withOpacity(0.7);
    final fieldPath =
        Path()
          ..moveTo(size.width * 0.05, size.height * 0.1)
          ..lineTo(size.width * 0.7, size.height * 0.08)
          ..lineTo(size.width * 0.75, size.height * 0.6)
          ..lineTo(size.width * 0.45, size.height * 0.85)
          ..lineTo(size.width * 0.05, size.height * 0.8)
          ..close();
    canvas.drawPath(fieldPath, fieldPaint);

    // Field border
    final borderPaint =
        Paint()
          ..color = const Color(0xFF388E3C)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    canvas.drawPath(fieldPath, borderPaint);

    // Grid lines (rice rows)
    final gridPaint =
        Paint()
          ..color = const Color(0xFF2E7D32).withOpacity(0.15)
          ..strokeWidth = 0.8;
    for (int i = 1; i < 8; i++) {
      canvas.drawLine(
        Offset(size.width * 0.05, size.height * (0.1 + i * 0.09)),
        Offset(size.width * 0.72, size.height * (0.08 + i * 0.08)),
        gridPaint,
      );
    }

    // Water channel (blue)
    final waterPaint =
        Paint()
          ..color = const Color(0xFF42A5F5).withOpacity(0.8)
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.72, size.height * 0.1),
      Offset(size.width * 0.95, size.height * 0.5),
      waterPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.45, size.height * 0.85),
      Offset(size.width * 0.95, size.height * 0.85),
      waterPaint,
    );

    // Storage area (orange)
    final storagePaint =
        Paint()..color = const Color(0xFFFFB74D).withOpacity(0.8);
    final storageRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.78,
        size.height * 0.55,
        size.width * 0.16,
        size.height * 0.25,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(storageRect, storagePaint);

    // Pest alert zone (red hatching)
    final pestPaint = Paint()..color = const Color(0xFFEF9A9A).withOpacity(0.4);
    final pestPath =
        Path()
          ..moveTo(size.width * 0.5, size.height * 0.08)
          ..lineTo(size.width * 0.7, size.height * 0.08)
          ..lineTo(size.width * 0.72, size.height * 0.45)
          ..lineTo(size.width * 0.5, size.height * 0.5)
          ..close();
    canvas.drawPath(pestPath, pestPaint);

    final pestBorder =
        Paint()
          ..color = const Color(0xFFD32F2F)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeDash = [4, 4];
    canvas.drawPath(pestPath, pestBorder);

    // Compass
    final compassCenter = Offset(size.width * 0.92, size.height * 0.12);
    final compassPaint = Paint()..color = Colors.white.withOpacity(0.9);
    canvas.drawCircle(compassCenter, 16, compassPaint);
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'N',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1B5E20),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      compassCenter - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

extension on Paint {
  set strokeDash(List<double> _) {}
}

// ─────────────────────────────────────────────
// FIELD MAP SCREEN
// ─────────────────────────────────────────────
class FieldMapScreen extends StatefulWidget {
  const FieldMapScreen({super.key});

  @override
  State<FieldMapScreen> createState() => _FieldMapScreenState();
}

class _FieldMapScreenState extends State<FieldMapScreen> {
  int _selectedField = 0;

  final fields = [
    {
      'name': 'North Plot',
      'crop': 'Samba Rice',
      'area': '1.8 acres',
      'health': 0.78,
      'status': 'Healthy',
      'stage': 'Tillering',
      'moisture': '72%',
      'ndvi': '0.68',
      'pest': 'High Risk',
      'harvest': 'Dec 15',
    },
    {
      'name': 'South Plot',
      'crop': 'Ponni Rice',
      'area': '1.4 acres',
      'health': 0.91,
      'status': 'Excellent',
      'stage': 'Panicle Init.',
      'moisture': '65%',
      'ndvi': '0.82',
      'pest': 'Low Risk',
      'harvest': 'Nov 28',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        title: const Text(
          'Field Overview',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_location_alt_rounded,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Full interactive map
            Container(
              height: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    _FullLandMapCanvas(),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Column(
                        children: [
                          _mapButton(Icons.add_rounded, () {}),
                          const SizedBox(height: 6),
                          _mapButton(Icons.remove_rounded, () {}),
                          const SizedBox(height: 6),
                          _mapButton(Icons.layers_rounded, () {}),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.satellite_alt_rounded,
                              size: 14,
                              color: Color(0xFF2E7D32),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Satellite View',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Field selector tabs
            Row(
              children:
                  fields.asMap().entries.map((e) {
                    final selected = e.key == _selectedField;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedField = e.key),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                selected
                                    ? const Color(0xFF2E7D32)
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                e.value['name'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color:
                                      selected
                                          ? Colors.white
                                          : Colors.grey.shade700,
                                ),
                              ),
                              Text(
                                e.value['area'] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  color:
                                      selected
                                          ? Colors.white70
                                          : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),
            _buildFieldDetails(fields[_selectedField]),
          ],
        ),
      ),
    );
  }

  Widget _mapButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: Colors.grey.shade700),
      ),
    );
  }

  Widget _buildFieldDetails(Map<String, dynamic> field) {
    final health = field['health'] as double;
    final pestRisk = field['pest'] as String;
    final isHighRisk = pestRisk.contains('High');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                field['name'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A2E1A),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  field['status'] as String,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          Text(
            '${field['crop']} • ${field['stage']} Stage',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 16),
          // Health bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Crop Health',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Text(
                '${(health * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: health,
              backgroundColor: Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF4CAF50),
              ),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildFieldStat(
                'Moisture',
                field['moisture'] as String,
                Icons.water_drop_rounded,
                const Color(0xFF1565C0),
              ),
              _buildFieldStat(
                'NDVI Index',
                field['ndvi'] as String,
                Icons.satellite_alt_rounded,
                const Color(0xFF2E7D32),
              ),
              _buildFieldStat(
                'Pest Risk',
                pestRisk,
                Icons.pest_control_rounded,
                isHighRisk ? const Color(0xFFD32F2F) : const Color(0xFF388E3C),
              ),
              _buildFieldStat(
                'Harvest',
                field['harvest'] as String,
                Icons.calendar_month_rounded,
                const Color(0xFFF57F17),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _FullLandMapCanvas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FullMapPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _FullMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Satellite-like background
    final bgPaint =
        Paint()
          ..shader = LinearGradient(
            colors: [
              const Color(0xFF558B2F),
              const Color(0xFF33691E),
              const Color(0xFF1B5E20),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Texture overlay
    final texturePaint = Paint()..color = Colors.black.withOpacity(0.05);
    for (int i = 0; i < 20; i++) {
      for (int j = 0; j < 15; j++) {
        if ((i + j) % 2 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(
              i * size.width / 20,
              j * size.height / 15,
              size.width / 20,
              size.height / 15,
            ),
            texturePaint,
          );
        }
      }
    }

    // North plot
    final northPaint =
        Paint()..color = const Color(0xFF8BC34A).withOpacity(0.85);
    final northPath =
        Path()
          ..moveTo(size.width * 0.05, size.height * 0.08)
          ..lineTo(size.width * 0.55, size.height * 0.06)
          ..lineTo(size.width * 0.58, size.height * 0.55)
          ..lineTo(size.width * 0.35, size.height * 0.75)
          ..lineTo(size.width * 0.05, size.height * 0.7)
          ..close();
    canvas.drawPath(northPath, northPaint);

    final northBorder =
        Paint()
          ..color = Colors.white.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
    canvas.drawPath(northPath, northBorder);

    // South plot
    final southPaint =
        Paint()..color = const Color(0xFF4CAF50).withOpacity(0.85);
    final southPath =
        Path()
          ..moveTo(size.width * 0.35, size.height * 0.75)
          ..lineTo(size.width * 0.58, size.height * 0.55)
          ..lineTo(size.width * 0.62, size.height * 0.95)
          ..lineTo(size.width * 0.1, size.height * 0.95)
          ..close();
    canvas.drawPath(southPath, southPaint);
    canvas.drawPath(southPath, northBorder);

    // Water channel
    final waterPaint =
        Paint()
          ..color = const Color(0xFF29B6F6).withOpacity(0.9)
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.6, 0),
      Offset(size.width * 0.65, size.height),
      waterPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.65, size.height * 0.95),
      Offset(size.width, size.height * 0.95),
      waterPaint,
    );

    // Road
    final roadPaint =
        Paint()
          ..color = const Color(0xFF795548).withOpacity(0.7)
          ..strokeWidth = 14;
    canvas.drawLine(
      Offset(0, size.height * 0.85),
      Offset(size.width, size.height * 0.85),
      roadPaint,
    );

    // Buildings
    final buildPaint =
        Paint()..color = const Color(0xFFFFB74D).withOpacity(0.9);
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.7,
        size.height * 0.3,
        size.width * 0.12,
        size.height * 0.2,
      ),
      buildPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.84,
        size.height * 0.3,
        size.width * 0.1,
        size.height * 0.15,
      ),
      buildPaint,
    );

    // North labels
    _paintLabel(
      canvas,
      'North Plot',
      Offset(size.width * 0.25, size.height * 0.35),
    );
    _paintLabel(
      canvas,
      'South Plot',
      Offset(size.width * 0.32, size.height * 0.82),
    );
    _paintLabel(
      canvas,
      '1.8 ac',
      Offset(size.width * 0.25, size.height * 0.43),
      small: true,
    );
    _paintLabel(
      canvas,
      '1.4 ac',
      Offset(size.width * 0.32, size.height * 0.9),
      small: true,
    );
  }

  void _paintLabel(
    Canvas canvas,
    String text,
    Offset position, {
    bool small = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: small ? 10 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, position - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────
// ANALYTICS SCREEN
// ─────────────────────────────────────────────
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        title: const Text(
          'Analytics',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Yield'),
            Tab(text: 'Weather'),
            Tab(text: 'Expenses'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildYieldTab(), _buildWeatherTab(), _buildExpensesTab()],
      ),
    );
  }

  Widget _buildYieldTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildYieldCard(),
          const SizedBox(height: 16),
          _buildYieldHistoryChart(),
          const SizedBox(height: 16),
          _buildCropComparisonCard(),
        ],
      ),
    );
  }

  Widget _buildYieldCard() {
    return Container(
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
          const Text(
            'Estimated Yield 2024',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '4.2',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              SizedBox(width: 8),
              Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Tons/Acre',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildYieldStat('vs Last Year', '+12%', Colors.greenAccent),
              const SizedBox(width: 24),
              _buildYieldStat('District Avg', '3.8 T', Colors.white70),
              const SizedBox(width: 24),
              _buildYieldStat('Target', '4.5 T', Colors.white70),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYieldStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildYieldHistoryChart() {
    final months = ['Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final values = [2.1, 2.8, 3.2, 3.8, 4.0, 4.2];
    final maxVal = 5.0;

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
            'Growth Progress',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A2E1A),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(months.length, (i) {
                final barHeight = (values[i] / maxVal) * 120;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      values[i].toString(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300 + i * 100),
                      width: 32,
                      height: barHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF4CAF50),
                            const Color(0xFF1B5E20),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      months[i],
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
    );
  }

  Widget _buildCropComparisonCard() {
    final crops = [
      {'name': 'Samba Rice', 'yield': 4.2, 'profit': '₹85,000'},
      {'name': 'Ponni Rice', 'yield': 3.8, 'profit': '₹72,000'},
      {'name': 'Kala Jeera', 'yield': 2.9, 'profit': '₹95,000'},
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
            (c) => Padding(
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
                          c['name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (c['yield'] as double) / 5.0,
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
                        '${c['yield']}T',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      Text(
                        c['profit'] as String,
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
    final forecast = [
      {
        'day': 'Today',
        'icon': Icons.wb_sunny_rounded,
        'high': 32,
        'low': 24,
        'rain': '5%',
        'color': Colors.orange,
      },
      {
        'day': 'Tomorrow',
        'icon': Icons.cloud_rounded,
        'high': 29,
        'low': 22,
        'rain': '20%',
        'color': Colors.grey,
      },
      {
        'day': 'Wed',
        'icon': Icons.thunderstorm_rounded,
        'high': 26,
        'low': 21,
        'rain': '75%',
        'color': Colors.blueGrey,
      },
      {
        'day': 'Thu',
        'icon': Icons.grain_rounded,
        'high': 27,
        'low': 22,
        'rain': '60%',
        'color': Colors.blue,
      },
      {
        'day': 'Fri',
        'icon': Icons.wb_sunny_rounded,
        'high': 31,
        'low': 23,
        'rain': '10%',
        'color': Colors.orange,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
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
                  '5-Day Forecast',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A2E1A),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:
                      forecast.map((f) {
                        return Column(
                          children: [
                            Text(
                              f['day'] as String,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Icon(
                              f['icon'] as IconData,
                              color: f['color'] as Color,
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${f['high']}°',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${f['low']}°',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                f['rain'] as String,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF1565C0),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF42A5F5).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFF1565C0),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Heavy Rain Alert – Wednesday',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Expected 35mm rainfall. Consider delaying pesticide application.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesTab() {
    final expenses = [
      {
        'category': 'Seeds',
        'amount': 4200,
        'icon': Icons.grass_rounded,
        'color': const Color(0xFF2E7D32),
      },
      {
        'category': 'Fertilizers',
        'amount': 8500,
        'icon': Icons.science_rounded,
        'color': const Color(0xFF1565C0),
      },
      {
        'category': 'Pesticides',
        'amount': 3200,
        'icon': Icons.pest_control_rounded,
        'color': const Color(0xFFD32F2F),
      },
      {
        'category': 'Labour',
        'amount': 12000,
        'icon': Icons.people_rounded,
        'color': const Color(0xFFF57F17),
      },
      {
        'category': 'Irrigation',
        'amount': 5600,
        'icon': Icons.water_drop_rounded,
        'color': const Color(0xFF0097A7),
      },
    ];
    final total = expenses.fold(0, (sum, e) => sum + (e['amount'] as int));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
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
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Expenses',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '₹33,500',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Season 2024',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
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
                    const Text(
                      '₹85,000',
                      style: TextStyle(
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
                      child: const Text(
                        'Profit: ₹51,500',
                        style: TextStyle(
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
                ...expenses.map((e) {
                  final pct = (e['amount'] as int) / total;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (e['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            e['icon'] as IconData,
                            color: e['color'] as Color,
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
                                  Text(
                                    e['category'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    '₹${e['amount']}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: e['color'] as Color,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  backgroundColor: Colors.grey.shade100,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    e['color'] as Color,
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
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PROFILE SCREEN
// ─────────────────────────────────────────────
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F0),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF1B5E20),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Center(
                        child: Text(
                          'RK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ramesh Kumar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'Farmer • Madurai, TN',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatRow(),
                  const SizedBox(height: 16),
                  _buildBadgesSection(),
                  const SizedBox(height: 16),
                  _buildProfileMenu(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow() {
    return Row(
      children: [
        _buildProfileStat('3.2', 'Total Acres', Icons.landscape_rounded),
        _buildProfileStat('2', 'Active Fields', Icons.eco_rounded),
        _buildProfileStat('4', 'Seasons', Icons.calendar_today_rounded),
        _buildProfileStat('92%', 'Success Rate', Icons.trending_up_rounded),
      ],
    );
  }

  Widget _buildProfileStat(String value, String label, IconData icon) {
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
          children: [
            Icon(icon, color: const Color(0xFF2E7D32), size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: Color(0xFF1A2E1A),
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesSection() {
    final badges = [
      {'label': 'Top Farmer', 'icon': '🏆', 'color': const Color(0xFFFFF8E1)},
      {'label': 'Water Saver', 'icon': '💧', 'color': const Color(0xFFE3F2FD)},
      {'label': 'Eco Warrior', 'icon': '🌿', 'color': const Color(0xFFE8F5E9)},
      {'label': '4 Seasons', 'icon': '🌾', 'color': const Color(0xFFFCE4EC)},
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
            'Achievements',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A2E1A),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                badges.map((b) {
                  return Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: b['color'] as Color,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            b['icon'] as String,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        b['label'] as String,
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenu() {
    final items = [
      {
        'icon': Icons.person_outline_rounded,
        'title': 'Edit Profile',
        'sub': 'Update your info',
      },
      {
        'icon': Icons.notifications_outlined,
        'title': 'Notifications',
        'sub': 'Manage alerts',
      },
      {
        'icon': Icons.language_rounded,
        'title': 'Language',
        'sub': 'Tamil / English',
      },
      {
        'icon': Icons.support_agent_rounded,
        'title': 'Support',
        'sub': 'Get help from KVK',
      },
      {
        'icon': Icons.share_rounded,
        'title': 'Share App',
        'sub': 'Refer a farmer',
      },
      {
        'icon': Icons.logout_rounded,
        'title': 'Logout',
        'sub': 'Sign out safely',
      },
    ];

    return Container(
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
        children:
            items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final isLast = i == items.length - 1;
              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            i == items.length - 1
                                ? const Color(0xFFFFEBEE)
                                : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color:
                            i == items.length - 1
                                ? const Color(0xFFD32F2F)
                                : const Color(0xFF2E7D32),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      item['title'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color:
                            i == items.length - 1
                                ? const Color(0xFFD32F2F)
                                : Colors.grey.shade800,
                      ),
                    ),
                    subtitle: Text(
                      item['sub'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onTap: () {},
                  ),
                  if (!isLast)
                    Divider(height: 1, indent: 70, color: Colors.grey.shade100),
                ],
              );
            }).toList(),
      ),
    );
  }
}
