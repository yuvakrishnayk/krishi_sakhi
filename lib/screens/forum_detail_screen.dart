import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/forum_models.dart';

class ForumDetailScreen extends StatefulWidget {
  final PostData post;

  const ForumDetailScreen({super.key, required this.post});

  @override
  _ForumDetailScreenState createState() => _ForumDetailScreenState();
}

class _ForumDetailScreenState extends State<ForumDetailScreen> {
  bool isLiked = false;
  bool isBookmarked = false;
  int likeCount = 0;
  final TextEditingController _commentController = TextEditingController();
  List<CommentData> comments = [];

  // Clean color theme
  final Color primaryColor = Color(0xFF2E7D32);
  final Color backgroundColor = Color(0xFFF8F9FA);
  final Color cardColor = Colors.white;
  final Color textPrimaryColor = Color(0xFF212121);
  final Color textSecondaryColor = Color(0xFF757575);
  final Color likeColor = Color(0xFFE91E63);

  @override
  void initState() {
    super.initState();
    isLiked = widget.post.isLiked;
    isBookmarked = widget.post.isBookmarked;
    likeCount = widget.post.likes;
    _initializeComments();
  }

  void _initializeComments() {
    comments = [
      CommentData(
        id: '1',
        author: 'Dr. Rajesh Kumar',
        content:
            'Excellent analysis on sustainable farming practices. The emphasis on soil microbiome health is particularly noteworthy.',
        timeAgo: '2h ago',
        likes: 24,
        isExpert: true,
      ),
      CommentData(
        id: '2',
        author: 'Priya Patel',
        content:
            'As a young farmer, this post is incredibly valuable. Currently managing 25 acres using these principles.',
        timeAgo: '4h ago',
        likes: 18,
        isExpert: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          'Posts',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPostCard(),
            SizedBox(height: 16),
            _buildCommentsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard() {
    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          if (widget.post.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 200,
                child: Image.network(
                  widget.post.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: primaryColor.withOpacity(0.1),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: textSecondaryColor,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Image not available',
                              style: TextStyle(
                                color: textSecondaryColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      color: primaryColor.withOpacity(0.05),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: primaryColor,
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Content section with padding
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category badge with like button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(widget.post.icon, size: 14, color: primaryColor),
                          SizedBox(width: 4),
                          Text(
                            widget.post.category,
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          likeCount.toString(),
                          style: TextStyle(
                            color: textSecondaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        IconButton(
                          onPressed: _toggleLike,
                          icon: Icon(
                            isLiked
                                ? Icons.favorite
                                : Icons.favorite_outline_outlined,
                            color: isLiked ? likeColor : textSecondaryColor,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Title
                Text(
                  widget.post.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textPrimaryColor,
                    height: 1.3,
                  ),
                ),

                SizedBox(height: 16),

                // Author info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: primaryColor,
                      child: Text(
                        widget.post.author[0].toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.author,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textPrimaryColor,
                          ),
                        ),
                        Text(
                          widget.post.timeAgo,
                          style: TextStyle(
                            fontSize: 14,
                            color: textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Post content
                Text(
                  _getPostContent(),
                  style: TextStyle(
                    fontSize: 16,
                    color: textPrimaryColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Card(
      color: cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comments (${comments.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimaryColor,
              ),
            ),

            SizedBox(height: 16),

            // Comment input
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: primaryColor,
                  child: Text('Y', style: TextStyle(color: Colors.white)),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: primaryColor.withOpacity(0.3),
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: primaryColor),
                  onPressed: _addComment,
                ),
              ],
            ),

            SizedBox(height: 20),

            // Comments list
            ...comments.map((comment) => _buildCommentItem(comment)),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(CommentData comment) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: primaryColor,
                child: Text(
                  comment.author[0].toUpperCase(),
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.author,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: textPrimaryColor,
                          ),
                        ),
                        if (comment.isExpert) ...[
                          SizedBox(width: 4),
                          Icon(Icons.verified, size: 14, color: primaryColor),
                        ],
                      ],
                    ),
                    Text(
                      comment.timeAgo,
                      style: TextStyle(fontSize: 12, color: textSecondaryColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            comment.content,
            style: TextStyle(color: textPrimaryColor, height: 1.4),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.favorite_outline_outlined,
                size: 16,
                color: textSecondaryColor,
              ),
              SizedBox(width: 4),
              Text(
                comment.likes.toString(),
                style: TextStyle(color: textSecondaryColor, fontSize: 12),
              ),
              SizedBox(width: 16),
              Icon(Icons.reply_outlined, size: 16, color: textSecondaryColor),
              SizedBox(width: 4),
              Text(
                'Reply',
                style: TextStyle(color: textSecondaryColor, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getPostContent() {
    return '''Sustainable farming is the cornerstone of modern agriculture. It focuses on practices that maintain soil health, conserve water, and reduce environmental impact while ensuring economic viability.

Key principles include crop rotation, integrated pest management, water conservation, and organic matter incorporation. Recent studies show farms implementing these practices see a 25-30% reduction in input costs while maintaining yields.

What sustainable practices have you found most effective?''';
  }

  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });
    HapticFeedback.lightImpact();
  }

  void _addComment() {
    if (_commentController.text.trim().isEmpty) return;

    final newComment = CommentData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      author: 'You',
      content: _commentController.text.trim(),
      timeAgo: 'now',
      likes: 0,
      isExpert: false,
    );

    setState(() {
      comments.add(newComment);
      _commentController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Comment added!'), duration: Duration(seconds: 1)),
    );
  }
}
