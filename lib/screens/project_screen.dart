import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(
  const MaterialApp(home: ProjectScreen(), debugShowCheckedModeBanner: false),
);

// ─────────────────────────────────────────────
// MAIN APP SHELL
// ─────────────────────────────────────────────
class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});
  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _navAnim;
  late Animation<double> _navScale;

  final List<Widget> _screens = const [
    HomeScreen(),
    MyFieldsScreen(),
    FarmDiaryScreen(),
    MandiHelpScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _navAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _navScale = CurvedAnimation(parent: _navAnim, curve: Curves.easeOutBack);
    _navAnim.forward();
  }

  @override
  void dispose() {
    _navAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder:
                (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.02),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
            child: KeyedSubtree(
              key: ValueKey(_currentIndex),
              child: _screens[_currentIndex],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ScaleTransition(scale: _navScale, child: _buildNavDock()),
          ),
        ],
      ),
    );
  }

  Widget _buildNavDock() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.grass_rounded, 'label': 'My Fields'},
      {'icon': Icons.menu_book_rounded, 'label': 'Diary'},
      {'icon': Icons.store_rounded, 'label': 'Mandi'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withOpacity(0.18),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (i) {
          final isSelected = _currentIndex == i;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _currentIndex = i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                gradient:
                    isSelected
                        ? const LinearGradient(
                          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                        : null,
                borderRadius: BorderRadius.circular(22),
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
                  Icon(
                    items[i]['icon'] as IconData,
                    color: isSelected ? Colors.white : Colors.grey.shade400,
                    size: 22,
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: isSelected ? 14 : 0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isSelected ? 1.0 : 0.0,
                      child: Text(
                        items[i]['label'] as String,
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
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HOME SCREEN — Farmer's Daily Dashboard
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  int _selectedDay = 3;
  final today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F1),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildWeatherCard(),
                  _buildWeekStrip(),
                  _buildAlertBanner(),
                  _buildFarmStats(),
                  _buildTodaysTasks(),
                  _buildCropTimeline(),
                  _buildQuickAdvice(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: const Color(0xFF1B5E20),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Krishi Sakhi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Namaskaram, Ramesh! 🙏',
                style: TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF388E3C), Color(0xFF5A9E40)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'இன்றைய வானிலை',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Today\'s Weather',
                        style: TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text(
                            '32°C',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          SizedBox(width: 10),
                          Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Sunny ☀️',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Madurai, Tamil Nadu',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: const [
                      Icon(
                        Icons.wb_sunny_rounded,
                        color: Color(0xFFFFD54F),
                        size: 40,
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Good for\nFarming',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _weatherStat(
                  Icons.water_drop_rounded,
                  '68%',
                  'ஈரப்பதம்\nHumidity',
                ),
                _vDivider(),
                _weatherStat(Icons.air_rounded, '12 km/h', 'காற்று\nWind'),
                _vDivider(),
                _weatherStat(
                  Icons.umbrella_rounded,
                  '5%',
                  'மழை வாய்ப்பு\nRain Chance',
                ),
                _vDivider(),
                _weatherStat(Icons.thermostat_rounded, '22°C', 'இரவு\nNight'),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(0.2),
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
                const Expanded(
                  child: Text(
                    '✅ இன்று நீர் பாய்ச்சல் நல்ல நேரம் — Good day for irrigation!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _weatherStat(IconData icon, String val, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(height: 4),
        Text(
          val,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 8,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _vDivider() =>
      Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2));

  Widget _buildWeekStrip() {
    final dates = List.generate(
      7,
      (i) => DateTime(today.year, today.month, today.day + (i - 3)),
    );
    final dayNames = ['தி', 'செ', 'பு', 'வி', 'வெ', 'ச', 'ஞா'];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'இந்த வாரம் | This Week',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2E7D32),
              ),
            ),
          ),
          SizedBox(
            height: 72,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, i) {
                final date = dates[i];
                final isToday = i == 3;
                final isSelected = i == _selectedDay;
                final isFuture = i > 3;
                return GestureDetector(
                  onTap:
                      isFuture ? null : () => setState(() => _selectedDay = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 46,
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
                      opacity: isFuture ? 0.35 : 1.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dayNames[date.weekday - 1],
                            style: TextStyle(
                              fontSize: 10,
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
                              fontSize: 18,
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
                              margin: const EdgeInsets.only(top: 2),
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
        ],
      ),
    );
  }

  Widget _buildAlertBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEF9A9A), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFD32F2F).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.warning_rounded,
              color: Color(0xFFD32F2F),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚠️ பூச்சி அபாயம் | Pest Alert!',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: Color(0xFFD32F2F),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'North Plot-ல் Leaf Folder கண்டுபிடிக்கப்பட்டது.\nஉடனே மருந்து தெளிக்கவும்!',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFC62828),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFD32F2F)),
        ],
      ),
    );
  }

  Widget _buildFarmStats() {
    final stats = [
      {
        'label': 'மண் pH\nSoil pH',
        'value': '6.8',
        'icon': Icons.science_rounded,
        'color': const Color(0xFF1565C0),
        'bg': const Color(0xFFE3F2FD),
        'sub': 'Normal',
      },
      {
        'label': 'தண்ணீர்\nMoisture',
        'value': '72%',
        'icon': Icons.water_drop_rounded,
        'color': const Color(0xFF0097A7),
        'bg': const Color(0xFFE0F7FA),
        'sub': 'Good',
      },
      {
        'label': 'மகசூல்\nYield Est.',
        'value': '4.2T',
        'icon': Icons.agriculture_rounded,
        'color': const Color(0xFF2E7D32),
        'bg': const Color(0xFFE8F5E9),
        'sub': '+12%',
      },
      {
        'label': 'பூச்சி\nPest Risk',
        'value': 'High',
        'icon': Icons.pest_control_rounded,
        'color': const Color(0xFFC62828),
        'bg': const Color(0xFFFFEBEE),
        'sub': 'Act Now',
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children:
            stats
                .map(
                  (s) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
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
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: s['color'] as Color,
                            ),
                          ),
                          Text(
                            s['label'] as String,
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.grey.shade500,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s['sub'] as String,
                            style: TextStyle(
                              fontSize: 9,
                              color: s['color'] as Color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildTodaysTasks() {
    final tasks = [
      {
        'title': 'நீர் பாய்ச்சல் சரிபார்',
        'en': 'Irrigation Check',
        'time': 'காலை 6 மணி | 6:00 AM',
        'icon': Icons.water_drop_rounded,
        'done': false,
        'priority': 'High',
        'pColor': const Color(0xFFF57F17),
      },
      {
        'title': 'பூச்சி மருந்து தெளி',
        'en': 'Apply Pesticide',
        'time': 'காலை 8 மணி | 8:00 AM',
        'icon': Icons.pest_control_rounded,
        'done': false,
        'priority': 'Critical',
        'pColor': const Color(0xFFD32F2F),
      },
      {
        'title': 'உரம் இட்டாயிற்று',
        'en': 'Fertilizer Applied',
        'time': 'முடிந்தது | Done',
        'icon': Icons.grass_rounded,
        'done': true,
        'priority': 'Done',
        'pColor': const Color(0xFF2E7D32),
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'இன்றைய வேலைகள்',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A2E1A),
                    ),
                  ),
                  Text(
                    "Today's Tasks",
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${tasks.where((t) => !(t['done'] as bool)).length} remaining',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...tasks.map((task) {
            final done = task['done'] as bool;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: done ? Colors.grey.shade50 : const Color(0xFFFAFCFA),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: done ? Colors.grey.shade200 : const Color(0xFFDCEEDC),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
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
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            decoration:
                                done ? TextDecoration.lineThrough : null,
                            color:
                                done
                                    ? Colors.grey.shade400
                                    : const Color(0xFF1A2E1A),
                          ),
                        ),
                        Text(
                          '${task['en']} • ${task['time']}',
                          style: TextStyle(
                            fontSize: 10,
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
                      color: (task['pColor'] as Color).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      task['priority'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: task['pColor'] as Color,
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

  Widget _buildCropTimeline() {
    final phases = [
      {
        'week': 'W1-2',
        'title': 'நடவு தயாரிப்பு\nNursery',
        'done': true,
        'current': false,
      },
      {
        'week': 'W3',
        'title': 'நடவு\nTransplant',
        'done': false,
        'current': true,
      },
      {
        'week': 'W6',
        'title': 'உரம்\nFertilizer',
        'done': false,
        'current': false,
      },
      {
        'week': 'W10',
        'title': 'பூச்சி\nPest Ctrl',
        'done': false,
        'current': false,
      },
      {
        'week': 'W14',
        'title': 'அறுவடை\nHarvest',
        'done': false,
        'current': false,
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
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
                size: 20,
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'பயிர் வழிகாட்டி | Crop Roadmap',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A2E1A),
                    ),
                  ),
                  Text(
                    'Samba Rice • Week 3 of 14',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'W3/14',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children:
                phases.asMap().entries.map((e) {
                  final p = e.value;
                  final done = p['done'] as bool;
                  final current = p['current'] as bool;
                  return Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 4,
                          color:
                              (done || current)
                                  ? const Color(0xFF2E7D32)
                                  : Colors.grey.shade200,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color:
                                done
                                    ? const Color(0xFF2E7D32)
                                    : current
                                    ? Colors.white
                                    : Colors.grey.shade100,
                            shape: BoxShape.circle,
                            border:
                                current
                                    ? Border.all(
                                      color: const Color(0xFF2E7D32),
                                      width: 2.5,
                                    )
                                    : null,
                            boxShadow:
                                current
                                    ? [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF2E7D32,
                                        ).withOpacity(0.3),
                                        blurRadius: 8,
                                      ),
                                    ]
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
                                done
                                    ? Colors.white
                                    : current
                                    ? const Color(0xFF2E7D32)
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
                                    : Colors.grey.shade400,
                          ),
                        ),
                        Text(
                          p['title'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 7,
                            color:
                                current
                                    ? const Color(0xFF1A2E1A)
                                    : Colors.grey.shade400,
                            fontWeight:
                                current ? FontWeight.w700 : FontWeight.normal,
                            height: 1.4,
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

  Widget _buildQuickAdvice() {
    final advisories = [
      {
        'icon': Icons.pest_control_rounded,
        'title': 'Leaf Folder அபாயம்',
        'body': 'Chlorpyrifos 2.5ml/L — இப்போதே தெளிக்கவும்!',
        'color': const Color(0xFFD32F2F),
        'bg': const Color(0xFFFFEBEE),
      },
      {
        'icon': Icons.water_drop_rounded,
        'title': 'நீர் பாய்ச்சல்',
        'body': 'மண் ஈரப்பதம் 72%. காலை 6-8 நல்ல நேரம்.',
        'color': const Color(0xFF1565C0),
        'bg': const Color(0xFFE3F2FD),
      },
      {
        'icon': Icons.grass_rounded,
        'title': 'உரம் இடுங்கள்',
        'body': 'Week 6 — 45kg Urea/acre தூவுங்கள்.',
        'color': const Color(0xFF2E7D32),
        'bg': const Color(0xFFE8F5E9),
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI ஆலோசனை | AI Advice',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A2E1A),
                    ),
                  ),
                  Text(
                    'Powered by Krishi AI',
                    style: TextStyle(fontSize: 9, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...advisories.map(
            (a) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: a['bg'] as Color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    a['icon'] as IconData,
                    color: a['color'] as Color,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a['title'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: a['color'] as Color,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          a['body'] as String,
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
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MY FIELDS SCREEN
// ─────────────────────────────────────────────
class MyFieldsScreen extends StatefulWidget {
  const MyFieldsScreen({super.key});
  @override
  State<MyFieldsScreen> createState() => _MyFieldsScreenState();
}

class _MyFieldsScreenState extends State<MyFieldsScreen>
    with TickerProviderStateMixin {
  int _selected = 0;
  int _mapLayer = 0;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  final fields = [
    {
      'name': 'வடக்கு வயல்\nNorth Plot',
      'shortName': 'North Plot',
      'crop': 'சம்பா நெல் | Samba Rice',
      'area': '1.8 ஏக்கர்',
      'health': 0.78,
      'status': 'Normal',
      'stage': 'Tillering',
      'moisture': '72%',
      'ndvi': '0.68',
      'pest': 'High Risk',
      'harvest': 'Dec 15',
      'color': const Color(0xFF8BC34A),
      'nextTask': 'பூச்சி மருந்து தெளி',
    },
    {
      'name': 'தெற்கு வயல்\nSouth Plot',
      'shortName': 'South Plot',
      'crop': 'பொன்னி நெல் | Ponni Rice',
      'area': '1.4 ஏக்கர்',
      'health': 0.91,
      'status': 'Excellent',
      'stage': 'Panicle Init.',
      'moisture': '65%',
      'ndvi': '0.82',
      'pest': 'Low Risk',
      'harvest': 'Nov 28',
      'color': const Color(0xFF4CAF50),
      'nextTask': 'நீர் பாய்ச்சல் சரிபார்',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 0.8,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F1),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: const Color(0xFF1B5E20),
            systemOverlayStyle: SystemUiOverlayStyle.light,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.grass_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'என் வயல்கள் | My Fields',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '3.2 ஏக்கர் மொத்தம் • 3.2 acres total',
                      style: TextStyle(color: Colors.white60, fontSize: 9),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildMap(),
                _buildLayerToggle(),
                _buildFieldCards(),
                _buildSelectedFieldDetail(),
                _buildHealthChecklist(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withOpacity(0.25),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            _FarmMapCanvas(selectedField: _selected, mapLayer: _mapLayer),
            if (_selected == 0)
              Positioned(
                top: 75,
                left: 95,
                child: AnimatedBuilder(
                  animation: _pulse,
                  builder:
                      (_, __) => Transform.scale(
                        scale: _pulse.value,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFD32F2F).withOpacity(0.25),
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
                                size: 11,
                              ),
                            ),
                          ),
                        ),
                      ),
                ),
              ),
            Positioned(
              top: 10,
              right: 10,
              child: Column(
                children: [
                  _glassBtn(Icons.add_rounded),
                  const SizedBox(height: 6),
                  _glassBtn(Icons.remove_rounded),
                  const SizedBox(height: 6),
                  _glassBtn(Icons.my_location_rounded),
                ],
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'N',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _legendItem(const Color(0xFF8BC34A), 'North Plot'),
                    const SizedBox(height: 3),
                    _legendItem(const Color(0xFF4CAF50), 'South Plot'),
                    const SizedBox(height: 3),
                    _legendItem(const Color(0xFF29B6F6), 'Water'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassBtn(IconData icon) => Container(
    width: 38,
    height: 38,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.88),
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
      ],
    ),
    child: Icon(icon, size: 18, color: const Color(0xFF1B5E20)),
  );

  Widget _legendItem(Color color, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 5),
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

  Widget _buildLayerToggle() {
    final layers = [
      {'label': 'Satellite', 'icon': Icons.satellite_alt_rounded},
      {'label': 'NDVI', 'icon': Icons.grass_rounded},
      {'label': 'தண்ணீர்\nMoisture', 'icon': Icons.water_drop_rounded},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Row(
        children:
            layers.asMap().entries.map((e) {
              final sel = e.key == _mapLayer;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _mapLayer = e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient:
                          sel
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
                          e.value['icon'] as IconData,
                          size: 14,
                          color: sel ? Colors.white : Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          e.value['label'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: sel ? Colors.white : Colors.grey.shade600,
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
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 0),
        itemCount: fields.length,
        itemBuilder: (_, i) {
          final f = fields[i];
          final sel = i == _selected;
          return GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 170,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient:
                    sel
                        ? const LinearGradient(
                          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                        : const LinearGradient(
                          colors: [Colors.white, Color(0xFFF8FBF8)],
                        ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color:
                        sel
                            ? const Color(0xFF2E7D32).withOpacity(0.35)
                            : Colors.black.withOpacity(0.06),
                    blurRadius: sel ? 16 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          f['shortName'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: sel ? Colors.white : const Color(0xFF1A2E1A),
                          ),
                        ),
                      ),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: f['color'] as Color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (f['color'] as Color).withOpacity(0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    f['crop'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: sel ? Colors.white70 : Colors.grey.shade500,
                    ),
                  ),
                  Row(
                    children: [
                      _miniTag(
                        '${((f['health'] as double) * 100).toInt()}%',
                        sel,
                      ),
                      const SizedBox(width: 6),
                      _miniTag(f['area'] as String, sel),
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

  Widget _miniTag(String val, bool sel) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: sel ? Colors.white.withOpacity(0.2) : const Color(0xFFE8F5E9),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      val,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: sel ? Colors.white : const Color(0xFF2E7D32),
      ),
    ),
  );

  Widget _buildSelectedFieldDetail() {
    final f = fields[_selected];
    final health = f['health'] as double;
    final isHighRisk = (f['pest'] as String).contains('High');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
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
                  color: (f['color'] as Color).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.landscape_rounded,
                  color: f['color'] as Color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f['shortName'] as String,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A2E1A),
                      ),
                    ),
                    Text(
                      '${f['crop']} • ${f['stage']} stage',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  f['status'] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'பயிர் ஆரோக்கியம் | Crop Health',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A2E1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${(health * 100).toInt()}% Healthy',
                    style: TextStyle(
                      fontSize: 11,
                      color: f['color'] as Color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '${(health * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: f['color'] as Color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: health,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          (f['color'] as Color).withOpacity(0.6),
                          f['color'] as Color,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: (f['color'] as Color).withOpacity(0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _fieldStat(
                'தண்ணீர்\nMoisture',
                f['moisture'] as String,
                Icons.water_drop_rounded,
                const Color(0xFF0097A7),
              ),
              _fieldStat(
                'NDVI\nValue',
                f['ndvi'] as String,
                Icons.satellite_alt_rounded,
                const Color(0xFF2E7D32),
              ),
              _fieldStat(
                'பூச்சி\nPest Risk',
                f['pest'] as String,
                Icons.pest_control_rounded,
                isHighRisk ? const Color(0xFFD32F2F) : const Color(0xFF388E3C),
              ),
              _fieldStat(
                'அறுவடை\nHarvest',
                f['harvest'] as String,
                Icons.event_rounded,
                const Color(0xFFF57F17),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFF2E7D32),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'அடுத்த வேலை | Next Task',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      Text(
                        f['nextTask'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey.shade800,
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

  Widget _fieldStat(String label, String val, IconData icon, Color color) {
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
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 5),
            Text(
              val,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 8,
                color: Colors.grey.shade500,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthChecklist() {
    final checks = [
      {
        'icon': Icons.water_drop_rounded,
        'title': 'நீர் நிலை சரியாக உள்ளது',
        'en': 'Water level is adequate',
        'ok': true,
      },
      {
        'icon': Icons.wb_sunny_rounded,
        'title': 'வெயில் சரியாக கிடைக்கிறது',
        'en': 'Sunlight exposure is good',
        'ok': true,
      },
      {
        'icon': Icons.pest_control_rounded,
        'title': 'பூச்சி தொல்லை அதிகமாக உள்ளது',
        'en': 'Pest infestation is high — act now!',
        'ok': false,
      },
      {
        'icon': Icons.science_rounded,
        'title': 'மண் pH சாதகமாக உள்ளது',
        'en': 'Soil pH is normal',
        'ok': true,
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'வயல் ஆரோக்கிய சரிபார்ப்பு | Field Health Checklist',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A2E1A),
            ),
          ),
          const SizedBox(height: 12),
          ...checks.map(
            (c) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    (c['ok'] as bool)
                        ? const Color(0xFFF1FBF1)
                        : const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    c['icon'] as IconData,
                    color:
                        (c['ok'] as bool)
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFD32F2F),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c['title'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color:
                                (c['ok'] as bool)
                                    ? const Color(0xFF1A2E1A)
                                    : const Color(0xFFD32F2F),
                          ),
                        ),
                        Text(
                          c['en'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    (c['ok'] as bool)
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color:
                        (c['ok'] as bool)
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFD32F2F),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Farm Map Canvas
class _FarmMapCanvas extends StatelessWidget {
  final int selectedField;
  final int mapLayer;
  const _FarmMapCanvas({required this.selectedField, required this.mapLayer});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FarmMapPainter(
        selectedField: selectedField,
        mapLayer: mapLayer,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _FarmMapPainter extends CustomPainter {
  final int selectedField;
  final int mapLayer;
  _FarmMapPainter({required this.selectedField, required this.mapLayer});

  @override
  void paint(Canvas canvas, Size size) {
    final bgColors =
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

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          colors: bgColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Offset.zero & size),
    );

    final patternPaint = Paint()..color = Colors.white.withOpacity(0.015);
    for (int i = 0; i < 30; i++) {
      for (int j = 0; j < 20; j++) {
        if ((i + j) % 3 == 0)
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

    final northColor =
        mapLayer == 0
            ? const Color(0xFF8BC34A)
            : mapLayer == 1
            ? const Color(0xFFFFEB3B)
            : const Color(0xFF4FC3F7);
    final northPath =
        Path()
          ..moveTo(size.width * 0.05, size.height * 0.08)
          ..lineTo(size.width * 0.55, size.height * 0.06)
          ..lineTo(size.width * 0.58, size.height * 0.52)
          ..lineTo(size.width * 0.35, size.height * 0.72)
          ..lineTo(size.width * 0.05, size.height * 0.68)
          ..close();

    canvas.drawPath(
      northPath,
      Paint()..color = northColor.withOpacity(selectedField == 0 ? 0.92 : 0.65),
    );
    if (selectedField == 0)
      canvas.drawPath(
        northPath,
        Paint()
          ..color = Colors.white.withOpacity(0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8),
      );
    canvas.drawPath(
      northPath,
      Paint()
        ..color =
            (selectedField == 0 ? Colors.white : Colors.white.withOpacity(0.4))
        ..style = PaintingStyle.stroke
        ..strokeWidth = selectedField == 0 ? 3 : 1.5,
    );

    final southColor =
        mapLayer == 0
            ? const Color(0xFF4CAF50)
            : mapLayer == 1
            ? const Color(0xFF8BC34A)
            : const Color(0xFF29B6F6);
    final southPath =
        Path()
          ..moveTo(size.width * 0.35, size.height * 0.74)
          ..lineTo(size.width * 0.58, size.height * 0.54)
          ..lineTo(size.width * 0.60, size.height * 0.92)
          ..lineTo(size.width * 0.10, size.height * 0.92)
          ..close();

    canvas.drawPath(
      southPath,
      Paint()..color = southColor.withOpacity(selectedField == 1 ? 0.92 : 0.65),
    );
    if (selectedField == 1)
      canvas.drawPath(
        southPath,
        Paint()
          ..color = Colors.white.withOpacity(0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8),
      );
    canvas.drawPath(
      southPath,
      Paint()
        ..color =
            (selectedField == 1 ? Colors.white : Colors.white.withOpacity(0.4))
        ..style = PaintingStyle.stroke
        ..strokeWidth = selectedField == 1 ? 3 : 1.5,
    );

    canvas.drawLine(
      Offset(size.width * 0.62, 0),
      Offset(size.width * 0.65, size.height),
      Paint()
        ..color = const Color(0xFF29B6F6).withOpacity(0.25)
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawLine(
      Offset(size.width * 0.62, 0),
      Offset(size.width * 0.65, size.height),
      Paint()
        ..color = const Color(0xFF29B6F6).withOpacity(0.85)
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );

    final bldg = Paint()..color = const Color(0xFFFFB74D).withOpacity(0.9);
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
      bldg,
    );

    _label(canvas, 'North Plot', Offset(size.width * 0.28, size.height * 0.35));
    _label(
      canvas,
      '1.8 acres',
      Offset(size.width * 0.28, size.height * 0.44),
      small: true,
    );
    _label(canvas, 'South Plot', Offset(size.width * 0.32, size.height * 0.78));
    _label(
      canvas,
      '1.4 acres',
      Offset(size.width * 0.32, size.height * 0.87),
      small: true,
    );
  }

  void _label(Canvas canvas, String text, Offset pos, {bool small = false}) {
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
    )..layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _FarmMapPainter old) =>
      selectedField != old.selectedField || mapLayer != old.mapLayer;
}

// ─────────────────────────────────────────────
// FARM DIARY SCREEN
// ─────────────────────────────────────────────
class FarmDiaryScreen extends StatefulWidget {
  const FarmDiaryScreen({super.key});
  @override
  State<FarmDiaryScreen> createState() => _FarmDiaryScreenState();
}

class _FarmDiaryScreenState extends State<FarmDiaryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  int _activeEntry = -1;

  final List<Map<String, dynamic>> _entries = [
    {
      'date': 'Nov 28',
      'day': 'Thursday',
      'title': 'பூச்சி மருந்து தெளித்தேன்',
      'en': 'Applied pesticide on North Plot',
      'field': 'North Plot',
      'type': 'Pest Control',
      'icon': Icons.pest_control_rounded,
      'color': const Color(0xFFD32F2F),
      'amount': '',
      'note': 'Chlorpyrifos 2.5ml/L — 20 liters used',
    },
    {
      'date': 'Nov 27',
      'day': 'Wednesday',
      'title': 'யூரியா உரம் இட்டேன்',
      'en': 'Applied Urea fertilizer',
      'field': 'South Plot',
      'type': 'Fertilizer',
      'icon': Icons.grass_rounded,
      'color': const Color(0xFF2E7D32),
      'amount': '₹1,200',
      'note': '45 kg Urea used',
    },
    {
      'date': 'Nov 26',
      'day': 'Tuesday',
      'title': 'நீர் மோட்டார் சரிசெய்தேன்',
      'en': 'Repaired water pump motor',
      'field': 'Both Fields',
      'type': 'Maintenance',
      'icon': Icons.build_rounded,
      'color': const Color(0xFFF57F17),
      'amount': '₹850',
      'note': 'Mechanic came and fixed the pump',
    },
    {
      'date': 'Nov 25',
      'day': 'Monday',
      'title': 'கூலி வேலையாட்கள்',
      'en': 'Hired daily labour workers',
      'field': 'North Plot',
      'type': 'Labour',
      'icon': Icons.people_rounded,
      'color': const Color(0xFF7B1FA2),
      'amount': '₹2,400',
      'note': '4 workers × ₹600 each',
    },
  ];

  final _expenseData = [
    {
      'label': 'விதை | Seeds',
      'amount': 4200,
      'icon': Icons.grass_rounded,
      'color': const Color(0xFF2E7D32),
    },
    {
      'label': 'உரம் | Fertilizer',
      'amount': 8500,
      'icon': Icons.science_rounded,
      'color': const Color(0xFF1565C0),
    },
    {
      'label': 'பூச்சி | Pesticide',
      'amount': 3200,
      'icon': Icons.pest_control_rounded,
      'color': const Color(0xFFD32F2F),
    },
    {
      'label': 'கூலி | Labour',
      'amount': 12000,
      'icon': Icons.people_rounded,
      'color': const Color(0xFFF57F17),
    },
    {
      'label': 'நீர் | Irrigation',
      'amount': 5600,
      'icon': Icons.water_drop_rounded,
      'color': const Color(0xFF0097A7),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'வயல் நாட்குறிப்பு | Farm Diary',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Record daily activities & expenses',
              style: TextStyle(color: Colors.white60, fontSize: 10),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_circle_rounded,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () => _showAddEntrySheet(),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: '📝 நாட்குறிப்பு | Log'),
            Tab(text: '💰 செலவு | Expenses'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [_buildLogTab(), _buildExpensesTab()],
      ),
    );
  }

  Widget _buildLogTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // Summary bar
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _diarySummary(
                '${_entries.length}',
                'மொத்த பதிவுகள்\nTotal Entries',
              ),
              _vWhite(),
              _diarySummary('4', 'இந்த வாரம்\nThis Week'),
              _vWhite(),
              _diarySummary('2', 'நிலுவை வேலைகள்\nPending Tasks'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'சமீபத்திய பதிவுகள் | Recent Entries',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A2E1A),
          ),
        ),
        const SizedBox(height: 10),
        ..._entries.asMap().entries.map((e) {
          final i = e.key;
          final entry = e.value;
          final isOpen = _activeEntry == i;
          return GestureDetector(
            onTap: () => setState(() => _activeEntry = isOpen ? -1 : i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color:
                      isOpen
                          ? (entry['color'] as Color).withOpacity(0.4)
                          : Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isOpen ? 0.08 : 0.04),
                    blurRadius: isOpen ? 14 : 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (entry['color'] as Color).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            entry['icon'] as IconData,
                            color: entry['color'] as Color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry['title'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: Color(0xFF1A2E1A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                entry['en'] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (entry['color'] as Color)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      entry['type'] as String,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: entry['color'] as Color,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${entry['date']} • ${entry['field']}',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if ((entry['amount'] as String).isNotEmpty)
                              Text(
                                entry['amount'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                            const SizedBox(height: 4),
                            Icon(
                              isOpen
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: Colors.grey.shade400,
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isOpen)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (entry['color'] as Color).withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.notes_rounded,
                              color: entry['color'] as Color,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                entry['note'] as String,
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
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _diarySummary(String val, String label) {
    return Column(
      children: [
        Text(
          val,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 9,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _vWhite() =>
      Container(width: 1, height: 36, color: Colors.white.withOpacity(0.3));

  Widget _buildExpensesTab() {
    final total = _expenseData.fold(0, (sum, e) => sum + (e['amount'] as int));
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'மொத்த செலவு | Total Expenses',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '₹33,500',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '2024 பருவம் | Season',
                        style: TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'வருமானம் | Revenue',
                      style: TextStyle(color: Colors.white70, fontSize: 10),
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
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'லாபம் | Profit',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                            ),
                          ),
                          Text(
                            '₹51,500',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
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
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'செலவு விவரம் | Expense Breakdown',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A2E1A),
                  ),
                ),
                const SizedBox(height: 16),
                ..._expenseData.map((e) {
                  final pct = (e['amount'] as int) / total;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
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
                                    e['label'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    '₹${e['amount']}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      color: e['color'] as Color,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  backgroundColor: Colors.grey.shade100,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    e['color'] as Color,
                                  ),
                                  minHeight: 8,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${(pct * 100).toStringAsFixed(0)}% of total',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey.shade400,
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
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2E7D32), width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.download_rounded,
                    color: Color(0xFF2E7D32),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Excel ஆக பதிவிறக்கம் | Download as Excel',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEntrySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'புதிய பதிவு | Add Entry',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A2E1A),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'என்ன வேலை செய்தீர்கள்? | What did you do today?',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF1A2E1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'உதாரணம்: பூச்சி மருந்து தெளித்தேன்...',
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'செலவு ஆனதா? | Any expense?',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF1A2E1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '₹ தொகை உள்ளிடவும் | Enter amount',
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                        prefixText: '₹ ',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF43A047), Color(0xFF1B5E20)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'சேமி | Save Entry',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
    );
  }
}

// ─────────────────────────────────────────────
// MANDI & HELP SCREEN
// ─────────────────────────────────────────────
class MandiHelpScreen extends StatefulWidget {
  const MandiHelpScreen({super.key});
  @override
  State<MandiHelpScreen> createState() => _MandiHelpScreenState();
}

class _MandiHelpScreenState extends State<MandiHelpScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  final mandiPrices = [
    {
      'crop': 'சம்பா நெல் | Samba Rice',
      'price': '₹2,180',
      'unit': '/quintal',
      'change': '+₹40',
      'up': true,
      'icon': '🌾',
      'mandi': 'Madurai APMC',
    },
    {
      'crop': 'பொன்னி நெல் | Ponni Rice',
      'price': '₹2,050',
      'unit': '/quintal',
      'change': '-₹20',
      'up': false,
      'icon': '🌾',
      'mandi': 'Dindigul APMC',
    },
    {
      'crop': 'தக்காளி | Tomato',
      'price': '₹1,200',
      'unit': '/quintal',
      'change': '+₹150',
      'up': true,
      'icon': '🍅',
      'mandi': 'Coimbatore',
    },
    {
      'crop': 'வெங்காயம் | Onion',
      'price': '₹950',
      'unit': '/quintal',
      'change': '-₹30',
      'up': false,
      'icon': '🧅',
      'mandi': 'Salem',
    },
    {
      'crop': 'மிளகாய் | Chilli',
      'price': '₹8,500',
      'unit': '/quintal',
      'change': '+₹300',
      'up': true,
      'icon': '🌶️',
      'mandi': 'Guntur',
    },
    {
      'crop': 'கோதுமை | Wheat',
      'price': '₹2,275',
      'unit': '/quintal',
      'change': '0',
      'up': true,
      'icon': '🌾',
      'mandi': 'MSP Rate',
    },
  ];

  final schemes = [
    {
      'title': 'PM-KISAN',
      'desc': 'ஆண்டுக்கு ₹6,000 நேரடி உதவி\n₹6,000/year direct support',
      'icon': Icons.account_balance_rounded,
      'color': const Color(0xFF1565C0),
      'status': 'Active',
    },
    {
      'title': 'Crop Insurance\nPMFBY',
      'desc': 'பயிர் காப்பீடு — பருவத்திற்கு ₹800\nCrop insurance scheme',
      'icon': Icons.shield_rounded,
      'color': const Color(0xFF2E7D32),
      'status': 'Apply Now',
    },
    {
      'title': 'Soil Health Card',
      'desc': 'இலவச மண் பரிசோதனை\nFree soil testing',
      'icon': Icons.science_rounded,
      'color': const Color(0xFF6A1B9A),
      'status': 'Free',
    },
    {
      'title': 'KCC - Kisan Credit',
      'desc': 'குறைந்த வட்டியில் கடன்\nLow interest farm loan',
      'icon': Icons.credit_card_rounded,
      'color': const Color(0xFFF57F17),
      'status': 'Apply',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'மண்டி & உதவி | Mandi & Help',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Prices • Schemes • Helplines',
              style: TextStyle(color: Colors.white60, fontSize: 10),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          tabs: const [
            Tab(text: '📈 விலை\nPrices'),
            Tab(text: '🏛️ திட்டங்கள்\nSchemes'),
            Tab(text: '📞 உதவி\nHelp'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [_buildPricesTab(), _buildSchemesTab(), _buildHelpTab()],
      ),
    );
  }

  Widget _buildPricesTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF81C784)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.update_rounded,
                  color: Color(0xFF2E7D32),
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Text(
                  'இன்று புதுப்பிக்கப்பட்டது | Updated Today',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const Spacer(),
                Text(
                  'Mar 04, 2026',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'இன்றைய மண்டி விலை | Today\'s Mandi Prices',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A2E1A),
            ),
          ),
          const SizedBox(height: 10),
          ...mandiPrices.map(
            (m) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        m['icon'] as String,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m['crop'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Color(0xFF1A2E1A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          m['mandi'] as String,
                          style: TextStyle(
                            fontSize: 10,
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
                        m['price'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1A2E1A),
                        ),
                      ),
                      Text(
                        m['unit'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (m['up'] as bool)
                                  ? const Color(0xFFE8F5E9)
                                  : const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              (m['up'] as bool)
                                  ? Icons.trending_up_rounded
                                  : Icons.trending_down_rounded,
                              size: 12,
                              color:
                                  (m['up'] as bool)
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFFD32F2F),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              m['change'] as String,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color:
                                    (m['up'] as bool)
                                        ? const Color(0xFF2E7D32)
                                        : const Color(0xFFD32F2F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFCC02)),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'விலை உச்சம் | Best Selling Window',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'அடுத்த 2 வாரத்தில் சம்பா விலை உயரும் என்று எதிர்பார்க்கப்படுகிறது.\nSamba price expected to rise in next 2 weeks.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF795548),
                          height: 1.4,
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

  Widget _buildSchemesTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'உங்களுக்கு கிடைக்கும் அரசு திட்டங்கள்',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Government schemes you can apply for',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        '4',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Schemes',
                        style: TextStyle(color: Colors.white70, fontSize: 9),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...schemes.map(
            (s) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (s['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      s['icon'] as IconData,
                      color: s['color'] as Color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s['title'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: Color(0xFF1A2E1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s['desc'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  (s['color'] as Color).withOpacity(0.8),
                                  s['color'] as Color,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              s['status'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpTab() {
    final helplines = [
      {
        'name': 'KVK Helpline',
        'ta': 'விவசாய அறிவியல் மையம்',
        'number': '1800-180-1551',
        'icon': Icons.agriculture_rounded,
        'color': const Color(0xFF2E7D32),
        'time': '9 AM – 5 PM',
      },
      {
        'name': 'Kisan Call Centre',
        'ta': 'கிசான் அழைப்பு மையம்',
        'number': '1800-180-1551',
        'icon': Icons.support_agent_rounded,
        'color': const Color(0xFF1565C0),
        'time': '6 AM – 10 PM',
      },
      {
        'name': 'PM-KISAN Helpline',
        'ta': 'PM கிசான் உதவி',
        'number': '155261',
        'icon': Icons.account_balance_rounded,
        'color': const Color(0xFF6A1B9A),
        'time': '9 AM – 6 PM',
      },
      {
        'name': 'Crop Insurance',
        'ta': 'பயிர் காப்பீடு',
        'number': '14447',
        'icon': Icons.shield_rounded,
        'color': const Color(0xFFD32F2F),
        'time': '10 AM – 5 PM',
      },
      {
        'name': 'Weather Alert',
        'ta': 'வானிலை அறிவிப்பு',
        'number': '1800-180-1717',
        'icon': Icons.wb_cloudy_rounded,
        'color': const Color(0xFFF57F17),
        'time': '24 Hours',
      },
    ];

    final faqs = [
      {
        'q': 'எப்போது நீர் பாய்ச்சலாம்?\nWhen should I irrigate?',
        'a':
            'காலை 6-8 மணி அல்லது மாலை 5-7 மணி சிறந்தது. Morning 6-8 AM or evening 5-7 PM is best to reduce evaporation.',
      },
      {
        'q':
            'பூச்சி மருந்து எவ்வளவு தெளிக்கணும்?\nHow much pesticide to spray?',
        'a':
            'ஒரு ஏக்கருக்கு 200 லிட்டர் தண்ணீரில் கலந்து தெளிக்கவும். Use 200 litres of water per acre for even coverage.',
      },
      {
        'q': 'மண் பரிசோதனை எங்கு செய்வது?\nWhere to do soil testing?',
        'a':
            'அருகில் உள்ள KVK அல்லது வேளாண் அலுவலகத்திற்கு செல்லவும். Visit your nearest KVK or Agriculture office.',
      },
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'உதவி எண்கள் | Helplines',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A2E1A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'இலவசமாக அழைக்கலாம் | All calls are FREE (Toll-Free)',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          ...helplines.map(
            (h) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (h['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      h['icon'] as IconData,
                      color: h['color'] as Color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          h['name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: Color(0xFF1A2E1A),
                          ),
                        ),
                        Text(
                          h['ta'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '⏰ ${h['time']}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            (h['color'] as Color).withOpacity(0.8),
                            h['color'] as Color,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.call_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            h['number'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
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
          const Text(
            'அடிக்கடி கேட்கப்படும் கேள்விகள் | FAQs',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A2E1A),
            ),
          ),
          const SizedBox(height: 10),
          ...faqs.map((f) => _FAQCard(q: f['q']!, a: f['a']!)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'AI-உடன் பேசுங்கள்',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Chat with Krishi AI',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'எந்த கேள்வியும் கேளுங்கள்!\nAsk any farming question!',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    const Text('🤖', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Chat',
                        style: TextStyle(
                          color: Color(0xFF1B5E20),
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FAQCard extends StatefulWidget {
  final String q;
  final String a;
  const _FAQCard({required this.q, required this.a});

  @override
  State<_FAQCard> createState() => _FAQCardState();
}

class _FAQCardState extends State<_FAQCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _open = !_open),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                _open
                    ? const Color(0xFF2E7D32).withOpacity(0.4)
                    : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('❓', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.q,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Color(0xFF1A2E1A),
                      height: 1.4,
                    ),
                  ),
                ),
                Icon(
                  _open
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
            if (_open) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.a,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
