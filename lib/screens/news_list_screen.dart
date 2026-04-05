import 'package:flutter/material.dart';
import 'package:krishi_sakhi/models/home_feed_models.dart';
import 'package:krishi_sakhi/services/agri_scraper_agent_service.dart';
import 'package:krishi_sakhi/services/home_feed_local_storage.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  late Future<List<FarmNewsItem>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = _loadNews();
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

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                itemCount: news.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = news[index];
                  final categoryInfo = _categoryInfo(item.category);

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white,
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
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: categoryInfo.color.withValues(alpha: 0.12),
                            ),
                            child: Icon(
                              categoryInfo.icon,
                              color: categoryInfo.color,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Color(0xFF1B5E20),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.subtitle,
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
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  _NewsCategoryStyle _categoryInfo(String category) {
    final normalized = category.toLowerCase();
    if (normalized == 'market') {
      return const _NewsCategoryStyle(
        label: 'Market',
        color: Color(0xFF2E7D32),
        icon: Icons.trending_up_rounded,
      );
    }
    if (normalized == 'loan') {
      return const _NewsCategoryStyle(
        label: 'Loan',
        color: Color(0xFF1565C0),
        icon: Icons.account_balance_rounded,
      );
    }
    if (normalized == 'policy' || normalized == 'scheme') {
      return const _NewsCategoryStyle(
        label: 'Policy',
        color: Color(0xFF3949AB),
        icon: Icons.policy_outlined,
      );
    }

    return const _NewsCategoryStyle(
      label: 'General',
      color: Color(0xFF6A1B9A),
      icon: Icons.newspaper_rounded,
    );
  }
}

class _NewsCategoryStyle {
  const _NewsCategoryStyle({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;
}
