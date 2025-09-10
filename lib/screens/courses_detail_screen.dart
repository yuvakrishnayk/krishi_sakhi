import 'package:flutter/material.dart';
import 'package:krishi_sakhi/models/courses_model.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isEnrolled = false;
  double _courseProgress = 0.0;
  int _currentVideoIndex = 0;
  bool _isVideoPlaying = false;
  final ScrollController _scrollController = ScrollController();

  // Sample video lessons data
  final List<VideoLesson> _videoLessons = [
    VideoLesson(
      id: '1',
      title: 'Introduction to Organic Farming',
      duration: '12:30',
      isCompleted: true,
      videoUrl: 'https://www.youtube.com/watch?v=Dip81m1rRrM',
      thumbnail:
          'https://images.unsplash.com/photo-1574943320219-553eb213f72d?w=400',
    ),
    VideoLesson(
      id: '2',
      title: 'Soil Preparation Techniques',
      duration: '18:45',
      isCompleted: true,
      videoUrl: 'https://sample-videos.com/farming2.mp4',
      thumbnail:
          'https://images.unsplash.com/photo-1560493676-04071c5f467b?w=400',
    ),
    VideoLesson(
      id: '3',
      title: 'Seed Selection and Planting',
      duration: '15:20',
      isCompleted: false,
      videoUrl: 'https://sample-videos.com/farming3.mp4',
      thumbnail:
          'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=400',
    ),
    VideoLesson(
      id: '4',
      title: 'Natural Pest Control Methods',
      duration: '22:10',
      isCompleted: false,
      videoUrl: 'https://sample-videos.com/farming4.mp4',
      thumbnail:
          'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=400',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _calculateProgress();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _calculateProgress() {
    int completedLessons =
        _videoLessons.where((lesson) => lesson.isCompleted).length;
    _courseProgress = completedLessons / _videoLessons.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildVideoPlayer(),
                _buildCourseInfo(),
                _buildTabSection(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      backgroundColor: const Color(0xFF2E7D32),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.course.title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        
        
      ],
    );
  }

  Widget _buildVideoPlayer() {
    final currentLesson = _videoLessons[_currentVideoIndex];

    return Container(
      height: 220,
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(currentLesson.thumbnail),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isVideoPlaying = !_isVideoPlaying;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isVideoPlaying ? Icons.pause : Icons.play_arrow,
                    size: 32,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentLesson.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Duration: ${currentLesson.duration}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
              Expanded(
                child: Text(
                  widget.course.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.course.level,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'by ${widget.course.instructor}',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF616161),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(
                Icons.star,
                '${widget.course.rating}',
                Colors.orange,
              ),
              _buildInfoChip(
                Icons.people,
                '${widget.course.students}',
                Colors.blue,
              ),
              _buildInfoChip(
                Icons.access_time,
                widget.course.duration,
                Colors.green,
              ),
              _buildInfoChip(
                Icons.language,
                widget.course.language,
                Colors.purple,
              ),
            ],
          ),
          if (_isEnrolled) ...[
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Course Progress',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    Text(
                      '${(_courseProgress * 100).toInt()}% Complete',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF616161),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _courseProgress,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF4CAF50),
                  ),
                  minHeight: 6,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF2E7D32),
            unselectedLabelColor: const Color(0xFF616161),
            indicatorColor: const Color(0xFF2E7D32),
            tabs: const [
              Tab(text: 'Lessons'),
              Tab(text: 'About'),
              Tab(text: 'Reviews'),
              Tab(text: 'Resources'),
            ],
          ),
          SizedBox(
            height: 400,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLessonsTab(),
                _buildAboutTab(),
                _buildReviewsTab(),
                _buildResourcesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _videoLessons.length,
      itemBuilder: (context, index) {
        final lesson = _videoLessons[index];
        final isCurrentLesson = index == _currentVideoIndex;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isCurrentLesson ? const Color(0xFFE8F5E8) : Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  isCurrentLesson
                      ? const Color(0xFF2E7D32)
                      : Colors.transparent,
              width: 1,
            ),
          ),
          child: ListTile(
            leading: Container(
              width: 60,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                image: DecorationImage(
                  image: NetworkImage(lesson.thumbnail),
                  fit: BoxFit.cover,
                ),
              ),
              child:
                  lesson.isCompleted
                      ? Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 20,
                        ),
                      )
                      : null,
            ),
            title: Text(
              lesson.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color:
                    isCurrentLesson
                        ? const Color(0xFF1B5E20)
                        : const Color(0xFF212121),
              ),
            ),
            subtitle: Text(
              lesson.duration,
              style: const TextStyle(fontSize: 12, color: Color(0xFF616161)),
            ),
            trailing:
                isCurrentLesson
                    ? const Icon(
                      Icons.play_circle_fill,
                      color: Color(0xFF2E7D32),
                    )
                    : null,
            onTap: () {
              setState(() {
                _currentVideoIndex = index;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildAboutTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.course.description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF212121),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'What you\'ll learn:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 12),
          ...[
            'Fundamentals of organic farming practices',
            'Soil health assessment and improvement',
            'Natural pest and disease management',
            'Crop rotation and companion planting',
            'Sustainable harvesting techniques',
          ].map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Color(0xFF4CAF50),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF212121),
                      ),
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

  Widget _buildReviewsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text(
              '${widget.course.rating}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < widget.course.rating.floor()
                            ? Icons.star
                            : Icons.star_border,
                        size: 20,
                        color: Colors.orange,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Based on ${widget.course.students} reviews',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF616161),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...List.generate(3, (index) => _buildReviewItem()),
      ],
    );
  }

  Widget _buildReviewItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF2E7D32),
                child: Text(
                  'A',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Anonymous User',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < 4 ? Icons.star : Icons.star_border,
                            size: 12,
                            color: Colors.orange,
                          );
                        }),
                        const SizedBox(width: 8),
                        const Text(
                          '2 days ago',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF616161),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Excellent course! The instructor explains complex concepts in a very simple and practical way. Highly recommended for beginners.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF212121),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesTab() {
    final resources = [
      {'title': 'Course PDF Guide', 'type': 'PDF', 'size': '2.5 MB'},
      {'title': 'Farming Tools Checklist', 'type': 'PDF', 'size': '1.2 MB'},
      {'title': 'Seasonal Planting Calendar', 'type': 'PDF', 'size': '3.1 MB'},
      {'title': 'Pest Identification Guide', 'type': 'PDF', 'size': '5.8 MB'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final resource = resources[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E8),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.picture_as_pdf,
                color: Color(0xFF2E7D32),
                size: 20,
              ),
            ),
            title: Text(
              resource['title']!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
            ),
            subtitle: Text(
              '${resource['type']} • ${resource['size']}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF616161)),
            ),
            trailing: const Icon(
              Icons.download,
              color: Color(0xFF2E7D32),
              size: 20,
            ),
            onTap: () {},
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child:
            _isEnrolled
                ? Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Continue Learning'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF2E7D32)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.download,
                          color: Color(0xFF2E7D32),
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                )
                : Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.course.isFree
                              ? 'Free Course'
                              : '\$${widget.course.price?.toStringAsFixed(2) ?? '0.00'}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                widget.course.isFree
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFF1B5E20),
                          ),
                        ),
                        if (!widget.course.isFree)
                          const Text(
                            'One-time payment',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF616161),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isEnrolled = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          widget.course.isFree ? 'Enroll Free' : 'Enroll Now',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}

class VideoLesson {
  final String id;
  final String title;
  final String duration;
  final bool isCompleted;
  final String videoUrl;
  final String thumbnail;

  VideoLesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.isCompleted,
    required this.videoUrl,
    required this.thumbnail,
  });
}
