import 'package:flutter/material.dart';
import 'package:krishi_sakhi/components/drawer.dart';
import 'package:krishi_sakhi/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _toggleDrawer() {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeDrawer();
    } else {
      _scaffoldKey.currentState?.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom AppBar in body
            SliverToBoxAdapter(child: _buildCustomAppBar(context)),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildDailyTipCard(context),
                    const SizedBox(height: 20),
                    _buildWeatherSection(context),
                    const SizedBox(height: 20),
                    _buildSectionHeader(context, 'Latest News', 'See All'),
                    const SizedBox(height: 12),
                    _buildAnnouncementSection(context),
                    const SizedBox(height: 20),
                    _buildSectionHeader(context, 'My Projects', ''),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Project List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildProjectCard(context, index),
                  childCount: 3,
                ),
              ),
            ),

            // Add bottom spacing
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D32), Color(0xFF388E3C), Color(0xFF43A047)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x29000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            splashRadius: 24,
            onPressed: _toggleDrawer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.appTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            splashRadius: 24,
            tooltip: 'Settings',
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildDailyTipCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFF1F8E9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: const Color(0xFF4CAF50).withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.lightbulb,
                    color: Color(0xFF2E7D32),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '5-Minute Daily Tip',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Monsoon Season Alert',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Prepare your fields for heavy rainfall. Ensure proper drainage channels are clear and ready for the upcoming monsoon rains.',
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_circle_outline, size: 18),
                  label: const Text('Play Audio'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2E7D32),
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thrissur',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Scattered Showers',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Text(
                '28°C',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                5,
                (index) => Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      Text(
                        ['Now', '3PM', '4PM', '5PM', '6PM'][index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Icon(
                        [
                          Icons.wb_cloudy,
                          Icons.grain,
                          Icons.grain,
                          Icons.wb_cloudy,
                          Icons.nights_stay,
                        ][index],
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ['28°', '27°', '26°', '25°', '25°'][index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            action,
            style: const TextStyle(
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectCard(BuildContext context, int index) {
    final crops = ['Rice', 'Vegetables', 'Coconut'];
    final dates = ['Started: May 15', 'Started: Jun 02', 'Started: Apr 10'];
    final progress = [0.7, 0.35, 0.9];
    final bgColors = [
      const Color(0xFFE8F5E9),
      const Color(0xFFF1F8E9),
      const Color(0xFFDCEDC8),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: bgColors[index],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF4CAF50).withOpacity(0.3),
                    ),
                  ),
                  child: const Icon(Icons.grass, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${crops[index]} Field',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dates[index],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
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
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    index == 1 ? 'Needs Attention' : 'On Track',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Progress',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF666666),
                            ),
                          ),
                          Text(
                            '${(progress[index] * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress[index],
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            index == 1
                                ? Colors.orange
                                : const Color(0xFF4CAF50),
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.water_drop_outlined,
                      color: Color(0xFF2E7D32),
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      index == 1 ? 'Irrigation needed' : 'Watered today',
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            index == 1
                                ? Colors.orange.shade800
                                : const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Details'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2E7D32),
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementSection(BuildContext context) {
    // Sample announcement data with more entries
    final announcements = [
      {
        'title': 'Rice MSP increased to ₹2,183/quintal',
        'type': 'market',
        'subtitle': 'Effective from October 1st',
      },
      {
        'title': 'PM Kisan: 15th installment dates announced',
        'type': 'scheme',
        'subtitle': 'Apply before September 25',
      },
      {
        'title': 'Coconut prices reach ₹40 per piece',
        'type': 'market',
        'subtitle': 'Local mandi rates updated',
      },
      {
        'title': 'Subsidies for micro-irrigation systems',
        'type': 'scheme',
        'subtitle': 'Up to 55% subsidy available',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
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
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                splashColor: (isMarket
                        ? const Color(0xFF388E3C)
                        : const Color(0xFF3949AB))
                    .withOpacity(0.1),
                highlightColor: (isMarket
                        ? const Color(0xFF388E3C)
                        : const Color(0xFF3949AB))
                    .withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Type icon
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
                                .withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          isMarket ? Icons.trending_up : Icons.policy_outlined,
                          size: 18,
                          color:
                              isMarket
                                  ? const Color(0xFF388E3C)
                                  : const Color(0xFF3949AB),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title']!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color:
                                    isMarket
                                        ? const Color(0xFF388E3C)
                                        : const Color(0xFF3949AB),
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item['subtitle']!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // View details link
                      Row(
                        children: [
                          Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color:
                                  isMarket
                                      ? const Color(0xFF388E3C)
                                      : const Color(0xFF3949AB),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            size: 20,
                            color:
                                isMarket
                                    ? const Color(0xFF388E3C)
                                    : const Color(0xFF3949AB),
                          ),
                        ],
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
