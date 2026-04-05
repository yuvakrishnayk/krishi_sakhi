import 'package:flutter/material.dart';
import 'package:krishi_sakhi/screens/Project_Details/widgets/project_hero_app_bar.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F0),
      body: Column(
        children: [
          const ProjectHeroAppBar(
            title: 'Inventory & Rates',
            subtitle: 'Ramesh Farm Stock • Madurai, TN',
            leadingIcon: Icons.inventory_2_rounded,
            chips: [
              ProjectHeroChipData(
                icon: Icons.category_rounded,
                value: '12 Items',
              ),
              ProjectHeroChipData(
                icon: Icons.warning_rounded,
                value: '2 Low Stock',
              ),
              ProjectHeroChipData(
                icon: Icons.trending_up_rounded,
                value: 'Updated Today',
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
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
    final inventoryItems = [
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
    final rates = [
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
