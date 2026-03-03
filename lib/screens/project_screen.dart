import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
void main() => runApp(const MaterialApp(home: ProjectScreen(),debugShowCheckedModeBanner: false,));
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
  late AnimationController _navController;
  late Animation<double> _navAnimation;
  bool _showQuickActions = false;

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
    _navController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _navAnimation = CurvedAnimation(
      parent: _navController,
      curve: Curves.easeOutBack,
    );
    _navController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    _navController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.03),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey(_currentIndex),
              child: _screens[_currentIndex],
            ),
          ),
          // Floating Quick Actions
          if (_showQuickActions) _buildQuickActionsOverlay(),
          // Innovative Floating Navigation Dock
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildFloatingNavDock(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsOverlay() {
    return GestureDetector(
      onTap: () => setState(() => _showQuickActions = false),
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildQuickActionItem(
                Icons.camera_alt_rounded,
                'Scan Crop',
                () {},
              ),
              const SizedBox(height: 16),
              _buildQuickActionItem(Icons.mic_rounded, 'Voice Query', () {}),
              const SizedBox(height: 16),
              _buildQuickActionItem(Icons.add_task_rounded, 'Add Task', () {}),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () => setState(() => _showQuickActions = false),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() => _showQuickActions = false);
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF1B5E20), size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF1B5E20),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingNavDock() {
    return ScaleTransition(
      scale: _navAnimation,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.95),
              Colors.white.withOpacity(0.85),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B5E20).withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.space_dashboard_rounded, 'Home'),
            _buildNavItem(1, Icons.terrain_rounded, 'Fields'),
            _buildCenterActionButton(),
            _buildNavItem(2, Icons.insights_rounded, 'Stats'),
            _buildNavItem(3, Icons.person_rounded, 'Me'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _currentIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient:
              isSelected
                  ? const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade500,
                size: 22,
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1.0 : 0.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: isSelected ? 14 : 0,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterActionButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        setState(() => _showQuickActions = true);
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF43A047), Color(0xFF1B5E20)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B5E20).withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Animated ring
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(seconds: 2),
              builder: (context, value, child) {
                return Container(
                  width: 50 + (value * 6),
                  height: 50 + (value * 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3 * (1 - value)),
                      width: 2,
                    ),
                  ),
                );
              },
            ),
            const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 26,
            ),
          ],
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
                  _buildFieldHealthSummary(),
                  _buildAdvisoryCard(),
                  _buildRoadmapTimeline(),
                  _buildTasksSection(),
                  const SizedBox(height: 100),
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

  Widget _buildFieldHealthSummary() {
    final fields = [
      {
        'name': 'North Plot',
        'crop': 'Samba Rice',
        'health': 0.78,
        'status': 'Tillering',
        'alert': true,
        'alertText': 'Pest Alert',
        'color': const Color(0xFF4CAF50),
      },
      {
        'name': 'South Plot',
        'crop': 'Ponni Rice',
        'health': 0.91,
        'status': 'Panicle Init.',
        'alert': false,
        'alertText': '',
        'color': const Color(0xFF66BB6A),
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.terrain_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Field Health',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A2E1A),
                        ),
                      ),
                      Text(
                        '2 active fields • 3.2 acres',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.visibility_rounded,
                      size: 14,
                      color: Color(0xFF2E7D32),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'View Map',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...fields.map((field) {
            final health = field['health'] as double;
            final hasAlert = field['alert'] as bool;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (field['color'] as Color).withOpacity(0.08),
                    (field['color'] as Color).withOpacity(0.02),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (field['color'] as Color).withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  // Health Ring
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            value: health,
                            strokeWidth: 5,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              field['color'] as Color,
                            ),
                          ),
                        ),
                        Text(
                          '${(health * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A2E1A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              field['name'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Color(0xFF1A2E1A),
                              ),
                            ),
                            if (hasAlert) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEBEE),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.warning_rounded,
                                      size: 10,
                                      color: Color(0xFFD32F2F),
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      'Alert',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFD32F2F),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${field['crop']} • ${field['status']}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade400,
                    size: 22,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
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
// FIELD MAP SCREEN
// ─────────────────────────────────────────────
class FieldMapScreen extends StatefulWidget {
  const FieldMapScreen({super.key});

