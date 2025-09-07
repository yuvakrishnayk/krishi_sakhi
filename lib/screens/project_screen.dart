import 'package:flutter/material.dart';
import 'package:krishi_sakhi/components/drawer.dart';
import 'package:intl/intl.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  // Fix the default selected day index to correctly point to today
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final primaryColor = const Color(0xFF2E7D32);
  final backgroundColor = const Color(0xFFF5F7FA);
  final today = DateTime.now();
  int _selectedDayIndex = 3; // Changed from 2 to 3 to correctly represent today

  void _toggleDrawer() {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeDrawer();
    } else {
      _scaffoldKey.currentState?.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the selected date
    final selectedDate = DateTime(
      today.year,
      today.month,
      today.day + (_selectedDayIndex - 3), // Changed from -2 to -3
    );

    // Determine section title based on selected date
    String sectionTitle = 'Today\'s Tasks';
    if (selectedDate.day == today.day - 1) {
      sectionTitle = 'Yesterday\'s Tasks';
    } else if (selectedDate.day < today.day - 1) {
      sectionTitle = 'Tasks for ${DateFormat('MMM d').format(selectedDate)}';
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Krishi Sakhi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: _toggleDrawer,
          tooltip: 'Open navigation menu',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            splashRadius: 24,
            tooltip: 'Settings',
            onPressed: () {},
          ),
        ],
        elevation: 4,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCalendarSection(),
                  _buildEnhancedDailyAdvisory(selectedDate),
                  _buildProjectOverview(),
                  _buildRoadmapSection(),
                  _buildSectionHeader(sectionTitle),
                ],
              ),
            ),
            _buildTodayTasksList(),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    // Generate dates for calendar (previous 3 days, today, and next 3 days)
    final List<DateTime> dates = [];
    for (int i = -3; i <= 3; i++) {
      dates.add(DateTime(today.year, today.month, today.day + i));
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Rice Cultivation Project',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                final date = dates[index];
                final isToday =
                    date.day == today.day &&
                    date.month == today.month &&
                    date.year == today.year;
                final isSelected = index == _selectedDayIndex;

                return GestureDetector(
                  onTap: () {
                    // Only allow selecting today or past dates
                    final selectedDate = dates[index];
                    if (selectedDate.isAfter(
                      DateTime(today.year, today.month, today.day),
                    )) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Future tasks will be available on their scheduled date',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: primaryColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          duration: Duration(seconds: 3),
                          action: SnackBarAction(
                            label: 'DISMISS',
                            textColor: Colors.white,
                            onPressed: () {
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar();
                            },
                          ),
                          elevation: 4,
                          dismissDirection: DismissDirection.horizontal,
                        ),
                      );
                      return;
                    }
                    setState(() {
                      _selectedDayIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 60,
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isToday ? primaryColor : Colors.grey.shade300,
                        width: isToday ? 2 : 1,
                      ),
                    ),
                    child: Opacity(
                      // Dim future dates to show they're not selectable
                      opacity:
                          date.isAfter(
                                DateTime(today.year, today.month, today.day),
                              )
                              ? 0.5
                              : 1.0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('E').format(date).substring(0, 3),
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? Colors.white
                                      : Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  isToday && !isSelected
                                      ? Colors.green.shade50
                                      : isSelected
                                      ? Colors.white
                                      : null,
                            ),
                            child: Center(
                              child: Text(
                                '${date.day}',
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? primaryColor
                                          : Colors.grey.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
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

  Widget _buildProjectOverview() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.eco, color: primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rice Field',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Started: May 15',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
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
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'On Track',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
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
                    '70%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: 0.7,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  minHeight: 8,
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
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Watered today',
                    style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(60, 30),
                ),
                child: const Text('Details'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapSection() {
    final roadmapData = {
      "week1": ["Prepare nursery"],
      "week2": ["Irrigate beds"],
      "week3": ["Transplant seedlings"],
      "week6": ["Apply urea"],
      "week10": ["Check for leaf spot"],
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                'Roadmap',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...roadmapData.entries.map((entry) {
            final weekNum = int.tryParse(entry.key.replaceAll('week', '')) ?? 0;
            final isCurrentWeek =
                weekNum == 3; // Example: assuming we're in week 3
            final isPastWeek = weekNum < 3;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Week ${weekNum}',
                      style: TextStyle(
                        color:
                            isCurrentWeek ? primaryColor : Colors.grey.shade700,
                        fontWeight:
                            isCurrentWeek ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Container(
                    width: 24,
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color:
                                isPastWeek
                                    ? primaryColor
                                    : isCurrentWeek
                                    ? primaryColor
                                    : Colors.grey.shade300,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  isCurrentWeek
                                      ? primaryColor
                                      : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child:
                              isPastWeek
                                  ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                  : null,
                        ),
                        if (entry.key !=
                            'week10') // Don't show line for last item
                          Container(
                            width: 2,
                            height: 30,
                            color:
                                isPastWeek
                                    ? primaryColor
                                    : Colors.grey.shade300,
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          entry.value
                              .map(
                                (task) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Text(
                                    task,
                                    style: TextStyle(
                                      decoration:
                                          isPastWeek
                                              ? TextDecoration.lineThrough
                                              : null,
                                      color:
                                          isPastWeek
                                              ? Colors.grey.shade500
                                              : isCurrentWeek
                                              ? Colors.black
                                              : Colors.grey.shade700,
                                      fontWeight:
                                          isCurrentWeek
                                              ? FontWeight.w500
                                              : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333),
        ),
      ),
    );
  }

  Widget _buildTodayTasksList() {
    // Add date field to each task
    final allTasks = [
      {
        'title': 'Apply organic fertilizer',
        'time': '9:00 AM',
        'isDone': true,
        'icon': Icons.grass,
        'date': DateTime(today.year, today.month, today.day - 1), // Yesterday
      },
      {
        'title': 'Irrigation check',
        'time': '11:30 AM',
        'isDone': false,
        'icon': Icons.water_drop,
        'date': DateTime(today.year, today.month, today.day), // Today
      },
      {
        'title': 'Pest monitoring',
        'time': '2:00 PM',
        'isDone': false,
        'icon': Icons.bug_report,
        'date': DateTime(today.year, today.month, today.day), // Today
      },
      {
        'title': 'Harvest planning',
        'time': '4:30 PM',
        'isDone': false,
        'icon': Icons.agriculture,
        'date': DateTime(today.year, today.month, today.day + 1), // Tomorrow
      },
      {
        'title': 'Soil testing',
        'time': '10:00 AM',
        'isDone': false,
        'icon': Icons.science,
        'date': DateTime(today.year, today.month, today.day + 1), // Tomorrow
      },
    ];

    // Get the selected date from the calendar
    final selectedDate = DateTime(
      today.year,
      today.month,
      today.day + (_selectedDayIndex - 3), // Changed from -2 to -3
    );

    // Filter tasks for the selected date
    final filteredTasks =
        allTasks.where((task) {
          final taskDate = task['date'] as DateTime;
          return taskDate.year == selectedDate.year &&
              taskDate.month == selectedDate.month &&
              taskDate.day == selectedDate.day;
        }).toList();

    // Update the section header based on the selected date
    if (selectedDate.day == today.day - 1) {
    } else if (selectedDate.day < today.day - 1) {}

    if (filteredTasks.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.grey.shade400,
                  size: 48,
                ),
                SizedBox(height: 12),
                Text(
                  'No tasks for this day',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final task = filteredTasks[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12, left: 16, right: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    task['isDone'] as bool
                        ? Colors.grey.shade100
                        : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                task['icon'] as IconData,
                color: task['isDone'] as bool ? Colors.grey : primaryColor,
              ),
            ),
            title: Text(
              task['title'] as String,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                decoration:
                    task['isDone'] as bool ? TextDecoration.lineThrough : null,
                color:
                    task['isDone'] as bool
                        ? Colors.grey.shade500
                        : Colors.grey.shade800,
              ),
            ),
            subtitle: Text(
              task['time'] as String,
              style: TextStyle(
                color:
                    task['isDone'] as bool
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
              ),
            ),
            trailing: Checkbox(
              value: task['isDone'] as bool,
              onChanged: (value) {},
              activeColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onTap: () {},
          ),
        );
      }, childCount: filteredTasks.length),
    );
  }

  Widget _buildEnhancedDailyAdvisory(DateTime selectedDate) {
    // Check if selected date is in the past, today, or future
    selectedDate.isBefore(
      DateTime(today.year, today.month, today.day),
    );
    final isToday =
        selectedDate.day == today.day &&
        selectedDate.month == today.month &&
        selectedDate.year == today.year;

    // Only show content for today or past dates
    if (selectedDate.isAfter(DateTime(today.year, today.month, today.day))) {
      return SizedBox.shrink(); // Don't show advisory for future days
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday ? primaryColor.withOpacity(0.2) : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with date and refresh button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isToday ? Icons.today : Icons.event,
                    color: isToday ? primaryColor : Colors.grey.shade700,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isToday
                        ? "Today's Advisory"
                        : "Advisory for ${DateFormat('MMM d').format(selectedDate)}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isToday ? primaryColor : Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              if (isToday)
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.refresh, color: primaryColor, size: 16),
                  label: Text(
                    'Refresh',
                    style: TextStyle(color: primaryColor, fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(60, 20),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Weather section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weather icon and temperature
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      isToday ? Icons.wb_sunny : Icons.history,
                      size: 32,
                      color: isToday ? Colors.orange : Colors.grey.shade600,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isToday ? '32°C' : '29°C',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      isToday ? 'Sunny' : 'Was Cloudy',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Weather metrics
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Field Conditions',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMetricItem(
                          Icons.water_drop,
                          isToday ? '72%' : '68%',
                          'Soil Moisture',
                        ),
                        _buildMetricItem(
                          Icons.air,
                          isToday ? '10 km/h' : '8 km/h',
                          'Wind',
                        ),
                        _buildMetricItem(
                          Icons.opacity,
                          isToday ? '68%' : '75%',
                          'Humidity',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isToday
                          ? 'Weather conditions are optimal for field operations today.'
                          : 'Weather conditions were suitable for field activities.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 24),

          // Pest alert section
          Row(
            children: [
              Icon(
                Icons.pest_control_outlined,
                color: isToday ? Colors.red.shade700 : Colors.grey.shade700,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Pest Alert',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isToday ? Colors.red.shade700 : Colors.grey.shade700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isToday ? Colors.red.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isToday ? 'High Risk' : 'Medium Risk',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isToday ? Colors.red.shade700 : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isToday
                ? 'Leaf Folder detected in nearby fields. Consider preventative measures within 48 hours.'
                : 'Brown Plant Hopper risks were monitored and controlled.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),

          const Divider(height: 24),

          // Daily recommendations section
          Row(
            children: [
              Icon(
                Icons.tips_and_updates_outlined,
                color: primaryColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Recommendations',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildRecommendationItem(
            isToday
                ? 'Optimal time for irrigation is before 10:00 AM today'
                : 'Field irrigation was completed',
            isToday,
          ),
          _buildRecommendationItem(
            isToday
                ? 'Monitor field edges for pest activity'
                : 'Pest monitoring was conducted',
            isToday,
          ),
          _buildRecommendationItem(
            isToday
                ? 'Consider fertilizer application in Section B'
                : 'Field nutrients were at optimal levels',
            isToday,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 16, color: primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildRecommendationItem(String text, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isActive ? primaryColor : Colors.grey.shade400,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isActive ? Icons.check : Icons.history,
              size: 10,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.grey.shade800 : Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
