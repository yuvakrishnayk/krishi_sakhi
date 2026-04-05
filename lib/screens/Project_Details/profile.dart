import 'package:flutter/material.dart';
import 'package:krishi_sakhi/auth/auth_repository.dart';
import 'package:krishi_sakhi/auth/auth_service.dart';
import 'package:krishi_sakhi/models/farm_project.dart';
import 'package:krishi_sakhi/screens/Project_Details/widgets/project_hero_app_bar.dart';

class InventoryScreen extends StatefulWidget {
  final FarmProject? project;
  final Map<String, dynamic>? advisoryResponse;

  const InventoryScreen({super.key, this.project, this.advisoryResponse});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final AuthRepository _authRepository = AuthRepository(service: AuthService());

  String _farmerName = 'Farmer';

  @override
  void initState() {
    super.initState();
    _loadFarmerName();
  }

  Future<void> _loadFarmerName() async {
    final cachedUser = await _authRepository.currentUser;
    if (cachedUser != null && cachedUser.name.trim().isNotEmpty && mounted) {
      setState(() => _farmerName = cachedUser.name.trim());
    }

    final latestUser = await _authRepository.fetchProfile();
    if (latestUser != null && latestUser.name.trim().isNotEmpty && mounted) {
      setState(() => _farmerName = latestUser.name.trim());
    }
  }

  List<dynamic> _asList(dynamic value) => value is List ? value : const [];

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  String get _locationName {
    final summary = _asMap(widget.advisoryResponse?['summary']);
    final responseLocation = summary['location']?.toString().trim();
    if (responseLocation != null && responseLocation.isNotEmpty) {
      return responseLocation;
    }

    if (widget.project?.locationName.isNotEmpty == true) {
      return widget.project!.locationName;
    }

    return 'Your farm';
  }

  String get _cropName {
    final crop =
        _asMap(widget.advisoryResponse?['summary'])['crop']?.toString().trim();
    if (crop != null && crop.isNotEmpty) return crop;
    if (widget.project?.cropName.isNotEmpty == true) {
      return widget.project!.cropName;
    }
    return 'Crop Advisory';
  }

  List<Map<String, dynamic>> get _months =>
      _asList(widget.advisoryResponse?['months']).map(_asMap).toList();

  int get _weeksCount =>
      _months.fold(0, (sum, month) => sum + _asList(month['weeks']).length);

  int get _daysCount => _months.fold(
    0,
    (sum, month) =>
        sum +
        _asList(month['weeks']).fold<int>(
          0,
          (weekSum, week) => weekSum + _asList(_asMap(week)['days']).length,
        ),
  );

  int get _alertsCount {
    var alerts = 0;
    for (final month in _months) {
      for (final week in _asList(month['weeks'])) {
        for (final day in _asList(_asMap(week)['days'])) {
          final weather = _asMap(_asMap(day)['weather']);
          final advisory = weather['advisory']?.toString().trim() ?? '';
          final maxTemp =
              (_asMap(weather['temperature'])['max'] as num?)?.toDouble();
          final rainfall = (weather['rainfall'] as num?)?.toDouble() ?? 0;
          final windSpeed = (weather['windSpeed'] as num?)?.toDouble() ?? 0;
          if (advisory.isNotEmpty ||
              rainfall > 0 ||
              windSpeed >= 28 ||
              (maxTemp != null && maxTemp >= 37)) {
            alerts += 1;
          }
        }
      }
    }
    return alerts;
  }