  @override
  State<FieldMapScreen> createState() => _FieldMapScreenState();
}

class _FieldMapScreenState extends State<FieldMapScreen>
    with TickerProviderStateMixin {
  int _selectedField = 0;
  int _mapLayer = 0; // 0: Satellite, 1: NDVI, 2: Moisture
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

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
      'color': const Color(0xFF8BC34A),
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
      'color': const Color(0xFF4CAF50),
    },
  ];

  final mapLayers = ['Satellite', 'NDVI', 'Moisture'];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F0),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildInteractiveMap(),
                _buildLayerSelector(),
                _buildFieldCards(),
                _buildFieldDetails(fields[_selectedField]),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.terrain_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Field Map',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '3.2 acres total',
                style: TextStyle(color: Colors.white60, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.gps_fixed_rounded, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.fullscreen_rounded, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildInteractiveMap() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withOpacity(0.25),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Map Canvas with 3D Transform
            Transform(
              transform:
                  Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(-0.05),
              alignment: Alignment.center,
              child: _Enhanced3DMapCanvas(
                selectedField: _selectedField,
                mapLayer: _mapLayer,
              ),
            ),
            // Animated Alert Marker
            if (fields[0]['pest'] == 'High Risk')
              Positioned(
                top: 80,
                left: 100,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFD32F2F).withOpacity(0.3),
                        ),
                        child: Center(
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFD32F2F),
                            ),
                            child: const Icon(
                              Icons.warning_rounded,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            // Glassmorphism Control Buttons
            Positioned(
              top: 12,
              right: 12,
              child: Column(
                children: [
                  _buildGlassButton(Icons.add_rounded, () {}),
                  const SizedBox(height: 8),
                  _buildGlassButton(Icons.remove_rounded, () {}),
                  const SizedBox(height: 8),
                  _buildGlassButton(Icons.my_location_rounded, () {}),
                ],
              ),
            ),
            // Compass
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'N',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 2,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B5E20),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Scale indicator
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '50m',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Legend
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.95),
                      Colors.white.withOpacity(0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem(const Color(0xFF8BC34A), 'North Plot'),
                    const SizedBox(height: 4),
                    _buildLegendItem(const Color(0xFF4CAF50), 'South Plot'),
                    const SizedBox(height: 4),
                    _buildLegendItem(const Color(0xFF29B6F6), 'Water'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.9),
              Colors.white.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF1B5E20)),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.4), blurRadius: 4),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A2E1A),
          ),
        ),
      ],
    );
  }

  Widget _buildLayerSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children:
            mapLayers.asMap().entries.map((e) {
              final selected = e.key == _mapLayer;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _mapLayer = e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient:
                          selected
                              ? const LinearGradient(
                                colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                              )
                              : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          e.key == 0
                              ? Icons.satellite_alt_rounded
                              : e.key == 1
                              ? Icons.grass_rounded
                              : Icons.water_drop_rounded,
                          size: 16,
                          color: selected ? Colors.white : Colors.grey.shade500,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          e.value,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color:
                                selected ? Colors.white : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildFieldCards() {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: fields.length,
        itemBuilder: (context, index) {
          final field = fields[index];
          final selected = index == _selectedField;
          return GestureDetector(
            onTap: () => setState(() => _selectedField = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 160,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient:
                    selected
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
                        selected
                            ? const Color(0xFF2E7D32).withOpacity(0.35)
                            : Colors.black.withOpacity(0.06),
                    blurRadius: selected ? 16 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color:
                      selected
                          ? Colors.transparent
                          : (field['color'] as Color).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        field['name'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color:
                              selected ? Colors.white : const Color(0xFF1A2E1A),
                        ),
                      ),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: field['color'] as Color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (field['color'] as Color).withOpacity(0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    field['crop'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: selected ? Colors.white70 : Colors.grey.shade500,
                    ),
                  ),
                  Row(
                    children: [
                      _buildMiniStat(
                        '${((field['health'] as double) * 100).toInt()}%',
                        selected,
                      ),
                      const SizedBox(width: 8),
                      _buildMiniStat(field['area'] as String, selected),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniStat(String value, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            selected ? Colors.white.withOpacity(0.2) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: selected ? Colors.white : const Color(0xFF2E7D32),
        ),
      ),
    );
  }

  Widget _buildFieldDetails(Map<String, dynamic> field) {
    final health = field['health'] as double;
    final pestRisk = field['pest'] as String;
    final isHighRisk = pestRisk.contains('High');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (field['color'] as Color).withOpacity(0.2),
                      (field['color'] as Color).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.landscape_rounded,
                  color: field['color'] as Color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          field['name'] as String,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A2E1A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF4CAF50).withOpacity(0.2),
                                const Color(0xFF2E7D32).withOpacity(0.1),
                              ],
                            ),
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
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Health Progress with Gradient
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Crop Health Index',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A2E1A),
                ),
              ),
              Text(
                '${(health * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: field['color'] as Color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: health,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          (field['color'] as Color).withOpacity(0.7),
                          field['color'] as Color,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: (field['color'] as Color).withOpacity(0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Stats Grid
          Row(
            children: [
              _buildFieldStat(
                'Moisture',
                field['moisture'] as String,
                Icons.water_drop_rounded,
                const Color(0xFF1565C0),
              ),
              _buildFieldStat(
                'NDVI',
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
                Icons.event_rounded,
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
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced 3D Map Canvas
class _Enhanced3DMapCanvas extends StatelessWidget {
  final int selectedField;
  final int mapLayer;

  const _Enhanced3DMapCanvas({
    required this.selectedField,
    required this.mapLayer,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _Enhanced3DMapPainter(
        selectedField: selectedField,
        mapLayer: mapLayer,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _Enhanced3DMapPainter extends CustomPainter {
  final int selectedField;
  final int mapLayer;

  _Enhanced3DMapPainter({required this.selectedField, required this.mapLayer});

  @override
  void paint(Canvas canvas, Size size) {
    // Rich gradient background based on layer
    final List<Color> bgColors =
        mapLayer == 0
            ? [
              const Color(0xFF2E5A1C),
              const Color(0xFF1B4512),
              const Color(0xFF0D2D08),
            ]
            : mapLayer == 1
            ? [
              const Color(0xFF1E3A14),
              const Color(0xFF2D5A1E),
              const Color(0xFF4A7A32),
            ]
            : [
              const Color(0xFF1A3A4A),
              const Color(0xFF2A5A6A),
              const Color(0xFF3A7A8A),
            ];

    final bgPaint =
        Paint()
          ..shader = LinearGradient(
            colors: bgColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Subtle pattern overlay
    final patternPaint = Paint()..color = Colors.white.withOpacity(0.02);
    for (int i = 0; i < 30; i++) {
      for (int j = 0; j < 20; j++) {
        if ((i + j) % 3 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(
              i * size.width / 30,
              j * size.height / 20,
              size.width / 30,
              size.height / 20,
            ),
            patternPaint,
          );
        }
      }
    }

    // North plot
    final northColor =
        mapLayer == 0
            ? const Color(0xFF8BC34A)
            : mapLayer == 1
            ? const Color(0xFFFFEB3B)
            : const Color(0xFF4FC3F7);
    final northPaint =
        Paint()
          ..color = northColor.withOpacity(selectedField == 0 ? 0.95 : 0.7);
    final northPath =
        Path()
          ..moveTo(size.width * 0.05, size.height * 0.08)
          ..lineTo(size.width * 0.55, size.height * 0.06)
          ..lineTo(size.width * 0.58, size.height * 0.52)
          ..lineTo(size.width * 0.35, size.height * 0.72)
          ..lineTo(size.width * 0.05, size.height * 0.68)
          ..close();
    canvas.drawPath(northPath, northPaint);

    // North plot glow when selected
    if (selectedField == 0) {
      final glowPaint =
          Paint()
            ..color = Colors.white.withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8);
      canvas.drawPath(northPath, glowPaint);
    }

    // North plot border
    final borderPaint =
        Paint()
          ..color =
              selectedField == 0 ? Colors.white : Colors.white.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = selectedField == 0 ? 3 : 2;
    canvas.drawPath(northPath, borderPaint);

    // South plot
    final southColor =
        mapLayer == 0
            ? const Color(0xFF4CAF50)
            : mapLayer == 1
            ? const Color(0xFF8BC34A)
            : const Color(0xFF29B6F6);
    final southPaint =
        Paint()
          ..color = southColor.withOpacity(selectedField == 1 ? 0.95 : 0.7);
    final southPath =
        Path()
          ..moveTo(size.width * 0.35, size.height * 0.74)
          ..lineTo(size.width * 0.58, size.height * 0.54)
          ..lineTo(size.width * 0.60, size.height * 0.92)
          ..lineTo(size.width * 0.10, size.height * 0.92)
          ..close();
    canvas.drawPath(southPath, southPaint);

    if (selectedField == 1) {
      final glowPaint =
          Paint()
            ..color = Colors.white.withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8);
      canvas.drawPath(southPath, glowPaint);
    }

    final southBorder =
        Paint()
          ..color =
              selectedField == 1 ? Colors.white : Colors.white.withOpacity(0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = selectedField == 1 ? 3 : 2;
    canvas.drawPath(southPath, southBorder);

    // Water channel with glow
    final waterPaint =
        Paint()
          ..color = const Color(0xFF29B6F6).withOpacity(0.9)
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round;

    final waterGlow =
        Paint()
          ..color = const Color(0xFF29B6F6).withOpacity(0.3)
          ..strokeWidth = 16
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawLine(
      Offset(size.width * 0.62, 0),
      Offset(size.width * 0.65, size.height),
      waterGlow,
    );
    canvas.drawLine(
      Offset(size.width * 0.62, 0),
      Offset(size.width * 0.65, size.height),
      waterPaint,
    );

    // Buildings
    final buildPaint =
        Paint()..color = const Color(0xFFFFB74D).withOpacity(0.9);
    final buildShadow =
        Paint()
          ..color = Colors.black.withOpacity(0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.72,
          size.height * 0.32,
          size.width * 0.12,
          size.height * 0.18,
        ),
        const Radius.circular(4),
      ),
      buildShadow,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.70,
          size.height * 0.30,
          size.width * 0.12,
          size.height * 0.18,
        ),
        const Radius.circular(4),
      ),
      buildPaint,
    );

    // Labels
    _paintLabel(
      canvas,
      'North Plot',
      Offset(size.width * 0.28, size.height * 0.35),
    );
    _paintLabel(
      canvas,
      '1.8 ac',
      Offset(size.width * 0.28, size.height * 0.43),
      small: true,
    );
    _paintLabel(
      canvas,
      'South Plot',
      Offset(size.width * 0.32, size.height * 0.78),
    );
    _paintLabel(
      canvas,
      '1.4 ac',
      Offset(size.width * 0.32, size.height * 0.86),
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
          fontSize: small ? 10 : 13,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          shadows: const [
            Shadow(color: Colors.black54, blurRadius: 6),
            Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 2)),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, position - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _Enhanced3DMapPainter oldDelegate) =>
      selectedField != oldDelegate.selectedField ||
      mapLayer != oldDelegate.mapLayer;
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
          const SizedBox(height: 100),
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
          const SizedBox(height: 100),
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
          const SizedBox(height: 100),
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
                  const SizedBox(height: 100),
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
