import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:krishi_sakhi/screens/create_post_screen.dart';
import 'package:krishi_sakhi/screens/form_screen.dart';
import 'package:krishi_sakhi/providers/auth_provider.dart';
import 'forum_detail_screen.dart';
import '../models/forum_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// THEME CONSTANTS
// ─────────────────────────────────────────────────────────────────────────────
const Color kPrimary = Color(0xFF2E7D32);
const Color kPrimaryDark = Color(0xFF1B5E20);
const Color kPrimaryLight = Color(0xFF81C784);
const Color kAccent = Color(0xFF66BB6A);
const Color kBg = Color(0xFFF5F7FA);
const Color kCard = Colors.white;
const Color kTextPrimary = Color(0xFF1A1A2E);
const Color kTextSecondary = Color(0xFF6B7280);
const Color kDivider = Color(0xFFE5E7EB);
const Color kSurface = Color(0xFFFFFFFF);
const Color kOnlineGreen = Color(0xFF22C55E);
const Color kLikeRed = Color(0xFFEF4444);
const Color kWarning = Color(0xFFF59E0B);
const Color kInfo = Color(0xFF3B82F6);

// Gradient for premium feel
const LinearGradient kPrimaryGradient = LinearGradient(
  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────

class ChatMessage {
  final String id;
  final String senderName;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final Color avatarColor;

  ChatMessage({
    required this.id,
    required this.senderName,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.isOnline = false,
    required this.avatarColor,
  });
}

class CommunityItem {
  final String id;
  final String name;
  final String description;
  final int members;
  final IconData icon;
  final Color color;
  final bool isJoined;
  final String lastActive;

  CommunityItem({
    required this.id,
    required this.name,
    required this.description,
    required this.members,
    required this.icon,
    required this.color,
    this.isJoined = false,
    this.lastActive = '',
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// DUMMY DATA
// ─────────────────────────────────────────────────────────────────────────────
final List<PostData> dummyPosts = [
  PostData(
    id: '1',
    title: 'Best Practices for Sustainable Rice Cultivation',
    author: 'KrishiGuru',
    timeAgo: '2h ago',
    category: 'Organic Farming',
    likes: 72,
    comments: 18,
    icon: Icons.eco,
    description:
        'Discover how to grow rice sustainably using modern techniques while preserving traditional wisdom.',
  ),
  PostData(
    id: '2',
    title: 'Effective Water Management for Drought Conditions',
    author: 'WaterConservationist',
    timeAgo: '4h ago',
    category: 'Irrigation',
    likes: 23,
    comments: 7,
    isBookmarked: true,
    icon: Icons.water_drop,
    description:
        'Learn how to optimize water usage during drought with drip irrigation and mulching.',
  ),
  PostData(
    id: '3',
    title: 'Natural Pest Control Methods for Vegetable Gardens',
    author: 'OrganicFarmer',
    timeAgo: '6h ago',
    category: 'Pest Management',
    likes: 156,
    comments: 34,
    imageUrl:
        'https://images.unsplash.com/photo-1523348837708-15d4a09cfac2?w=800&q=80',
    icon: Icons.bug_report,
    description:
        'Say goodbye to chemicals! Natural ways to keep pests away from your veggies.',
  ),
  PostData(
    id: '4',
    title: 'How to Choose the Right Fertilizers for Your Soil',
    author: 'SoilExpert',
    timeAgo: '8h ago',
    category: 'Soil Health',
    likes: 89,
    comments: 22,
    isBookmarked: true,
    imageUrl:
        'https://images.unsplash.com/photo-1590682680695-43b964a3ae17?w=800&q=80',
    icon: Icons.terrain,
    description:
        'A comprehensive guide on soil testing and selecting the ideal fertilizer for your crops.',
  ),
  PostData(
    id: '5',
    title: 'Weather Forecasting Tools for Modern Farmers',
    author: 'WeatherWatcher',
    timeAgo: '1d ago',
    category: 'Technology',
    likes: 67,
    comments: 15,
    icon: Icons.cloud,
    description:
        'Top weather apps and tools that every farmer should be using in 2026.',
  ),
  PostData(
    id: '6',
    title: 'Government Subsidies & Schemes for Small Farmers',
    author: 'AgriPolicy',
    timeAgo: '1d ago',
    category: 'Finance',
    likes: 234,
    comments: 56,
    icon: Icons.account_balance,
    description:
        'Complete list of government programs to support small and marginal farmers.',
  ),
];

final List<ChatMessage> dummyChats = [
  ChatMessage(
    id: '1',
    senderName: 'Dr. Rajesh Kumar',
    lastMessage: 'The soil test results look promising!',
    time: '2m ago',
    unreadCount: 3,
    isOnline: true,
    avatarColor: Color(0xFF1565C0),
  ),
  ChatMessage(
    id: '2',
    senderName: 'Priya Patel',
    lastMessage: 'Can you share the irrigation schedule?',
    time: '15m ago',
    unreadCount: 1,
    isOnline: true,
    avatarColor: Color(0xFF7B1FA2),
  ),
  ChatMessage(
    id: '3',
    senderName: 'Krishi Support',
    lastMessage: 'Your query has been resolved ✅',
    time: '1h ago',
    isOnline: true,
    avatarColor: kPrimary,
  ),
  ChatMessage(
    id: '4',
    senderName: 'Ramesh Yadav',
    lastMessage: 'Thanks for the fertilizer recommendation',
    time: '3h ago',
    avatarColor: Color(0xFFD84315),
  ),
  ChatMessage(
    id: '5',
    senderName: 'Anita Sharma',
    lastMessage: 'The mango harvest was excellent this year!',
    time: '5h ago',
    unreadCount: 2,
    avatarColor: Color(0xFF00838F),
  ),
  ChatMessage(
    id: '6',
    senderName: 'Sunil Verma',
    lastMessage: 'Weather alert: Heavy rain expected tomorrow',
    time: '1d ago',
    avatarColor: Color(0xFF5D4037),
  ),
  ChatMessage(
    id: '7',
    senderName: 'AgriBot Assistant',
    lastMessage: 'Here are your crop recommendations for March',
    time: '1d ago',
    isOnline: true,
    avatarColor: Color(0xFF388E3C),
  ),
];

final List<CommunityItem> dummyChannels = [
  CommunityItem(
    id: '1',
    name: 'Organic Farmers Hub',
    description: 'Tips and tricks for chemical-free farming',
    members: 12400,
    icon: Icons.eco,
    color: Color(0xFF2E7D32),
    isJoined: true,
    lastActive: '5m ago',
  ),
  CommunityItem(
    id: '2',
    name: 'Irrigation Tech',
    description: 'Latest innovations in water management',
    members: 8300,
    icon: Icons.water_drop,
    color: Color(0xFF1565C0),
    isJoined: true,
    lastActive: '20m ago',
  ),
  CommunityItem(
    id: '3',
    name: 'Market Prices Daily',
    description: 'Real-time mandi prices & market updates',
    members: 34500,
    icon: Icons.trending_up,
    color: Color(0xFFE65100),
    lastActive: '1h ago',
  ),
  CommunityItem(
    id: '4',
    name: 'Crop Disease Alert',
    description: 'Early warning system for crop diseases',
    members: 19200,
    icon: Icons.warning_amber,
    color: Color(0xFFC62828),
    isJoined: true,
    lastActive: '30m ago',
  ),
  CommunityItem(
    id: '5',
    name: 'Weather Watch',
    description: 'Hyper-local weather forecasts for farmers',
    members: 27000,
    icon: Icons.cloud,
    color: Color(0xFF00838F),
    lastActive: '10m ago',
  ),
];

final List<CommunityItem> dummyGroups = [
  CommunityItem(
    id: '1',
    name: 'Rice Growers India',
    description: 'Community for paddy farmers across India',
    members: 4800,
    icon: Icons.grass,
    color: Color(0xFF33691E),
    isJoined: true,
    lastActive: '10m ago',
  ),
  CommunityItem(
    id: '2',
    name: 'Vegetable Garden Club',
    description: 'Share tips and harvest photos!',
    members: 3200,
    icon: Icons.local_florist,
    color: Color(0xFF7B1FA2),
    lastActive: '45m ago',
  ),
  CommunityItem(
    id: '3',
    name: 'Dairy Farmers Network',
    description: 'Milk production, cattle care & more',
    members: 6100,
    icon: Icons.pets,
    color: Color(0xFF5D4037),
    isJoined: true,
    lastActive: '2h ago',
  ),
  CommunityItem(
    id: '4',
    name: 'Agri Entrepreneurs',
    description: 'Business ideas & agri-startup discussions',
    members: 2500,
    icon: Icons.rocket_launch,
    color: Color(0xFFFF6F00),
    lastActive: '3h ago',
  ),
  CommunityItem(
    id: '5',
    name: 'Women in Agriculture',
    description: 'Empowering women farmers with knowledge',
    members: 5700,
    icon: Icons.female,
    color: Color(0xFFAD1457),
    isJoined: true,
    lastActive: '1h ago',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// HELPER
// ─────────────────────────────────────────────────────────────────────────────
Color _avatarColorFor(String name) {
  const colors = [
    Color(0xFF2E7D32),
    Color(0xFF5D4037),
    Color(0xFF7B1FA2),
    Color(0xFF1565C0),
    Color(0xFFD84315),
    Color(0xFF00838F),
    Color(0xFF6D4C41),
  ];
  int h = 0;
  for (var i = 0; i < name.length; i++) {
    h = (h + name.codeUnitAt(i)) % colors.length;
  }
  return colors[h];
}

String _formatCount(int n) {
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
  return n.toString();
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN SCREEN – Bottom Navigation Shell
// ─────────────────────────────────────────────────────────────────────────────
class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _FeedPage(),
    _ChatPage(),
    _CommunityPage(),
    _ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  activeIcon: Icons.home,
                  label: 'Feed',
                  isActive: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  activeIcon: Icons.chat_bubble_rounded,
                  label: 'Chat',
                  isActive: _currentIndex == 1,
                  badge: 6,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavItem(
                  icon: Icons.groups_outlined,
                  activeIcon: Icons.groups_rounded,
                  label: 'Community',
                  isActive: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profile',
                  isActive: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Nav Item
// ─────────────────────────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final int badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    this.badge = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 18 : 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isActive ? kPrimary.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border:
              isActive
                  ? Border.all(color: kPrimary.withOpacity(0.2), width: 1)
                  : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isActive ? activeIcon : icon,
                    key: ValueKey(isActive),
                    color:
                        isActive ? kPrimary : kTextSecondary.withOpacity(0.7),
                    size: isActive ? 26 : 24,
                  ),
                ),
                if (badge > 0)
                  Positioned(
                    right: -8,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFF87171)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        badge > 9 ? '9+' : badge.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child:
                  isActive
                      ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: kPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            letterSpacing: 0.2,
                          ),
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 1 — FEED (Posts + Create Post)
// ═══════════════════════════════════════════════════════════════════════════════
class _FeedPage extends StatefulWidget {
  const _FeedPage();

  @override
  State<_FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<_FeedPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<PostData> _posts = List.from(dummyPosts);
  bool _searching = false;

  void _filter(String q) {
    setState(() {
      _searching = q.isNotEmpty;
      _posts =
          q.isEmpty
              ? List.from(dummyPosts)
              : dummyPosts
                  .where(
                    (p) =>
                        p.title.toLowerCase().contains(q.toLowerCase()) ||
                        p.category.toLowerCase().contains(q.toLowerCase()) ||
                        p.author.toLowerCase().contains(q.toLowerCase()),
                  )
                  .toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(gradient: kPrimaryGradient),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.eco_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Krishi Feed',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Discover farming insights',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: kPrimaryGradient,
          boxShadow: [
            BoxShadow(
              color: kPrimary.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showCreatePost(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
          label: const Text(
            'Post',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search
          Container(
            decoration: const BoxDecoration(
              gradient: kPrimaryGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _filter,
                style: const TextStyle(
                  color: kTextPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Search posts, topics, farmers...',
                  hintStyle: TextStyle(
                    color: kTextSecondary.withOpacity(0.5),
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 12),
                    child: Icon(
                      Icons.search_rounded,
                      color:
                          _searching
                              ? kPrimary
                              : kTextSecondary.withOpacity(0.4),
                      size: 24,
                    ),
                  ),
                  suffixIcon:
                      _searching
                          ? GestureDetector(
                            onTap: () {
                              _searchCtrl.clear();
                              _filter('');
                            },
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: kBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: kTextSecondary,
                                size: 16,
                              ),
                            ),
                          )
                          : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 4,
                  ),
                ),
              ),
            ),
          ),

          // Category chips
          Container(
            height: 56,
            margin: const EdgeInsets.only(top: 4),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _Chip(label: '✨ All', selected: true, onTap: () {}),
                _Chip(label: '🌿 Organic', onTap: () {}),
                _Chip(label: '💧 Irrigation', onTap: () {}),
                _Chip(label: '🐛 Pests', onTap: () {}),
                _Chip(label: '🌡️ Weather', onTap: () {}),
                _Chip(label: '💰 Finance', onTap: () {}),
              ],
            ),
          ),

          // Posts
          Expanded(
            child:
                _posts.isEmpty && _searching
                    ? _emptySearch()
                    : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 88),
                      itemCount: _posts.length,
                      itemBuilder:
                          (ctx, i) => _PostCard(
                            post: _posts[i],
                            onLike: () {
                              setState(() {
                                _posts[i].isLiked = !_posts[i].isLiked;
                                _posts[i].likes += _posts[i].isLiked ? 1 : -1;
                              });
                            },
                            onBookmark: () {
                              setState(() {
                                _posts[i].isBookmarked =
                                    !_posts[i].isBookmarked;
                              });
                              HapticFeedback.selectionClick();
                            },
                          ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _emptySearch() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 56,
              color: kPrimary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No posts found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try different keywords or browse categories',
            style: TextStyle(color: kTextSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () {
              _searchCtrl.clear();
              _filter('');
            },
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Clear Search'),
            style: TextButton.styleFrom(
              foregroundColor: kPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: kPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePost(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => const CreatePostScreen(),
        transitionsBuilder: (_, anim, __, child) {
          return SlideTransition(
            position: Tween(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          );
        },
      ),
    );
  }
}

// ── Feed Chip ────────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({
    required this.label,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: selected ? kPrimaryGradient : null,
            color: selected ? null : kSurface,
            borderRadius: BorderRadius.circular(24),
            border: selected ? null : Border.all(color: kDivider),
            boxShadow:
                selected
                    ? [
                      BoxShadow(
                        color: kPrimary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                    : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : kTextPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Post Card (Modern clean look) ────────────────────────────────────────────
class _PostCard extends StatelessWidget {
  final PostData post;
  final VoidCallback onLike;
  final VoidCallback onBookmark;
  const _PostCard({
    required this.post,
    required this.onLike,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final hasImg = post.imageUrl.isNotEmpty;
    return GestureDetector(
      onTap: () => _navigateToDetail(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              spreadRadius: 0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _avatarColorFor(post.author).withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: _avatarColorFor(post.author),
                      child: Text(
                        post.author[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              post.author,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: kTextPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.verified_rounded,
                              size: 14,
                              color: kInfo,
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: kTextSecondary.withOpacity(0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              post.timeAgo,
                              style: TextStyle(
                                color: kTextSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    kPrimary.withOpacity(0.1),
                                    kAccent.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                post.category,
                                style: const TextStyle(
                                  color: kPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        post.isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline_rounded,
                        key: ValueKey(post.isBookmarked),
                        color:
                            post.isBookmarked
                                ? kPrimary
                                : kTextSecondary.withOpacity(0.6),
                        size: 24,
                      ),
                    ),
                    onPressed: onBookmark,
                  ),
                ],
              ),
            ),

            // Title & description
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Text(
                post.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                  color: kTextPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            if (post.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  post.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: kTextSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),

            // Image
            if (hasImg)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    post.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: kBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: kPrimary,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
              child: Row(
                children: [
                  _ActionBtn(
                    icon:
                        post.isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                    label: post.likes.toString(),
                    color: post.isLiked ? kLikeRed : kTextSecondary,
                    onTap: onLike,
                  ),
                  _ActionBtn(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: post.comments.toString(),
                    onTap: () {},
                  ),
                  _ActionBtn(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    onTap: () {},
                  ),
                  const Spacer(),
                  _ActionBtn(
                    icon: Icons.more_horiz_rounded,
                    label: '',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ForumDetailScreen(post: post)),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: color ?? kTextSecondary.withOpacity(0.7),
              ),
              if (label.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: color ?? kTextSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Create Post Bottom Sheet ────────────────────────────────────────────────
class _CreatePostSheet extends StatefulWidget {
  const _CreatePostSheet();
  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _selectedTag = 'Organic Farming';
  final _tags = [
    'Organic Farming',
    'Irrigation',
    'Pest Management',
    'Soil Health',
    'Technology',
    'Finance',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.only(bottom: bottom),
      decoration: const BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: kDivider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Create Post',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Post title',
                filled: true,
                fillColor: kBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyCtrl,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Write something...',
                filled: true,
                fillColor: kBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Tags
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    _tags
                        .map(
                          (t) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(
                                t,
                                style: const TextStyle(fontSize: 12),
                              ),
                              selected: _selectedTag == t,
                              selectedColor: kPrimary.withOpacity(0.15),
                              labelStyle: TextStyle(
                                color:
                                    _selectedTag == t ? kPrimary : kTextPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              onSelected:
                                  (_) => setState(() => _selectedTag = t),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
            const SizedBox(height: 12),
            // Media row
            Row(
              children: [
                _mediaBtn(Icons.image, 'Photo'),
                const SizedBox(width: 12),
                _mediaBtn(Icons.videocam, 'Video'),
                const SizedBox(width: 12),
                _mediaBtn(Icons.poll, 'Poll'),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Publish',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _mediaBtn(IconData icon, String label) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: kBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: kPrimary),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 2 — CHAT
// ═══════════════════════════════════════════════════════════════════════════════
class _ChatPage extends StatefulWidget {
  const _ChatPage();
  @override
  State<_ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<_ChatPage> {
  final _searchCtrl = TextEditingController();
  List<ChatMessage> _chats = List.from(dummyChats);
  bool _searching = false;

  void _filter(String q) {
    setState(() {
      _searching = q.isNotEmpty;
      _chats =
          q.isEmpty
              ? List.from(dummyChats)
              : dummyChats
                  .where(
                    (c) =>
                        c.senderName.toLowerCase().contains(q.toLowerCase()) ||
                        c.lastMessage.toLowerCase().contains(q.toLowerCase()),
                  )
                  .toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(gradient: kPrimaryGradient),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.chat_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Messages',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      '4 unread conversations',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.edit_note_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Search
          Container(
            decoration: const BoxDecoration(
              gradient: kPrimaryGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _filter,
                style: const TextStyle(
                  color: kTextPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  hintStyle: TextStyle(
                    color: kTextSecondary.withOpacity(0.5),
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 12),
                    child: Icon(
                      Icons.search_rounded,
                      color:
                          _searching
                              ? kPrimary
                              : kTextSecondary.withOpacity(0.4),
                      size: 24,
                    ),
                  ),
                  suffixIcon:
                      _searching
                          ? GestureDetector(
                            onTap: () {
                              _searchCtrl.clear();
                              _filter('');
                            },
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: kBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: kTextSecondary,
                                size: 16,
                              ),
                            ),
                          )
                          : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 4,
                  ),
                ),
              ),
            ),
          ),

          // Online users horizontal
          Container(
            color: kSurface,
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: dummyChats.where((c) => c.isOnline).length + 1,
                itemBuilder: (ctx, i) {
                  if (i == 0) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  kPrimary.withOpacity(0.1),
                                  kAccent.withOpacity(0.1),
                                ],
                              ),
                              border: Border.all(
                                color: kPrimary.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: kPrimary,
                              size: 26,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'New',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: kTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  final online =
                      dummyChats.where((c) => c.isOnline).toList()[i - 1];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: online.avatarColor.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 26,
                                backgroundColor: online.avatarColor,
                                child: Text(
                                  online.senderName[0],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: kOnlineGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: kSurface,
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: kOnlineGreen.withOpacity(0.4),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 60,
                          child: Text(
                            online.senderName.split(' ')[0],
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: kTextPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Chat list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _chats.length,
              separatorBuilder:
                  (_, __) => Padding(
                    padding: const EdgeInsets.only(left: 80),
                    child: Divider(color: kDivider.withOpacity(0.5), height: 2),
                  ),
              itemBuilder: (ctx, i) {
                final chat = _chats[i];
                return _ChatTile(chat: chat);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ChatMessage chat;
  const _ChatTile({required this.chat});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: chat.unreadCount > 0 ? kPrimary.withOpacity(0.04) : kSurface,
        borderRadius: BorderRadius.circular(16),
        border:
            chat.unreadCount > 0
                ? Border.all(color: kPrimary.withOpacity(0.1), width: 1)
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openChat(context, chat),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: chat.avatarColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: chat.avatarColor,
                        child: Text(
                          chat.senderName[0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    if (chat.isOnline)
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: kOnlineGreen,
                            shape: BoxShape.circle,
                            border: Border.all(color: kSurface, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: kOnlineGreen.withOpacity(0.4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat.senderName,
                              style: TextStyle(
                                fontWeight:
                                    chat.unreadCount > 0
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                fontSize: 15,
                                color: kTextPrimary,
                              ),
                            ),
                          ),
                          Text(
                            chat.time,
                            style: TextStyle(
                              color:
                                  chat.unreadCount > 0
                                      ? kPrimary
                                      : kTextSecondary,
                              fontSize: 12,
                              fontWeight:
                                  chat.unreadCount > 0
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color:
                                    chat.unreadCount > 0
                                        ? kTextPrimary
                                        : kTextSecondary,
                                fontWeight:
                                    chat.unreadCount > 0
                                        ? FontWeight.w500
                                        : FontWeight.w400,
                                fontSize: 13,
                                height: 1.3,
                              ),
                            ),
                          ),
                          if (chat.unreadCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: kPrimaryGradient,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: kPrimary.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                chat.unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openChat(BuildContext context, ChatMessage chat) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _ChatDetailScreen(chat: chat)),
    );
  }
}

// ── Chat Detail (simple) ────────────────────────────────────────────────────
class _ChatDetailScreen extends StatefulWidget {
  final ChatMessage chat;
  const _ChatDetailScreen({required this.chat});
  @override
  State<_ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<_ChatDetailScreen> {
  final _msgCtrl = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hi! How are your crops doing this season?',
      'isMe': false,
      'time': '10:30 AM',
    },
    {
      'text': 'Great! The rice paddy looks excellent this year 🌾',
      'isMe': true,
      'time': '10:32 AM',
    },
    {
      'text': 'That\'s wonderful! Did you try the new fertilizer?',
      'isMe': false,
      'time': '10:33 AM',
    },
    {
      'text': 'Yes, it made a huge difference. Highly recommend it!',
      'isMe': true,
      'time': '10:35 AM',
    },
    {
      'text': 'Can you share the brand name?',
      'isMe': false,
      'time': '10:36 AM',
    },
  ];

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  void _send() {
    if (_msgCtrl.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'text': _msgCtrl.text.trim(),
        'isMe': true,
        'time': 'Now',
      });
    });
    _msgCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: widget.chat.avatarColor,
              child: Text(
                widget.chat.senderName[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chat.senderName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (widget.chat.isOnline)
                  const Text(
                    'Online',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                final msg = _messages[i];
                final isMe = msg['isMe'] as bool;
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.72,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? kPrimary : kCard,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          msg['text'] as String,
                          style: TextStyle(
                            color: isMe ? Colors.white : kTextPrimary,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg['time'] as String,
                          style: TextStyle(
                            color: isMe ? Colors.white60 : kTextSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            color: kCard,
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: kPrimary),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: kBg,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _msgCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: kPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
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
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 3 — COMMUNITY (Channels + Groups tabs)
// ═══════════════════════════════════════════════════════════════════════════════
class _CommunityPage extends StatefulWidget {
  const _CommunityPage();
  @override
  State<_CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<_CommunityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: Container(
          decoration: const BoxDecoration(gradient: kPrimaryGradient),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.groups_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Community',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Connect with fellow farmers',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.search_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () {},
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tabCtrl,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: kPrimary,
                  unselectedLabelColor: Colors.white,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  padding: const EdgeInsets.all(4),
                  tabs: const [Tab(text: 'Channels'), Tab(text: 'Groups')],
                ),
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _CommunityList(items: dummyChannels, isChannel: true),
          _CommunityList(items: dummyGroups, isChannel: false),
        ],
      ),
    );
  }
}

class _CommunityList extends StatelessWidget {
  final List<CommunityItem> items;
  final bool isChannel;
  const _CommunityList({required this.items, required this.isChannel});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      itemCount: items.length,
      itemBuilder:
          (ctx, i) => _CommunityCard(item: items[i], isChannel: isChannel),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final CommunityItem item;
  final bool isChannel;
  const _CommunityCard({required this.item, required this.isChannel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(20),
        border:
            item.isJoined
                ? Border.all(color: kPrimary.withOpacity(0.15), width: 1)
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        item.color.withOpacity(0.15),
                        item.color.withOpacity(0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: item.color.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(item.icon, color: item.color, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    item.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: kTextPrimary,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                                if (isChannel) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: kInfo.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      Icons.campaign_rounded,
                                      size: 12,
                                      color: kInfo,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: kTextSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: kBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.people_rounded,
                                  size: 12,
                                  color: kTextSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatCount(item.members),
                                  style: const TextStyle(
                                    color: kTextSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: kOnlineGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: kOnlineGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.lastActive,
                                  style: TextStyle(
                                    color: kOnlineGreen,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          item.isJoined
                              ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: kPrimary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: kPrimary.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_rounded,
                                      size: 14,
                                      color: kPrimary,
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Joined',
                                      style: TextStyle(
                                        color: kPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : Container(
                                decoration: BoxDecoration(
                                  gradient: kPrimaryGradient,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: kPrimary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(24),
                                    onTap: () {},
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 8,
                                      ),
                                      child: Text(
                                        'Join',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
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
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════════
// TAB 4 — PROFILE
// ═════════════════════════════════════════════════════════════════════════════════
class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;
        return _ProfileContent(user: user, getInitials: _getInitials);
      },
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final dynamic user;
  final String Function(String) getInitials;

  const _ProfileContent({required this.user, required this.getInitials});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: CustomScrollView(
        slivers: [
          // Profile header
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: kPrimary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: kPrimaryGradient),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      // Avatar with glow effect
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 52,
                            backgroundColor: kPrimaryDark,
                            backgroundImage:
                                user?.imageUrl != null &&
                                        user!.imageUrl!.isNotEmpty
                                    ? NetworkImage(user.imageUrl!)
                                    : null,
                            child:
                                user?.imageUrl == null ||
                                        user!.imageUrl!.isEmpty
                                    ? Text(
                                      getInitials(user?.name ?? 'KS'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 32,
                                        letterSpacing: 1,
                                      ),
                                    )
                                    : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.name ?? 'Krishi Sakhi User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 24,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.eco_rounded,
                              color: Colors.white70,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '@${user?.username ?? 'krishisakhi'} • Organic Farmer',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Stats
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _ProfileStat(count: '24', label: 'Posts'),
                            Container(
                              width: 1,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0),
                                    Colors.white.withOpacity(0.3),
                                    Colors.white.withOpacity(0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            _ProfileStat(count: '1.2k', label: 'Followers'),
                            Container(
                              width: 1,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0),
                                    Colors.white.withOpacity(0.3),
                                    Colors.white.withOpacity(0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            _ProfileStat(count: '348', label: 'Following'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Actions & Settings
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Edit profile button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: kPrimary.withOpacity(0.3),
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {},
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.edit_rounded,
                                      size: 18,
                                      color: kPrimary,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Edit Profile',
                                      style: TextStyle(
                                        color: kPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: kPrimaryGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: kPrimary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {},
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.share_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Share Profile',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // About card
                _ProfileSection(
                  title: 'About',
                  icon: Icons.info_outline_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Passionate organic farmer from Maharashtra. Growing rice, vegetables, and fruits using sustainable methods for over 15 years.',
                        style: TextStyle(
                          color: kTextSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.location_on,
                        text: 'Pune, Maharashtra',
                      ),
                      _InfoRow(
                        icon: Icons.calendar_today,
                        text: 'Joined January 2024',
                      ),
                      _InfoRow(
                        icon: Icons.agriculture_rounded,
                        text: '5 acres farmland',
                      ),
                    ],
                  ),
                ),

                // Menu items
                _ProfileSection(
                  title: 'Settings',
                  icon: Icons.settings_rounded,
                  child: Column(
                    children: [
                      _MenuItem(
                        icon: Icons.bookmark_outline_rounded,
                        label: 'Saved Posts',
                        trailing: '12',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.history_rounded,
                        label: 'Activity History',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        trailing: 'On',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.language_rounded,
                        label: 'Language',
                        trailing: 'English',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.dark_mode_outlined,
                        label: 'Dark Mode',
                        trailing: 'Off',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.help_outline_rounded,
                        label: 'Help & Support',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.info_outline_rounded,
                        label: 'About App',
                        trailing: 'v2.1.0',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                // Logout
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kLikeRed.withOpacity(0.3)),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: kLikeRed.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.logout_rounded,
                                  color: kLikeRed,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Log Out',
                                style: TextStyle(
                                  color: kLikeRed,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String count;
  final String label;
  const _ProfileStat({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData? icon;
  const _ProfileSection({required this.title, required this.child, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: kPrimary),
                ),
                const SizedBox(width: 12),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: kTextPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: kPrimary),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: kTextSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String trailing;
  final VoidCallback onTap;
  const _MenuItem({
    required this.icon,
    required this.label,
    this.trailing = '',
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: kPrimary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: kTextPrimary,
                  ),
                ),
              ),
              if (trailing.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: kBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trailing,
                    style: const TextStyle(
                      color: kTextSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: kTextSecondary.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
