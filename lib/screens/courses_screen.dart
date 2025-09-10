import 'package:flutter/material.dart';
import 'package:krishi_sakhi/components/drawer.dart';
import 'package:krishi_sakhi/models/courses_model.dart';
import 'package:krishi_sakhi/screens/courses_detail_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});
  @override
  State<CoursesScreen> createState() => _CoursesScreenState();

  static final List<Course> _sampleCourses = [
    Course(
      title: 'Organic Farming Fundamentals',
      instructor: 'Dr. Sarah Johnson',
      duration: '6 weeks',
      language: 'English',
      imageUrl:
          'https://images.unsplash.com/photo-1574943320219-553eb213f72d?w=400',
      rating: 4.8,
      students: 1250,
      category: 'Sustainable Agriculture',
      level: 'Beginner',
      isFree: true,
      description:
          'Learn the basics of organic farming methods and sustainable practices',
    ),
    Course(
      title: 'Smart Irrigation Systems',
      instructor: 'Prof. Michael Chen',
      duration: '4 weeks',
      language: 'English',
      imageUrl:
          'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400',
      rating: 4.7,
      students: 980,
      category: 'Technology',
      level: 'Intermediate',
      isFree: true,

      description:
          'Master modern irrigation techniques and water conservation methods',
    ),
    Course(
      title: 'Integrated Pest Management',
      instructor: 'Dr. Emily Rodriguez',
      duration: '8 weeks',
      language: 'English',
      imageUrl:
          'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=400',
      rating: 4.9,
      students: 1500,
      category: 'Crop Protection',
      level: 'Advanced',
      isFree: true,

      description:
          'Comprehensive pest control strategies for sustainable farming',
    ),
    Course(
      title: 'Soil Health & Fertility Management',
      instructor: 'Dr. James Wilson',
      duration: '5 weeks',
      language: 'English',
      imageUrl:
          'https://images.unsplash.com/photo-1560493676-04071c5f467b?w=400',
      rating: 4.6,
      students: 750,
      category: 'Soil Science',
      level: 'Beginner',
      isFree: true,
      description:
          'Understand soil composition and improve fertility naturally',
    ),
  ];
}

class _CoursesScreenState extends State<CoursesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Course> _filteredCourses = [];

  @override
  void initState() {
    super.initState();
    _filteredCourses = CoursesScreen._sampleCourses;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCourses(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _filteredCourses = CoursesScreen._sampleCourses;
      } else {
        _filteredCourses =
            CoursesScreen._sampleCourses.where((course) {
              return course.title.toLowerCase().contains(query.toLowerCase()) ||
                  course.instructor.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  course.category.toLowerCase().contains(query.toLowerCase()) ||
                  course.level.toLowerCase().contains(query.toLowerCase());
            }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: _toggleDrawer,
        ),
        title: const Text(
          'Krishi Courses',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            height: 50,
            margin: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _filterCourses,
              style: TextStyle(color: Color(0xFF212121), fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Search courses, instructors, or categories...',
                hintStyle: TextStyle(color: Color(0xFF757575), fontSize: 15),
                prefixIcon: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child:
                      _isSearching
                          ? IconButton(
                            key: ValueKey('clear'),
                            icon: Icon(Icons.clear, color: Color(0xFF2E7D32)),
                            onPressed: () {
                              _searchController.clear();
                              _filterCourses('');
                            },
                          )
                          : Icon(
                            Icons.search,
                            color: Color(0xFF2E7D32),
                            key: ValueKey('search'),
                          ),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),

          // Rest of the content
          Expanded(
            child:
                _filteredCourses.isEmpty && _isSearching
                    ? _buildEmptySearchResult()
                    : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filteredCourses.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: CourseCard(
                                  course: _filteredCourses[index],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Color(0xFF757575).withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            'No courses found',
            style: TextStyle(
              color: Color(0xFF212121),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try different keywords or browse all courses',
            style: TextStyle(color: Color(0xFF757575), fontSize: 14),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            icon: Icon(Icons.refresh),
            label: Text('View All Courses'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              _searchController.clear();
              _filterCourses('');
            },
          ),
        ],
      ),
    );
  }

  void _toggleDrawer() {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeDrawer();
    } else {
      _scaffoldKey.currentState?.openDrawer();
    }
  }
}

class CourseCard extends StatelessWidget {
  final Course course;

  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailScreen(course: course),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Image Section
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Stack(
                  children: [
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(course.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.2),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              course.isFree
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFF2196F3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          course.isFree
                              ? 'FREE'
                              : '\$${course.price?.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          course.level,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Course Content Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Category and Rating Row
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                course.category,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Color(0xFFFF9800),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                course.rating.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF616161),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Course Title
                      Text(
                        course.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Instructor
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 14,
                            color: Color(0xFF616161),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              course.instructor,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF616161),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Duration and Students
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_outlined,
                            size: 14,
                            color: Color(0xFF616161),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            course.duration,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF616161),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Icon(
                            Icons.people_outline,
                            size: 14,
                            color: Color(0xFF616161),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${course.students}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF616161),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Enroll Button
                      SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            course.isFree ? 'Enroll Free' : 'Enroll Now',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
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
      ),
    );
  }
}
