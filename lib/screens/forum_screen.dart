import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:krishi_sakhi/components/drawer.dart';

class ForumScreen extends StatefulWidget {
  @override
  _ForumScreenState createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;

  // Updated color theme to match home screen
  final Color primaryColor = Color(0xFF2E7D32);
  final Color secondaryColor = Color(0xFF388E3C);
  final Color backgroundColor = Color(0xFFFFFBF5);
  final Color cardColor = Colors.white;
  final Color textPrimaryColor = Color(0xFF212121);
  final Color textSecondaryColor = Color(0xFF757575);
  final Color accentColor = Color(0xFF81C784);

  List<PostData> allPosts = [
    PostData(
      id: '1',
      title: 'Best Practices for Sustainable Rice Cultivation',
      author: 'KrishiGuru',
      timeAgo: '7m read time',
      category: 'Organic Farming',
      likes: 72,
      comments: 18,
      isBookmarked: false,
      gradient: LinearGradient(
        colors: [Color(0xFF81C784), Color(0xFF388E3C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.eco,
    ),
    PostData(
      id: '2',
      title: 'Effective Water Management Techniques for Drought Conditions',
      author: 'WaterConservationist',
      timeAgo: '6m read time',
      category: 'Irrigation',
      likes: 23,
      comments: 7,
      isBookmarked: true,

      gradient: LinearGradient(
        colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.water_drop,
    ),
    PostData(
      id: '3',
      title: 'Natural Pest Control Methods for Vegetable Gardens',
      author: 'OrganicFarmer',
      timeAgo: '12m read time',
      category: 'Pest Management',
      likes: 156,
      comments: 34,
      isBookmarked: false,
      imageUrl:
          'https://images.unsplash.com/photo-1523348837708-15d4a09cfac2?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      gradient: LinearGradient(
        colors: [Color(0xFFDAD299), Color(0xFFB0DAB9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.bug_report,
    ),
    PostData(
      id: '4',
      title: 'How to Choose the Right Fertilizers for Your Soil Type',
      author: 'SoilExpert',
      timeAgo: '15m read time',
      category: 'Soil Health',
      likes: 89,
      comments: 22,
      isBookmarked: true,
      imageUrl:
          'https://images.unsplash.com/photo-1590682680695-43b964a3ae17?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      gradient: LinearGradient(
        colors: [Color(0xFF7B920A), Color(0xFFADD100)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.terrain,
    ),
    PostData(
      id: '5',
      title: 'Weather Forecasting Tools for Modern Farmers in 2024',
      author: 'WeatherWatcher',
      timeAgo: '9m read time',
      category: 'Technology',
      likes: 67,
      comments: 15,
      isBookmarked: false,
      imageUrl:
          'https://images.unsplash.com/photo-1584267385427-cf4894528b38?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      gradient: LinearGradient(
        colors: [Color(0xFF73C8A9), Color(0xFF373B44)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.cloud,
    ),
    PostData(
      id: '6',
      title: 'Government Subsidies and Schemes for Small-Scale Farmers',
      author: 'AgriPolicy',
      timeAgo: '5m read time',
      category: 'Finance',
      likes: 234,
      comments: 56,
      isBookmarked: false,

      gradient: LinearGradient(
        colors: [Color(0xFF93A5CF), Color(0xFFE4EfE9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      icon: Icons.account_balance,
    ),
  ];

  List<PostData> filteredPosts = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    filteredPosts = allPosts;

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterPosts(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        filteredPosts = allPosts;
      } else {
        filteredPosts =
            allPosts.where((post) {
              return post.title.toLowerCase().contains(query.toLowerCase()) ||
                  post.category.toLowerCase().contains(query.toLowerCase()) ||
                  post.author.toLowerCase().contains(query.toLowerCase());
            }).toList();
      }
    });
  }

  void _toggleBookmark(String postId) {
    setState(() {
      // Update in both filtered and all posts to maintain consistency
      final postIndex = allPosts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        allPosts[postIndex].isBookmarked = !allPosts[postIndex].isBookmarked;
      }

      final filteredPostIndex = filteredPosts.indexWhere(
        (post) => post.id == postId,
      );
      if (filteredPostIndex != -1) {
        filteredPosts[filteredPostIndex].isBookmarked =
            allPosts[postIndex].isBookmarked;
      }
    });

    // Show feedback with a snackbar
    final post = allPosts.firstWhere((post) => post.id == postId);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          post.isBookmarked ? 'Added to bookmarks' : 'Removed from bookmarks',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Set system overlay style for status bar
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Krishi Forum',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: _toggleDrawer,
          tooltip: 'Open navigation menu',
        ),
        elevation: 4,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar - moved to body
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
                onChanged: _filterPosts,
                style: TextStyle(color: textPrimaryColor, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Search posts, topics, or authors...',
                  hintStyle: TextStyle(color: textSecondaryColor, fontSize: 15),
                  prefixIcon: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child:
                        _isSearching
                            ? IconButton(
                              icon: Icon(Icons.clear, color: primaryColor),
                              onPressed: () {
                                _searchController.clear();
                                _filterPosts('');
                              },
                            )
                            : Icon(Icons.search, color: primaryColor),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),

            // Create Post Button - moved to body
            Container(
              margin: EdgeInsets.only(bottom: 16, left: 16, right: 16),
              width: double.infinity,
              child: Material(
                borderRadius: BorderRadius.circular(15),
                elevation: 3,
                shadowColor: primaryColor.withOpacity(0.3),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Color(0xFFF8FFF8)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: primaryColor.withOpacity(0.15)),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    splashColor: primaryColor.withOpacity(0.1),
                    highlightColor: primaryColor.withOpacity(0.05),
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      // TODO: Implement create post functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Create new post'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: primaryColor,
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit_note, size: 22, color: primaryColor),
                          SizedBox(width: 10),
                          Text(
                            'Create New Post',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Animated posts list
            Expanded(
              child:
                  filteredPosts.isEmpty && _isSearching
                      ? _buildEmptySearchResult()
                      : AnimatedList(
                        initialItemCount: filteredPosts.length,
                        itemBuilder: (context, index, animation) {
                          final post = filteredPosts[index];
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutQuint,
                              ),
                            ),
                            child: FadeTransition(
                              opacity: animation,
                              child: PostCard(
                                post: post,
                                onBookmarkToggle:
                                    () => _toggleBookmark(post.id),
                                onTap: () => _onPostTap(post),
                                cardColor: cardColor,
                                textColor: textPrimaryColor,
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
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
            color: textSecondaryColor.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              color: textPrimaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try different keywords or browse all posts',
            style: TextStyle(color: textSecondaryColor, fontSize: 14),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            icon: Icon(Icons.refresh),
            label: Text('View All Posts'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              _searchController.clear();
              _filterPosts('');
            },
          ),
        ],
      ),
    );
  }

  void _onPostTap(PostData post) {
    // Add haptic feedback
    HapticFeedback.selectionClick();

    // Placeholder for post detail navigation
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening post: ${post.title}'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

// Update PostCard to use solid color instead of gradient
class PostCard extends StatelessWidget {
  final PostData post;
  final VoidCallback onBookmarkToggle;
  final VoidCallback onTap;
  final Color cardColor;
  final Color textColor;

  const PostCard({
    Key? key,
    required this.post,
    required this.onBookmarkToggle,
    required this.onTap,
    required this.cardColor,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasImage = post.imageUrl.isNotEmpty;
    final Color solidColor = Color(0xFF2E7D32); // Use same green as home screen

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 6),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show either image or styled title container
              Stack(
                children: [
                  hasImage
                      ? Container(
                        height: 200,
                        width: double.infinity,
                        child: Image.network(
                          post.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: const Color(0xFF2E7D32),
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(height: 0);
                          },
                        ),
                      )
                      : Container(
                        height: 200,
                        width: double.infinity,
                        color: solidColor,
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                post.icon,
                                size: 40,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              SizedBox(height: 16),
                              Text(
                                post.title,
                                textAlign: TextAlign.center,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                  letterSpacing: 0.3,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: Offset(0, 1),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                  // Author avatar overlay - keep for both image and non-image posts
                  Positioned(
                    top: 12,
                    left: 12,
                    child: TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeOutQuint,
                      builder: (context, double value, child) {
                        return Transform.scale(scale: value, child: child);
                      },
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: _getAvatarColor(post.author),
                          child: Text(
                            post.author[0].toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Enhanced content - now we need to adjust based on whether we're showing a title in image area
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: solidColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category and time with better styling
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(post.icon, color: Colors.white, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                post.category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: Colors.white70,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                post.timeAgo,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Display the author byline
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'By ${post.author}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // Only show title here if it wasn't already displayed in the image area
                    if (hasImage) ...[
                      const SizedBox(height: 16),
                      // Enhanced title with animation
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0.9, end: 1.0),
                        duration: Duration(milliseconds: 800),
                        curve: Curves.easeOut,
                        builder: (context, double value, child) {
                          return Transform.scale(
                            scale: value,
                            alignment: Alignment.centerLeft,
                            child: child,
                          );
                        },
                        child: Text(
                          post.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                            letterSpacing: 0.3,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Elegant divider
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.05),
                            Colors.white.withOpacity(0.3),
                            Colors.white.withOpacity(0.05),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Enhanced actions
                    Row(
                      children: [
                        _EnhancedActionButton(
                          icon: Icons.thumb_up_outlined,
                          count: post.likes,
                          onPressed: () {},
                        ),
                        const SizedBox(width: 20),
                        _EnhancedActionButton(
                          icon: Icons.chat_bubble_outline,
                          count: post.comments,
                          onPressed: () {},
                        ),
                        const Spacer(),
                        _BookmarkButton(
                          isBookmarked: post.isBookmarked,
                          onPressed: onBookmarkToggle,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.share_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          splashRadius: 24,
                          onPressed: () {
                            HapticFeedback.selectionClick();
                          },
                          tooltip: 'Share post',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Get enhanced gradient for better visual appeal

// Generate avatar color based on author name
Color _getAvatarColor(String author) {
  final List<Color> colors = [
    Color(0xFF2E7D32), // Dark Green
    Color(0xFF5D4037), // Brown
    Color(0xFF7B1FA2), // Purple
    Color(0xFF1565C0), // Blue
    Color(0xFFD84315), // Deep Orange
    Color(0xFF00838F), // Cyan
    Color(0xFF6D4C41), // Brown
  ];

  // Simple hash function for consistent color
  int hash = 0;
  for (var i = 0; i < author.length; i++) {
    hash = (hash + author.codeUnitAt(i)) % colors.length;
  }

  return colors[hash];
}

class _EnhancedActionButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback onPressed;

  const _EnhancedActionButton({
    Key? key,
    required this.icon,
    required this.count,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onPressed();
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            SizedBox(width: 6),
            Text(
              count.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookmarkButton extends StatelessWidget {
  final bool isBookmarked;
  final VoidCallback onPressed;

  const _BookmarkButton({
    Key? key,
    required this.isBookmarked,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: IconButton(
        key: ValueKey<bool>(isBookmarked),
        icon: Icon(
          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          color: Colors.white,
          size: 20,
        ),
        splashRadius: 24,
        onPressed: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
        tooltip: isBookmarked ? 'Remove from bookmarks' : 'Add to bookmarks',
      ),
    );
  }
}

class PostData {
  final String id;
  final String title;
  final String author;
  final String timeAgo;
  final String category;
  final int likes;
  final int comments;
  bool isBookmarked;
  final String imageUrl;
  final LinearGradient gradient;
  final IconData icon;

  PostData({
    required this.id,
    required this.title,
    required this.author,
    required this.timeAgo,
    required this.category,
    required this.likes,
    required this.comments,
    required this.isBookmarked,
    this.imageUrl = '',
    required this.gradient,
    required this.icon,
  });
}
