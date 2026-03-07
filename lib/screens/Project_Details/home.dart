import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:krishi_sakhi/models/farm_project.dart';

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
                child: const Row(
                  children: [
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
                                child: const Row(
                                  children: [
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
