import 'package:flutter/material.dart';
import 'package:krishi_sakhi/models/home_feed_models.dart';
import 'package:krishi_sakhi/services/agri_scraper_agent_service.dart';
import 'package:krishi_sakhi/services/home_feed_local_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import 'news_detail_screen.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen>
    with TickerProviderStateMixin {
  late Future<List<FarmNewsItem>> _newsFuture;
  late TabController _tabController;

  static const List<_NewsTabFilter> _filters = [
    _NewsTabFilter(label: 'All', category: null),
    _NewsTabFilter(label: 'Market Rates', category: 'market'),
    _NewsTabFilter(label: 'Loans', category: 'loan'),
    _NewsTabFilter(label: 'Schemes', category: 'policy'),
    _NewsTabFilter(label: 'General', category: 'general'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filters.length, vsync: this);
    _newsFuture = _loadNews();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<FarmNewsItem>> _loadNews() async {
    await HomeFeedLocalStorage.ensureSeedData();

    try {
      final liveNews = await AgriScraperAgentService.fetchLiveNews(limit: 60);
      if (liveNews.isNotEmpty) {
        await HomeFeedLocalStorage.saveNews(liveNews);
        liveNews.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
        return liveNews;
      }
    } catch (_) {
      // Falls back to cached/local seed data on connectivity or source failures.
    }

    final news = await HomeFeedLocalStorage.getNews();
    news.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return news;
  }

  Future<void> _refresh() async {
    setState(() {
      _newsFuture = _loadNews();
    });
    await _newsFuture;
  }

  Future<void> _openSourceLink(String url) async {
    final trimmedUrl = url.trim();
    if (trimmedUrl.isEmpty) {
      return;
    }

    final uri = Uri.tryParse(trimmedUrl);
    if (uri == null) {
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text(
          'Farm News',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(58),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.72),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              tabs: _filters
                  .map((filter) => Tab(text: filter.label))
                  .toList(growable: false),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF1F8E9), Color(0xFFE8F5E9), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<FarmNewsItem>>(
          future: _newsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 40),
                      const SizedBox(height: 10),
                      const Text(
                        'Could not load local news data.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final news = snapshot.data ?? const <FarmNewsItem>[];
            if (news.isEmpty) {
              return const Center(
                child: Text(
                  'No farm news available offline yet.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              );
            }

            return Column(
              children: [
                const SizedBox(height: 12),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      for (final filter in _filters)
                        _buildNewsList(
                          context,
                          _filterNews(news, filter.category),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNewsList(BuildContext context, List<FarmNewsItem> news) {
    if (news.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          children: [
            const SizedBox(height: 80),
            Icon(Icons.article_outlined, size: 44, color: Colors.grey.shade500),
            const SizedBox(height: 12),
            Text(
              'No news in this category yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        itemCount: news.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = news[index];
          final categoryInfo = _categoryInfo(item.category);
          final hasImage = item.imageUrl.trim().isNotEmpty;

          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => NewsDetailScreen(
                          item: item,
                          categoryInfo: categoryInfo,
                          onOpenSource: _openSourceLink,
                        ),
                  ),
                );
              },
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: categoryInfo.color.withValues(alpha: 0.2),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  categoryInfo.color.withValues(alpha: 0.18),
                                  categoryInfo.color.withValues(alpha: 0.06),
                                ],
                              ),
                            ),
                          ),
                          Icon(
                            categoryInfo.icon,
                            color: categoryInfo.color,
                            size: 24,
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: Color(0xFF1B5E20),
                                    ),
                                  ),
                                ),
                                if (hasImage) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.image_rounded,
                                    size: 18,
                                    color: Colors.grey.shade500,
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.subtitle,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (item.sourceName.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                item.sourceName,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: categoryInfo.color.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    categoryInfo.label,
                                    style: TextStyle(
                                      color: categoryInfo.color,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _formatDate(item.publishedAt),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
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
              ),
            ),
          );
        },
      ),
    );
  }

  List<FarmNewsItem> _filterNews(List<FarmNewsItem> news, String? category) {
    if (category == null) {
      return news;
    }

    if (category == 'policy') {
      return news
          .where((item) {
            final normalized = item.category.toLowerCase();
            return normalized == 'policy' || normalized == 'scheme';
          })
          .toList(growable: false);
    }

    return news
        .where((item) => item.category.toLowerCase() == category)
        .toList(growable: false);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  NewsCategoryStyle _categoryInfo(String category) {
    final normalized = category.toLowerCase();
    if (normalized == 'market') {
      return const NewsCategoryStyle(
        label: 'Market Rates',
        color: Color(0xFF2E7D32),
        icon: Icons.trending_up_rounded,
      );
    }
    if (normalized == 'loan') {
      return const NewsCategoryStyle(
        label: 'Loans',
        color: Color(0xFF1565C0),
        icon: Icons.account_balance_rounded,
      );
    }
    if (normalized == 'policy' || normalized == 'scheme') {
      return const NewsCategoryStyle(
        label: 'Schemes',
        color: Color(0xFF3949AB),
        icon: Icons.policy_outlined,
      );
    }

    return const NewsCategoryStyle(
      label: 'General',
      color: Color(0xFF6A1B9A),
      icon: Icons.newspaper_rounded,
    );
  }
}

class _NewsTabFilter {
  const _NewsTabFilter({required this.label, required this.category});

  final String label;
  final String? category;
}

class NewsCategoryStyle {
  const NewsCategoryStyle({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}
