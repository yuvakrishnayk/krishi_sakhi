import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

const LinearGradient kPrimaryGradient = LinearGradient(
  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────
class PostData {
  final String id;
  final String title;
  final String author;
  final String timeAgo;
  final String category;
  int likes;
  final int comments;
  bool isLiked;
  bool isBookmarked;
  final String imageUrl;
  final IconData icon;
  final String description;

  PostData({
    required this.id,
    required this.title,
    required this.author,
    required this.timeAgo,
    required this.category,
    required this.likes,
    required this.comments,
    this.isLiked = false,
    this.isBookmarked = false,
    this.imageUrl = '',
    required this.icon,
    this.description = '',
  });
}

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
  bool isJoined;
  final String lastActive;
  final bool isChannel;

  CommunityItem({
    required this.id,
    required this.name,
    required this.description,
    required this.members,
    required this.icon,
    required this.color,
    this.isJoined = false,
    this.lastActive = '',
    this.isChannel = false,
  });
}

class CallHistory {
  final String id;
  final String name;
  final String time;
  final bool isMissed;
  final bool isOutgoing;
  final Duration duration;
  final Color avatarColor;

  CallHistory({
    required this.id,
    required this.name,
    required this.time,
    this.isMissed = false,
    this.isOutgoing = false,
    required this.duration,
    required this.avatarColor,
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

List<CommunityItem> dummyChannels = [
  CommunityItem(
    id: '1',
    name: 'Organic Farmers Hub',
    description: 'Tips and tricks for chemical-free farming',
    members: 12400,
    icon: Icons.eco,
    color: Color(0xFF2E7D32),
    isJoined: true,
    lastActive: '5m ago',
    isChannel: true,
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
    isChannel: true,
  ),
  CommunityItem(
    id: '3',
    name: 'Market Prices Daily',
    description: 'Real-time mandi prices & market updates',
    members: 34500,
    icon: Icons.trending_up,
    color: Color(0xFFE65100),
    lastActive: '1h ago',
    isChannel: true,
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
    isChannel: true,
  ),
  CommunityItem(
    id: '5',
    name: 'Weather Watch',
    description: 'Hyper-local weather forecasts for farmers',
    members: 27000,
    icon: Icons.cloud,
    color: Color(0xFF00838F),
    lastActive: '10m ago',
    isChannel: true,
  ),
];

List<CommunityItem> dummyGroups = [
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

final List<CallHistory> dummyCallHistory = [
  CallHistory(
    id: '1',
    name: 'Dr. Rajesh Kumar',
    time: '2:15 PM',
    isOutgoing: true,
    duration: const Duration(minutes: 12, seconds: 45),
    avatarColor: Color(0xFF1565C0),
  ),
  CallHistory(
    id: '2',
    name: 'Priya Patel',
    time: '11:30 AM',
    duration: const Duration(minutes: 8, seconds: 20),
    avatarColor: Color(0xFF7B1FA2),
  ),
  CallHistory(
    id: '3',
    name: 'Krishi Support',
    time: 'Yesterday',
    isMissed: true,
    duration: Duration.zero,
    avatarColor: kPrimary,
  ),
  CallHistory(
    id: '4',
    name: 'Ramesh Yadav',
    time: 'Yesterday',
    isOutgoing: true,
    duration: const Duration(minutes: 5, seconds: 10),
    avatarColor: Color(0xFFD84315),
  ),
  CallHistory(
    id: '5',
    name: 'Anita Sharma',
    time: '3 days ago',
    duration: const Duration(minutes: 15, seconds: 30),
    avatarColor: Color(0xFF00838F),
  ),
  CallHistory(
    id: '6',
    name: 'Sunil Verma',
    time: '5 days ago',
    isOutgoing: true,
    duration: const Duration(minutes: 3, seconds: 5),
    avatarColor: Color(0xFF5D4037),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
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
// MAIN SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});
  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _FeedPage(),
      _ChatPage(),
      _CommunityPage(
        onChannelsChanged: (c) => setState(() => dummyChannels = c),
        onGroupsChanged: (g) => setState(() => dummyGroups = g),
      ),
      _CallsPage(),
    ];
  }

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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 32,
              offset: const Offset(0, -12),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, -4),
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
                  icon: Icons.call_outlined,
                  activeIcon: Icons.call_rounded,
                  label: 'Calls',
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
// NAV ITEM
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
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 18 : 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isActive ? kPrimary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border:
              isActive
                  ? Border.all(color: kPrimary.withOpacity(0.3), width: 1.5)
                  : null,
          boxShadow:
              isActive
                  ? [
                    BoxShadow(
                      color: kPrimary.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : [],
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
// TAB 1 — FEED
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
                      ),
                    ),
                    Text(
                      'Discover farming insights',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
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
              color: kPrimary.withOpacity(0.5),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: kPrimary.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
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
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      ),
      body: Column(
        children: [
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
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _filter,
                decoration: InputDecoration(
                  hintText: 'Search posts, topics, farmers...',
                  hintStyle: TextStyle(color: kTextSecondary.withOpacity(0.5)),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color:
                        _searching ? kPrimary : kTextSecondary.withOpacity(0.4),
                  ),
                  suffixIcon:
                      _searching
                          ? GestureDetector(
                            onTap: () {
                              _searchCtrl.clear();
                              _filter('');
                            },
                            child: const Icon(
                              Icons.close_rounded,
                              color: kTextSecondary,
                            ),
                          )
                          : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
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

  Widget _emptySearch() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: kPrimary.withOpacity(0.1),
          ),
          child: Icon(
            Icons.search_off_rounded,
            size: 48,
            color: kPrimary.withOpacity(0.7),
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
          'Try different keywords',
          style: TextStyle(color: kTextSecondary, fontSize: 14),
        ),
      ],
    ),
  );

