import 'package:flutter/material.dart';
import 'package:krishi_sakhi/models/home_feed_models.dart';
import 'package:krishi_sakhi/screens/news_list_screen.dart';

class NewsDetailScreen extends StatelessWidget {
  const NewsDetailScreen({
    super.key,
    required this.item,
    required this.categoryInfo,
    required this.onOpenSource,
  });

  final FarmNewsItem item;
  final NewsCategoryStyle categoryInfo;
  final Future<void> Function(String url) onOpenSource;

  @override
  Widget build(BuildContext context) {
    final hasImage = item.imageUrl.trim().isNotEmpty;
    final hasSourceLink = item.sourceUrl.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text('News Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child:
                    hasImage
                        ? Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildFallbackImage();
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: categoryInfo.color.withValues(alpha: 0.08),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        )
                        : _buildFallbackImage(),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildBadge(
                  icon: categoryInfo.icon,
                  label: categoryInfo.label,
                  background: categoryInfo.color.withValues(alpha: 0.12),
                  foreground: categoryInfo.color,
                ),
                _buildBadge(
                  icon: Icons.calendar_today_rounded,
                  label: _formatDate(item.publishedAt),
                  background: Colors.white,
                  foreground: Colors.grey.shade700,
                ),
                if (item.sourceName.isNotEmpty)
                  _buildBadge(
                    icon: Icons.source_rounded,
                    label: item.sourceName,
                    background: Colors.white,
                    foreground: Colors.grey.shade700,
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 26,
                height: 1.25,
                fontWeight: FontWeight.w800,
                color: Color(0xFF173B1A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item.subtitle,
              style: TextStyle(
                fontSize: 16,
                height: 1.65,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (item.tags.isNotEmpty) ...[
              const SizedBox(height: 18),
              const Text(
                'Related tags',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF173B1A),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    item.tags
                        .map(
                          (tag) => Chip(
                            label: Text(tag),
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: categoryInfo.color.withValues(alpha: 0.18),
                            ),
                            labelStyle: TextStyle(
                              color: categoryInfo.color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                        .toList(growable: false),
              ),
            ],
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Source',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.sourceName.isNotEmpty ? item.sourceName : 'Unknown source',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF173B1A),
                    ),
                  ),
                  if (hasSourceLink) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => onOpenSource(item.sourceUrl),
                        icon: const Icon(Icons.open_in_new_rounded),
                        label: const Text('Open source link'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
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
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color background,
    required Color foreground,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: foreground.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      color: categoryInfo.color.withValues(alpha: 0.08),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(categoryInfo.icon, size: 54, color: categoryInfo.color),
            const SizedBox(height: 10),
            Text(
              'No image available',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