  String get _summaryText {
    final summary = _asMap(widget.advisoryResponse?['summary']);
    final text =
        summary['summary']?.toString().trim() ??
        widget.advisoryResponse?['summary']?.toString().trim();
    if (text != null && text.isNotEmpty) return text;
    return 'Track your crop plan, weather alerts, stock and mandi rates in one place.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F0),
      body: Column(
        children: [
          ProjectHeroAppBar(
            title: 'Dashboard & Inventory',
            subtitle: '$_farmerName • $_locationName',
            leadingIcon: Icons.inventory_2_rounded,
            chips: [
              ProjectHeroChipData(
                icon: Icons.today_rounded,
                value: '$_daysCount Days',
              ),
              ProjectHeroChipData(
                icon: Icons.warning_rounded,
                value: '$_alertsCount Alerts',
              ),
              ProjectHeroChipData(
                icon: Icons.trending_up_rounded,
                value: '${_months.length} Months',
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDashboardOverviewCard(),
                    const SizedBox(height: 16),
                    _buildDashboardStatRow(),
                    const SizedBox(height: 16),
                    _buildInventorySummaryCard(),
                    const SizedBox(height: 16),
                    _buildInventoryList(),
                    const SizedBox(height: 16),
                    _buildMarketRates(),
                    const SizedBox(height: 16),
                    _buildActionButtons(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardOverviewCard() {
    final irrigationText =
        widget.project == null || widget.project!.irrigationMethods.isEmpty
            ? 'Not set'
            : widget.project!.irrigationMethods.join(', ');

    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.agriculture_rounded,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _cropName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A2E1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _locationName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _summaryText,
            style: TextStyle(
              fontSize: 12,
              height: 1.45,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _overviewChip('🌾 $_cropName', const Color(0xFF2E7D32)),
              _overviewChip('💧 $irrigationText', const Color(0xFF1565C0)),
              _overviewChip(
                '🌍 ${(widget.project?.calculatedAreaAcres ?? widget.project?.acres ?? 1.0).toStringAsFixed(1)} acres',
                const Color(0xFFF57F17),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardStatRow() {
    final stats = [
      _DashStat(
        icon: Icons.calendar_month_rounded,
        label: 'Months',
        value: '${_months.length}',
      ),
      _DashStat(
        icon: Icons.view_week_rounded,
        label: 'Weeks',
        value: '$_weeksCount',
      ),
      _DashStat(icon: Icons.today_rounded, label: 'Days', value: '$_daysCount'),
      _DashStat(
        icon: Icons.warning_amber_rounded,
        label: 'Alerts',
        value: '$_alertsCount',
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
              stats
                  .map(
                    (stat) => SizedBox(
                      width: itemWidth,
                      child: _buildStatBubble(stat),
                    ),
                  )
                  .toList(),
        );
      },
    );
  }

  Widget _buildStatBubble(_DashStat stat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8E2)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(stat.icon, color: const Color(0xFF2E7D32), size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A2E1A),
                  ),
                ),
                Text(
                  stat.label,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildInventorySummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF81C784)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Stock Value 📦',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Est. ₹ 45,200',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Alert: Urea Fertilizer is running low ⚠️',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryList() {
    const inventoryItems = [
      {'item': 'Wheat Seeds (Premium)', 'qty': '50 kg', 'status': 'Good'},
      {'item': 'Urea Fertilizer', 'qty': '10 kg', 'status': 'Low'},
      {'item': 'Organic Pesticide', 'qty': '5 Liters', 'status': 'Good'},
      {'item': 'Neem Oil', 'qty': '2 Liters', 'status': 'Good'},
    ];

    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Stock',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A2E1A),
                ),
              ),
              Text(
                'See All',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...inventoryItems.map(
            (item) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor:
                    item['status'] == 'Low'
                        ? Colors.red.shade50
                        : const Color(0xFFE8F5E9),
                child: Icon(
                  Icons.eco,
                  color:
                      item['status'] == 'Low'
                          ? Colors.red
                          : const Color(0xFF2E7D32),
                  size: 20,
                ),
              ),
              title: Text(
                item['item'] as String,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                item['status'] == 'Low' ? 'Refill needed' : 'In stock',
                style: TextStyle(
                  color: item['status'] == 'Low' ? Colors.red : Colors.grey,
                  fontSize: 12,
                ),
              ),
              trailing: Text(
                item['qty'] as String,
                style: const TextStyle(
                  color: Color(0xFF1A2E1A),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketRates() {
    const rates = [
      {'crop': 'Wheat', 'price': '₹2,500', 'unit': '/ quintal', 'trend': 'up'},
      {
        'crop': 'Rice (Paddy)',
        'price': '₹3,100',
        'unit': '/ quintal',
        'trend': 'down',
      },
      {'crop': 'Maize', 'price': '₹2,100', 'unit': '/ quintal', 'trend': 'up'},
    ];

    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Market Rates (Mandi)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A2E1A),
            ),
          ),
          const SizedBox(height: 10),
          ...rates.map(
            (rate) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        rate['trend'] == 'up'
                            ? Icons.trending_up
                            : Icons.trending_down,
                        color:
                            rate['trend'] == 'up' ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        rate['crop'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  RichText(
                    text: TextSpan(
                      text: rate['price'] as String,
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: ' ${rate['unit']}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.normal,
                            fontSize: 12,
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

  Widget _buildActionButtons() {
    return _buildSectionCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _btn(Icons.add_box, 'Add Stock'),
          _btn(Icons.qr_code_scanner, 'Scan Item'),
          _btn(Icons.bar_chart, 'History'),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFF2E7D32), size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
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
      child: child,
    );
  }
}

class _DashStat {
  final IconData icon;
  final String label;
  final String value;

  const _DashStat({
    required this.icon,
    required this.label,
    required this.value,
  });
}
