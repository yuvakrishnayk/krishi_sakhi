import 'package:flutter/material.dart';
import '../components/drawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Sample data for dashboard (in a real app, this would come from an API)
  final weatherInfo = {"temp": "32°C", "condition": "Sunny", "humidity": "65%"};
  final cropTips = [
    {"crop": "Rice", "tip": "Time for second fertilizer application"},
    {"crop": "Wheat", "tip": "Check for pest infestation"},
    {"crop": "Cotton", "tip": "Irrigation needed this week"},
  ];
  final marketPrices = [
    {"crop": "Rice", "price": "₹2,100/quintal", "trend": "up"},
    {"crop": "Wheat", "price": "₹1,950/quintal", "trend": "stable"},
    {"crop": "Cotton", "price": "₹6,200/quintal", "trend": "down"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Krishi Sakhi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Handle notification action
            },
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(color: Colors.green[50]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome banner
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade700, Colors.green.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 30,
                      child: Icon(
                        Icons.agriculture,
                        size: 30,
                        color: Colors.green[700],
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, Farmer!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Your farming assistant is ready',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Weather section
              _buildSectionCard(
                'Today\'s Weather',
                Icons.wb_sunny,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _weatherItem(
                      Icons.thermostat,
                      "Temperature",
                      weatherInfo["temp"]!,
                    ),
                    _weatherItem(
                      Icons.water_drop,
                      "Humidity",
                      weatherInfo["humidity"]!,
                    ),
                    _weatherItem(
                      Icons.filter_drama,
                      "Condition",
                      weatherInfo["condition"]!,
                    ),
                  ],
                ),
              ),

              // Crop advisory section
              _buildSectionCard(
                'Crop Advisory',
                Icons.eco,
                Column(
                  children:
                      cropTips
                          .map(
                            (tip) => _buildTipItem(
                              tip["crop"]!,
                              tip["tip"]!,
                              Icons.grass,
                            ),
                          )
                          .toList(),
                ),
              ),

              // Market prices section
              _buildSectionCard(
                'Market Prices',
                Icons.storefront,
                Column(
                  children:
                      marketPrices
                          .map(
                            (item) => _buildPriceItem(
                              item["crop"]!,
                              item["price"]!,
                              item["trend"] == "up"
                                  ? Icons.arrow_upward
                                  : item["trend"] == "down"
                                  ? Icons.arrow_downward
                                  : Icons.arrow_forward,
                              item["trend"] == "up"
                                  ? Colors.green
                                  : item["trend"] == "down"
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          )
                          .toList(),
                ),
              ),

              // Quick actions section
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  childAspectRatio: 1.0,
                  children: [
                    _buildActionButton('Crop Calendar', Icons.calendar_today),
                    _buildActionButton('Pest Control', Icons.bug_report),
                    _buildActionButton('Soil Health', Icons.landscape),
                    _buildActionButton('Expert Help', Icons.support_agent),
                    _buildActionButton('Community', Icons.people),
                    _buildActionButton('Resources', Icons.menu_book),
                  ],
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, Widget content) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: Colors.green[700]),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey[200]),
          Padding(padding: EdgeInsets.all(16), child: content),
        ],
      ),
    );
  }

  Widget _weatherItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.green[700], size: 32),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTipItem(String crop, String tip, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.green[100],
            child: Icon(icon, color: Colors.green[700], size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(crop, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text(tip, style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceItem(
    String crop,
    String price,
    IconData trendIcon,
    Color trendColor,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(crop, style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Text(price, style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Icon(trendIcon, color: trendColor, size: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon) {
    return Card(
      elevation: 0,
      color: Colors.green[100],
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.green[700], size: 28),
            SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
