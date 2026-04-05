import 'package:flutter/material.dart';
import 'package:krishi_sakhi/models/farm_project.dart';
import 'package:krishi_sakhi/screens/Project_Details/widgets/project_hero_app_bar.dart';

class AnalyticsScreen extends StatefulWidget {
  final FarmProject? project;

  const AnalyticsScreen({super.key, this.project});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  double get _estimatedYieldTonPerAcre {
    final project = widget.project;
    if (project == null) return 4.2;
    final area = project.calculatedAreaAcres;
    if (area <= 0) return 4.2;
    // Simple heuristic to keep demo analytics project-aware and stable.
    final estimate = 3.4 + (area * 0.18);
    return estimate.clamp(2.0, 6.0);
  }

  int get _estimatedRevenue {
    final area = widget.project?.calculatedAreaAcres ?? 1.0;
    return (area * 85000).round();
  }

  int get _estimatedExpenses {
    final area = widget.project?.calculatedAreaAcres ?? 1.0;
    return (area * 33500).round();
  }

  int get _estimatedProfit => _estimatedRevenue - _estimatedExpenses;

  String _formatCurrency(int amount) {
    final normalized = amount.toString();
    final regex = RegExp(r'(\d{1,2})(?=(\d{2})+(?!\d))');
    final lastThree = normalized.substring(normalized.length - 3);
    final otherNumbers = normalized.substring(0, normalized.length - 3);
    if (otherNumbers.isEmpty) {
      return '₹$lastThree';
    }
    return '₹${otherNumbers.replaceAllMapped(regex, (m) => '${m[1]},')}$lastThree';
  }

  String get _cropName {
    final crop = widget.project?.cropName.trim();
    if (crop == null || crop.isEmpty) return 'Samba Rice';
    return crop;
  }

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
      body: Column(
        children: [
          const ProjectHeroAppBar(
            title: 'Analytics',
            subtitle: 'Farm insights and forecasts',
            leadingIcon: Icons.analytics_rounded,
            chips: [
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFarmerTipCard(
            title: 'How to read this section',
            message:
                'Yield shows expected production per acre. If trend is flat for 2-3 weeks, increase nutrient and irrigation checks.',
            icon: Icons.lightbulb_rounded,
            color: const Color(0xFF2E7D32),
          ),
          const SizedBox(height: 12),
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
    final yield = _estimatedYieldTonPerAcre;
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
          Text(
            'Expected Yield • $_cropName',
            style: TextStyle(
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
              _buildYieldStat(
                'Target',
                '${(yield + 0.3).toStringAsFixed(1)} T',
                Colors.white70,
              ),
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
    final peak = _estimatedYieldTonPerAcre;
    final values = [
      (peak * 0.50),
      (peak * 0.65),
      (peak * 0.75),
      (peak * 0.88),
      (peak * 0.95),
      peak,
    ];
    const maxVal = 5.0;

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
                      values[i].toStringAsFixed(1),
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
    final projectCrop = _cropName;
    final crops = [
      {
        'name': projectCrop,
        'yield': _estimatedYieldTonPerAcre,
        'profit': _formatCurrency(_estimatedProfit),
      },
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
          _buildFarmerTipCard(
            title: 'Weather to action',
            message:
                'Check rain % before spraying. If rain chance is above 60%, postpone pesticide and prefer drainage checks.',
            icon: Icons.info_rounded,
            color: const Color(0xFF1565C0),
          ),
          const SizedBox(height: 12),
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
            child: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFF1565C0),
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
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
    final areaMultiplier = (widget.project?.calculatedAreaAcres ?? 1.0).clamp(
      0.5,
      6.0,
    );
    final expenses = [
      {
        'category': 'Seeds',
        'amount': (4200 * areaMultiplier).round(),
        'icon': Icons.grass_rounded,
        'color': const Color(0xFF2E7D32),
      },
      {
        'category': 'Fertilizers',
        'amount': (8500 * areaMultiplier).round(),
        'icon': Icons.science_rounded,
        'color': const Color(0xFF1565C0),
      },
      {
        'category': 'Pesticides',
        'amount': (3200 * areaMultiplier).round(),
        'icon': Icons.pest_control_rounded,
        'color': const Color(0xFFD32F2F),
      },
      {
        'category': 'Labour',
        'amount': (12000 * areaMultiplier).round(),
        'icon': Icons.people_rounded,
        'color': const Color(0xFFF57F17),
      },
      {
        'category': 'Irrigation',
        'amount': (5600 * areaMultiplier).round(),
        'icon': Icons.water_drop_rounded,
        'color': const Color(0xFF0097A7),
      },
    ];
    final total = expenses.fold<int>(0, (sum, e) => sum + (e['amount'] as int));
    final revenue = _estimatedRevenue;
    final profit = _estimatedProfit;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFarmerTipCard(
            title: 'Expense guidance',
            message:
                'Try to keep spending below 45% of expected revenue. If a category spikes, review usage before next purchase.',
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
                    const Text(
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
                    Text(
                      _formatCurrency(revenue),
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
                      child: Text(
                        'Profit: ${_formatCurrency(profit)}',
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
                  final amount = e['amount'] as int;
                  final pct = amount / total;
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
                                    _formatCurrency(amount),
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
