import 'package:flutter/material.dart';
import 'package:krishi_sakhi/components/drawer.dart';

class Course {
  final String title;
  final String instructor;
  final String duration;
  final String language;
  final String imageUrl;
  final double rating;
  final int students;
  final String category;
  final String level;
  final bool isFree;
  final double? price;
  final String description;

  Course({
    required this.title,
    required this.instructor,
    required this.duration,
    required this.language,
    required this.imageUrl,
    required this.rating,
    required this.students,
    required this.category,
    required this.level,
    required this.isFree,
    this.price,
    required this.description,
  });
}

// Move sample courses to a top-level constant
final List<Course> sampleCourses = [
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

class CoursesScreen extends StatefulWidget {
  CoursesScreen({Key? key}) : super(key: key);
  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: CoursesScreen._sampleCourses.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: CourseCard(
                    course: CoursesScreen._sampleCourses[index],
                  ),
                );
              },
            ),
          ],
        ),
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

  const CourseCard({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to course details
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