  void _showCreatePost(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CreatePostSheet(),
    );
  }
}

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
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            gradient: selected ? kPrimaryGradient : null,
            color: selected ? null : kSurface,
            borderRadius: BorderRadius.circular(28),
            border:
                selected
                    ? null
                    : Border.all(color: kDivider.withOpacity(0.4), width: 1),
            boxShadow:
                selected
                    ? [
                      BoxShadow(
                        color: kPrimary.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ]
                    : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : kTextPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

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
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => _ForumDetailScreen(post: post)),
          ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 6),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 0),
              child: Row(
                children: [
                  CircleAvatar(
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.author,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: kTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              post.timeAgo,
                              style: TextStyle(
                                color: kTextSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: kPrimary.withOpacity(0.1),
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
                    icon: Icon(
                      post.isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_outline_rounded,
                      color: post.isBookmarked ? kPrimary : kTextSecondary,
                    ),
                    onPressed: onBookmark,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Text(
                post.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
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
                  style: TextStyle(color: kTextSecondary, fontSize: 14),
                ),
              ),
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
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            AnimatedScale(
              scale: 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                size: 20,
                color: color ?? kTextSecondary.withOpacity(0.7),
              ),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FORUM DETAIL SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class _ForumDetailScreen extends StatefulWidget {
  final PostData post;
  const _ForumDetailScreen({required this.post});
  @override
  State<_ForumDetailScreen> createState() => _ForumDetailScreenState();
}

class _ForumDetailScreenState extends State<_ForumDetailScreen> {
  final _commentCtrl = TextEditingController();
  final List<Map<String, String>> _comments = [
    {
      'author': 'FarmExpert',
      'text': 'Great post! Very informative.',
      'time': '1h ago',
    },
    {
      'author': 'GreenGrower',
      'text': 'Thanks for sharing these tips!',
      'time': '2h ago',
    },
    {
      'author': 'SoilMaster',
      'text': 'I tried this last season, works amazingly!',
      'time': '3h ago',
    },
  ];

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _addComment() {
    if (_commentCtrl.text.trim().isEmpty) return;
    setState(() {
      _comments.insert(0, {
        'author': 'You',
        'text': _commentCtrl.text.trim(),
        'time': 'Just now',
      });
    });
    _commentCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kPrimaryGradient),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Post Detail',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: _avatarColorFor(
                                widget.post.author,
                              ),
                              child: Text(
                                widget.post.author[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.post.author,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: kTextPrimary,
                                    ),
                                  ),
                                  Text(
                                    widget.post.timeAgo,
                                    style: TextStyle(
                                      color: kTextSecondary,
                                      fontSize: 12,
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
                                color: kPrimary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.post.category,
                                style: const TextStyle(
                                  color: kPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.post.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: kTextPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.post.description,
                          style: TextStyle(
                            color: kTextSecondary,
                            fontSize: 15,
                            height: 1.7,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        if (widget.post.imageUrl.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              widget.post.imageUrl,
                              width: double.infinity,
                              height: 220,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.favorite_outline_rounded,
                              size: 20,
                              color: kLikeRed,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.post.likes} likes',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 20,
                              color: kTextSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.post.comments} comments',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Comments (${_comments.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._comments.map(
                    (c) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: kSurface,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: _avatarColorFor(c['author']!),
                            child: Text(
                              c['author']![0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      c['author']!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: kTextPrimary,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      c['time']!,
                                      style: TextStyle(
                                        color: kTextSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  c['text']!,
                                  style: TextStyle(
                                    color: kTextSecondary,
                                    fontSize: 13,
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
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            color: kCard,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: kBg,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _commentCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Add a comment...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onSubmitted: (_) => _addComment(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _addComment,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: kPrimaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kPrimary.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.send_rounded,
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

// ─────────────────────────────────────────────────────────────────────────────
// CREATE POST SHEET
// ─────────────────────────────────────────────────────────────────────────────
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
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            const SizedBox(height: 16),
            Row(
              children: [
                _mediaBtn(Icons.image, 'Photo'),
                const SizedBox(width: 12),
                _mediaBtn(Icons.videocam, 'Video'),
                const SizedBox(width: 12),
                _mediaBtn(Icons.poll, 'Poll'),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Post published successfully! 🌾'),
                        backgroundColor: kPrimary,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: kPrimary.withOpacity(0.4),
                  ),
                  child: const Text(
                    'Publish',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _mediaBtn(IconData icon, String label) => InkWell(
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
                      ),
                    ),
                    Text(
                      '4 unread conversations',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
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
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _filter,
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  hintStyle: TextStyle(color: kTextSecondary.withOpacity(0.5)),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color:
                        _searching ? kPrimary : kTextSecondary.withOpacity(0.4),
                  ),
                  suffixIcon:
                      _searching
                          ? GestureDetector(
                            onTap: () {
                              _searchCtrl.clear();
                              _filter('');
                            },
                            child: const Icon(Icons.close_rounded),
                          )
                          : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
          // Online users
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
                            CircleAvatar(
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
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _chats.length,
              separatorBuilder:
                  (_, __) => Padding(
                    padding: const EdgeInsets.only(left: 80),
                    child: Divider(color: kDivider.withOpacity(0.5), height: 2),
                  ),
              itemBuilder: (ctx, i) => _ChatTile(chat: _chats[i]),
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
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: chat.unreadCount > 0 ? kPrimary.withOpacity(0.06) : kSurface,
        borderRadius: BorderRadius.circular(18),
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
          borderRadius: BorderRadius.circular(18),
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _ChatDetailScreen(chat: chat),
                ),
              ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
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
                                fontSize: 13,
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
}

// ─────────────────────────────────────────────────────────────────────────────
// CHAT DETAIL
// ─────────────────────────────────────────────────────────────────────────────
class _ChatDetailScreen extends StatefulWidget {
  final ChatMessage chat;
  const _ChatDetailScreen({required this.chat});
  @override
  State<_ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<_ChatDetailScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
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
    _scrollCtrl.dispose();
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
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kPrimaryGradient),
        ),
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
                    letterSpacing: -0.3,
                  ),
                ),
                if (widget.chat.isOnline)
                  const Text(
                    'Online',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => _ActiveCallScreen(
                          name: widget.chat.senderName,
                          avatarColor: widget.chat.avatarColor,
                          isVideo: false,
                        ),
                  ),
                ),
          ),
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.white),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => _ActiveCallScreen(
                          name: widget.chat.senderName,
                          avatarColor: widget.chat.avatarColor,
                          isVideo: true,
                        ),
                  ),
                ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
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
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: kDivider.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
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
                      decoration: BoxDecoration(
                        gradient: kPrimaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: kPrimary.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.send_rounded,
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
// TAB 3 — COMMUNITY
// ═══════════════════════════════════════════════════════════════════════════════
class _CommunityPage extends StatefulWidget {
  final Function(List<CommunityItem>) onChannelsChanged;
  final Function(List<CommunityItem>) onGroupsChanged;

  const _CommunityPage({
    required this.onChannelsChanged,
    required this.onGroupsChanged,
  });

  @override
  State<_CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<_CommunityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<CommunityItem> _channels = List.from(dummyChannels);
  List<CommunityItem> _groups = List.from(dummyGroups);

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

  void _toggleJoinChannel(int index) {
    setState(() {
      _channels[index].isJoined = !_channels[index].isJoined;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _channels[index].isJoined
              ? 'Joined ${_channels[index].name}! 🎉'
              : 'Left ${_channels[index].name}',
        ),
        backgroundColor: kPrimary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleJoinGroup(int index) {
    setState(() {
      _groups[index].isJoined = !_groups[index].isJoined;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _groups[index].isJoined
              ? 'Joined ${_groups[index].name}! 🎉'
              : 'Left ${_groups[index].name}',
        ),
        backgroundColor: kPrimary,
        duration: const Duration(seconds: 2),
      ),
    );
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
                      ),
                    ),
                    Text(
                      'Connect with fellow farmers',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
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
                  onPressed: () {
                    final isChannels = _tabCtrl.index == 0;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => CreateGroupScreen(
                              isChannel: isChannels,
                              onCreated: (item) {
                                setState(() {
                                  if (isChannels) {
                                    _channels.insert(0, item);
                                  } else {
                                    _groups.insert(0, item);
                                  }
                                });
                              },
                            ),
                      ),
                    );
                  },
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
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
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
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            itemCount: _channels.length,
            itemBuilder:
                (ctx, i) => _CommunityCard(
                  item: _channels[i],
                  isChannel: true,
                  onJoinToggle: () => _toggleJoinChannel(i),
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => CommunityDetailScreen(
                                item: _channels[i],
                                isChannel: true,
                              ),
                        ),
                      ),
                ),
          ),
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            itemCount: _groups.length,
            itemBuilder:
                (ctx, i) => _CommunityCard(
                  item: _groups[i],
                  isChannel: false,
                  onJoinToggle: () => _toggleJoinGroup(i),
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => CommunityDetailScreen(
                                item: _groups[i],
                                isChannel: false,
                              ),
                        ),
                      ),
                ),
          ),
        ],
      ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final CommunityItem item;
  final bool isChannel;
  final VoidCallback onJoinToggle;
  final VoidCallback onTap;

  const _CommunityCard({
    required this.item,
    required this.isChannel,
    required this.onJoinToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(24),
        border:
            item.isJoined
                ? Border.all(color: kPrimary.withOpacity(0.15), width: 1.5)
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.12),
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
                          Flexible(
                            child: Text(
                              item.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: kTextPrimary,
                              ),
                            ),
                          ),
                          if (isChannel) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.campaign_rounded,
                              size: 14,
                              color: kInfo,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: kTextSecondary, fontSize: 13),
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
                          if (item.lastActive.isNotEmpty)
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
                                    style: const TextStyle(
                                      color: kOnlineGreen,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const Spacer(),
                          GestureDetector(
                            onTap: onJoinToggle,
                            child:
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
                                        children: const [
                                          Icon(
                                            Icons.check_rounded,
                                            size: 14,
                                            color: kPrimary,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
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
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 8,
                                      ),
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
                                      child: const Text(
                                        'Join',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
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

// ─────────────────────────────────────────────────────────────────────────────
// COMMUNITY DETAIL SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class CommunityDetailScreen extends StatefulWidget {
  final CommunityItem item;
  final bool isChannel;
  const CommunityDetailScreen({
    super.key,
    required this.item,
    required this.isChannel,
  });
  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  bool _isJoined = false;
  final _msgCtrl = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'author': 'Admin',
      'text': 'Welcome to the community! 🌱',
      'time': '9:00 AM',
    },
    {
      'author': 'FarmGuru',
      'text': 'Great to be here! Any updates on irrigation tips?',
      'time': '9:15 AM',
    },
    {
      'author': 'GreenFarmer',
      'text': 'Check out the latest post on drip irrigation!',
      'time': '9:30 AM',
    },
    {
      'author': 'SoilExpert',
      'text': 'I just tested organic compost — amazing results 🌿',
      'time': '10:00 AM',
    },
  ];

  @override
  void initState() {
    super.initState();
    _isJoined = widget.item.isJoined;
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_msgCtrl.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'author': 'You',
        'text': _msgCtrl.text.trim(),
        'time': 'Now',
      });
    });
    _msgCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: NestedScrollView(
        headerSliverBuilder:
            (ctx, inner) => [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(gradient: kPrimaryGradient),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            widget.item.icon,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.item.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatCount(widget.item.members)} members • ${widget.item.lastActive}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(48),
                  child: Container(
                    color: kPrimaryDark,
                    child: TabBar(
                      controller: _tabCtrl,
                      indicatorColor: Colors.white,
                      indicatorWeight: 3,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white60,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                      tabs: const [Tab(text: 'Chat'), Tab(text: 'About')],
                    ),
                  ),
                ),
              ),
            ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            // Chat tab
            Column(
              children: [
                if (!_isJoined)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kPrimary.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          color: kPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Join this community to participate in discussions',
                            style: TextStyle(
                              color: kPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() => _isJoined = true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Joined ${widget.item.name}! 🎉'),
                                backgroundColor: kPrimary,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: kPrimaryGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Join',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (ctx, i) {
                      final msg = _messages[i];
                      final isMe = msg['author'] == 'You';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment:
                              isMe
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                          children: [
                            if (!isMe) ...[
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: _avatarColorFor(
                                  msg['author']!,
                                ),
                                child: Text(
                                  msg['author']![0],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Column(
                                crossAxisAlignment:
                                    isMe
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                children: [
                                  if (!isMe)
                                    Text(
                                      msg['author']!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: kTextPrimary,
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isMe ? kPrimary : kSurface,
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(16),
                                        topRight: const Radius.circular(16),
                                        bottomLeft: Radius.circular(
                                          isMe ? 16 : 4,
                                        ),
                                        bottomRight: Radius.circular(
                                          isMe ? 4 : 16,
                                        ),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      msg['text']!,
                                      style: TextStyle(
                                        color:
                                            isMe ? Colors.white : kTextPrimary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    msg['time']!,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: kTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (_isJoined)
                  Container(
                    padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                    color: kCard,
                    child: SafeArea(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: kBg,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: TextField(
                                controller: _msgCtrl,
                                decoration: const InputDecoration(
                                  hintText: 'Message community...',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                ),
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _sendMessage,
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
            // About tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _aboutSection(
                    'About',
                    widget.item.description +
                        '\n\nThis is an active community where farmers share knowledge, tips, and support each other in achieving better crop yields and sustainable practices.',
                  ),
                  const SizedBox(height: 16),
                  _aboutSection(
                    'Members',
                    '${_formatCount(widget.item.members)} active members from across India',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Community Rules',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: kTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...[
                          '1. Be respectful to all members',
                          '2. Share only farming-related content',
                          '3. No spam or promotional content',
                          '4. Verify information before sharing',
                          '5. Help and support fellow farmers',
                        ].map(
                          (rule) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 16,
                                  color: kPrimary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  rule,
                                  style: TextStyle(
                                    color: kTextSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!_isJoined)
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: kPrimaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: kPrimary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => _isJoined = true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Joined ${widget.item.name}! 🎉'),
                                backgroundColor: kPrimary,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Join ${widget.isChannel ? 'Channel' : 'Group'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _aboutSection(String title, String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(color: kTextSecondary, fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CREATE GROUP / CHANNEL SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class CreateGroupScreen extends StatefulWidget {
  final bool isChannel;
  final Function(CommunityItem) onCreated;

  const CreateGroupScreen({
    super.key,
    required this.isChannel,
    required this.onCreated,
  });

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  IconData _selectedIcon = Icons.eco;
  Color _selectedColor = kPrimary;
  bool _isPublic = true;
  bool _isLoading = false;

  final List<IconData> _icons = [
    Icons.eco,
    Icons.water_drop,
    Icons.trending_up,
    Icons.warning_amber,
    Icons.cloud,
    Icons.grass,
    Icons.local_florist,
    Icons.pets,
    Icons.rocket_launch,
    Icons.female,
    Icons.terrain,
    Icons.bug_report,
    Icons.account_balance,
    Icons.agriculture,
    Icons.spa,
    Icons.park,
  ];

  final List<Color> _colors = [
    const Color(0xFF2E7D32),
    const Color(0xFF1565C0),
    const Color(0xFFE65100),
    const Color(0xFFC62828),
    const Color(0xFF00838F),
    const Color(0xFF33691E),
    const Color(0xFF7B1FA2),
    const Color(0xFF5D4037),
    const Color(0xFFFF6F00),
    const Color(0xFFAD1457),
    const Color(0xFF00695C),
    const Color(0xFF283593),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _create() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));

    final newItem = CommunityItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      description:
          _descCtrl.text.trim().isNotEmpty
              ? _descCtrl.text.trim()
              : 'A new ${widget.isChannel ? 'channel' : 'group'} for farmers',
      members: 1,
      icon: _selectedIcon,
      color: _selectedColor,
      isJoined: true,
      lastActive: 'Just now',
      isChannel: widget.isChannel,
    );

    widget.onCreated(newItem);
    setState(() => _isLoading = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.isChannel ? 'Channel' : 'Group'} "${newItem.name}" created! 🎉',
        ),
        backgroundColor: kPrimary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kPrimaryGradient),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create ${widget.isChannel ? 'Channel' : 'Group'}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _selectedColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: _selectedColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(_selectedIcon, color: _selectedColor, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nameCtrl.text.isEmpty
                              ? '${widget.isChannel ? 'Channel' : 'Group'} Name'
                              : _nameCtrl.text,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color:
                                _nameCtrl.text.isEmpty
                                    ? kTextSecondary
                                    : kTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _descCtrl.text.isEmpty
                              ? 'Description...'
                              : _descCtrl.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: kTextSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              _isPublic
                                  ? Icons.public_rounded
                                  : Icons.lock_outline_rounded,
                              size: 13,
                              color: kPrimary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isPublic ? 'Public' : 'Private',
                              style: const TextStyle(
                                color: kPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.people_rounded,
                              size: 13,
                              color: kTextSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '1 member',
                              style: TextStyle(
                                color: kTextSecondary,
                                fontSize: 12,
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

            const SizedBox(height: 24),

            // Name field
            _sectionLabel('${widget.isChannel ? 'Channel' : 'Group'} Name *'),
            const SizedBox(height: 8),
            _inputField(
              controller: _nameCtrl,
              hint: 'e.g. Organic Wheat Growers',
              icon: Icons.title_rounded,
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 20),

            // Description field
            _sectionLabel('Description'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: TextField(
                controller: _descCtrl,
                maxLines: 3,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Describe what this community is about...',
                  hintStyle: TextStyle(
                    color: kTextSecondary.withOpacity(0.6),
                    fontSize: 14,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 50,
                      left: 12,
                      right: 8,
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      color: kPrimary.withOpacity(0.7),
                      size: 20,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: kSurface,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Icon picker
            _sectionLabel('Choose Icon'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: _icons.length,
                itemBuilder: (ctx, i) {
                  final isSelected = _icons[i] == _selectedIcon;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = _icons[i]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? _selectedColor.withOpacity(0.15) : kBg,
                        borderRadius: BorderRadius.circular(10),
                        border:
                            isSelected
                                ? Border.all(color: _selectedColor, width: 2)
                                : null,
                      ),
                      child: Icon(
                        _icons[i],
                        color: isSelected ? _selectedColor : kTextSecondary,
                        size: 22,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Color picker
            _sectionLabel('Choose Color'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: _colors.length,
                itemBuilder: (ctx, i) {
                  final isSelected = _colors[i] == _selectedColor;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = _colors[i]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: _colors[i],
                        shape: BoxShape.circle,
                        border:
                            isSelected
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                        boxShadow:
                            isSelected
                                ? [
                                  BoxShadow(
                                    color: _colors[i].withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                                : [],
                      ),
                      child:
                          isSelected
                              ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 20,
                              )
                              : null,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Privacy toggle
            _sectionLabel('Privacy'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _privacyOption(
                    icon: Icons.public_rounded,
                    title: 'Public',
                    subtitle: 'Anyone can find and join',
                    selected: _isPublic,
                    onTap: () => setState(() => _isPublic = true),
                  ),
                  Divider(
                    height: 1,
                    color: kDivider,
                    indent: 16,
                    endIndent: 16,
                  ),
                  _privacyOption(
                    icon: Icons.lock_outline_rounded,
                    title: 'Private',
                    subtitle: 'Only invited members can join',
                    selected: !_isPublic,
                    onTap: () => setState(() => _isPublic = false),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Create button
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: kPrimaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimary.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _create,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.isChannel
                                    ? Icons.campaign_rounded
                                    : Icons.groups_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Create ${widget.isChannel ? 'Channel' : 'Group'}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 16,
      color: kTextPrimary,
    ),
  );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: kTextPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: kTextSecondary.withOpacity(0.6),
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: kPrimary.withOpacity(0.7), size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: kSurface,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  Widget _privacyOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected ? kPrimary.withOpacity(0.12) : kBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: selected ? kPrimary : kTextSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: selected ? kPrimary : kTextPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: kTextSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? kPrimary : kDivider,
                  width: 2,
                ),
                color: selected ? kPrimary : Colors.transparent,
              ),
              child:
                  selected
                      ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 14,
                      )
                      : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 4 — CALLS
// ═══════════════════════════════════════════════════════════════════════════════
class _CallsPage extends StatefulWidget {
  const _CallsPage();
  @override
  State<_CallsPage> createState() => _CallsPageState();
}

class _CallsPageState extends State<_CallsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  List<CallHistory> _calls = List.from(dummyCallHistory);
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _filter(String q) {
    setState(() {
      _searching = q.isNotEmpty;
      _calls =
          q.isEmpty
              ? List.from(dummyCallHistory)
              : dummyCallHistory
                  .where((c) => c.name.toLowerCase().contains(q.toLowerCase()))
                  .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final missed = _calls.where((c) => c.isMissed).toList();

    return Scaffold(
      backgroundColor: kBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: Container(
          decoration: const BoxDecoration(gradient: kPrimaryGradient),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.call_rounded,
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
                      'Calls',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      'Your call history',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
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
                    Icons.person_add_outlined,
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
                    Icons.add_call,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () => _showNewCallDialog(context),
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
                  tabs: [
                    const Tab(text: 'All'),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Missed'),
                          if (missed.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: kWarning,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                missed.length.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
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
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _filter,
                decoration: InputDecoration(
                  hintText: 'Search contacts...',
                  hintStyle: TextStyle(color: kTextSecondary.withOpacity(0.5)),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color:
                        _searching ? kPrimary : kTextSecondary.withOpacity(0.4),
                  ),
                  suffixIcon:
                      _searching
                          ? GestureDetector(
                            onTap: () {
                              _searchCtrl.clear();
                              _filter('');
                            },
                            child: const Icon(Icons.close_rounded),
                          )
                          : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [_callsList(_calls), _callsList(missed)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _callsList(List<CallHistory> calls) {
    if (calls.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimary.withOpacity(0.1),
              ),
              child: Icon(
                Icons.call_outlined,
                size: 48,
                color: kPrimary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No calls',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your call history will appear here',
              style: TextStyle(color: kTextSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: calls.length,
      itemBuilder:
          (ctx, i) => _CallTile(
            call: calls[i],
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => _ActiveCallScreen(
                          name: calls[i].name,
                          avatarColor: calls[i].avatarColor,
                          isVideo: false,
                        ),
                  ),
                ),
          ),
    );
  }

  void _showNewCallDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Container(
            decoration: const BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: kDivider,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'New Call',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                ...dummyChats
                    .take(5)
                    .map(
                      (c) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: c.avatarColor,
                          child: Text(
                            c.senderName[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          c.senderName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          c.isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            color: c.isOnline ? kOnlineGreen : kTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.call_rounded,
                                color: kPrimary,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => _ActiveCallScreen(
                                          name: c.senderName,
                                          avatarColor: c.avatarColor,
                                          isVideo: false,
                                        ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.videocam_rounded,
                                color: kInfo,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => _ActiveCallScreen(
                                          name: c.senderName,
                                          avatarColor: c.avatarColor,
                                          isVideo: true,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }
}

class _CallTile extends StatelessWidget {
  final CallHistory call;
  final VoidCallback onTap;
  const _CallTile({required this.call, required this.onTap});

  String _formatDuration(Duration duration) {
    if (duration.inSeconds == 0) return '';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes == 0) return '${seconds}s';
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: call.isMissed ? kWarning.withOpacity(0.05) : kSurface,
        borderRadius: BorderRadius.circular(16),
        border:
            call.isMissed
                ? Border.all(color: kWarning.withOpacity(0.2), width: 1)
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
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: call.avatarColor,
                  child: Text(
                    call.name[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (call.isMissed)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(
                                Icons.call_missed_rounded,
                                size: 14,
                                color: kWarning,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              call.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: call.isMissed ? kWarning : kTextPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            call.isOutgoing
                                ? Icons.call_made_rounded
                                : Icons.call_received_rounded,
                            size: 12,
                            color: kTextSecondary.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${call.isOutgoing ? 'Outgoing' : 'Incoming'} • ${call.time}',
                            style: TextStyle(
                              fontSize: 12,
                              color: kTextSecondary.withOpacity(0.7),
                            ),
                          ),
                          if (call.duration.inSeconds > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              '• ${_formatDuration(call.duration)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: kTextSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.call_rounded,
                        color: kPrimary,
                        size: 22,
                      ),
                      onPressed: onTap,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.videocam_rounded,
                        color: kInfo,
                        size: 22,
                      ),
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => _ActiveCallScreen(
                                    name: call.name,
                                    avatarColor: call.avatarColor,
                                    isVideo: true,
                                  ),
                            ),
                          ),
                    ),
                  ],
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
// ACTIVE CALL SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class _ActiveCallScreen extends StatefulWidget {
  final String name;
  final Color avatarColor;
  final bool isVideo;
  const _ActiveCallScreen({
    required this.name,
    required this.avatarColor,
    required this.isVideo,
  });
  @override
  State<_ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends State<_ActiveCallScreen>
    with SingleTickerProviderStateMixin {
  bool _isMuted = false;
  bool _isSpeaker = false;
  bool _isVideoOff = false;
  bool _isConnected = false;
  int _seconds = 0;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // Simulate connecting
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isConnected = true);
        _startTimer();
      }
    });
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_isConnected) return false;
      setState(() => _seconds++);
      return true;
    });
  }

  String get _timerText {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: kPrimaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      widget.isVideo ? 'Video Call' : 'Voice Call',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.more_horiz_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Avatar + name
              ScaleTransition(
                scale: _pulseAnim,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.avatarColor,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                      BoxShadow(
                        color: widget.avatarColor.withOpacity(0.5),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Text(
                    widget.name[0].toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 52,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child:
                    _isConnected
                        ? Container(
                          key: const ValueKey('connected'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: kOnlineGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _timerText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        )
                        : Container(
                          key: const ValueKey('connecting'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Connecting...',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
              ),

              const Spacer(),

              // Controls
              if (widget.isVideo)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _callBtn(
                        icon:
                            _isVideoOff
                                ? Icons.videocam_off_rounded
                                : Icons.videocam_rounded,
                        label: _isVideoOff ? 'Camera Off' : 'Camera On',
                        active: !_isVideoOff,
                        onTap: () => setState(() => _isVideoOff = !_isVideoOff),
                      ),
                    ],
                  ),
                ),

              Container(
                margin: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _callBtn(
                      icon:
                          _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                      label: _isMuted ? 'Unmute' : 'Mute',
                      active: !_isMuted,
                      onTap: () => setState(() => _isMuted = !_isMuted),
                    ),
                    // End Call
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.heavyImpact();
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: kLikeRed,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: kLikeRed.withOpacity(0.6),
                              blurRadius: 24,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.call_end_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    _callBtn(
                      icon:
                          _isSpeaker
                              ? Icons.volume_up_rounded
                              : Icons.volume_down_rounded,
                      label: _isSpeaker ? 'Speaker' : 'Earpiece',
                      active: _isSpeaker,
                      onTap: () => setState(() => _isSpeaker = !_isSpeaker),
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

  Widget _callBtn({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color:
                  active
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: active ? Colors.white : Colors.white60,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
