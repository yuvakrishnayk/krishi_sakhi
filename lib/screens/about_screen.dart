import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// -------------------------------------------------------------
// ABOUT SCREEN — Krishi Sakhi
// Rich, animated about page with image preview & founder details
// -------------------------------------------------------------

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _staggerController;
  late Animation<double> _heroScale;
  late Animation<double> _heroOpacity;

  // All images used in the page — tap any to preview
  final List<_GalleryItem> _gallery = [
    _GalleryItem(
      url:
          'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=800&auto=format&fit=crop',
      label: 'Our Farms',
    ),
    _GalleryItem(
      url:
          'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=800&auto=format&fit=crop',
      label: 'Technology & Agriculture',
    ),
    _GalleryItem(
      url:
          'https://images.unsplash.com/photo-1574943320219-553eb213f72d?w=800&auto=format&fit=crop',
      label: 'Smart Farming',
    ),
    _GalleryItem(
      url:
          'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800&auto=format&fit=crop',
      label: 'Sustainable Growth',
    ),
    _GalleryItem(
      url:
          'https://images.unsplash.com/photo-1536183922588-166604504d5e?w=800&auto=format&fit=crop',
      label: 'Innovation Lab',
    ),
    _GalleryItem(
      url:
          'https://images.unsplash.com/photo-1495107334309-fcf20504a5ab?w=800&auto=format&fit=crop',
      label: 'Rural Connect',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _heroScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.elasticOut),
    );
    _heroOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _heroController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _heroController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _staggerController.forward();
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  void _openImagePreview(BuildContext context, String imageUrl, String label) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black87,
        pageBuilder:
            (_, __, ___) =>
                _ImagePreviewScreen(imageUrl: imageUrl, label: label),
        transitionsBuilder:
            (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F0),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8),
              ],
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Color(0xFF1B5E20),
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ── Hero Banner ──────────────────────────────────────────
            _HeroBanner(
              heroScale: _heroScale,
              heroOpacity: _heroOpacity,
              onTapBanner:
                  () => _openImagePreview(
                    context,
                    'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=1200&auto=format&fit=crop',
                    'Krishi Sakhi — Fields of Tomorrow',
                  ),
            ),

            // ── App Tagline ──────────────────────────────────────────
            _AnimatedSection(
              controller: _staggerController,
              interval: const Interval(0.0, 0.4),
              child: _AppTaglineCard(),
            ),

            const SizedBox(height: 8),

            // ── Founder Spotlight ────────────────────────────────────
            _AnimatedSection(
              controller: _staggerController,
              interval: const Interval(0.15, 0.55),
              child: _FounderSpotlight(
                onImageTap:
                    () => _openImagePreview(
                      context,
                      'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=800&auto=format&fit=crop',
                      'Dr. Pranov JB — Founder & CEO',
                    ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Mission & Vision ─────────────────────────────────────
            _AnimatedSection(
              controller: _staggerController,
              interval: const Interval(0.25, 0.65),
              child: const _MissionVisionCard(),
            ),

            const SizedBox(height: 8),

            // ── Key Stats ────────────────────────────────────────────
            _AnimatedSection(
              controller: _staggerController,
              interval: const Interval(0.35, 0.75),
              child: const _StatsRow(),
            ),

            const SizedBox(height: 8),

            // ── Technology Stack ─────────────────────────────────────
            _AnimatedSection(
              controller: _staggerController,
              interval: const Interval(0.4, 0.8),
              child: const _TechStackCard(),
            ),

            const SizedBox(height: 8),

            // ── Photo Gallery ────────────────────────────────────────
            _AnimatedSection(
              controller: _staggerController,
              interval: const Interval(0.5, 0.9),
              child: _PhotoGallery(
                items: _gallery,
                onImageTap:
                    (item) => _openImagePreview(context, item.url, item.label),
              ),
            ),

            const SizedBox(height: 8),

            // ── Timeline ─────────────────────────────────────────────
            _AnimatedSection(
              controller: _staggerController,
              interval: const Interval(0.6, 1.0),
              child: const _TimelineCard(),
            ),

            const SizedBox(height: 8),

            // ── Awards & Recognition ─────────────────────────────────
            _AnimatedSection(
              controller: _staggerController,
              interval: const Interval(0.7, 1.0),
              child: const _AwardsCard(),
            ),

            const SizedBox(height: 8),

            // ── Core Team ────────────────────────────────────────────
            _AnimatedSection(
              controller: _staggerController,
              interval: const Interval(0.75, 1.0),
              child: _CoreTeamCard(
                onImageTap:
                    (url, label) => _openImagePreview(context, url, label),
              ),
            ),

            const SizedBox(height: 8),

            // ── Contact & Social ─────────────────────────────────────
            _AnimatedSection(
              controller: _staggerController,
              interval: const Interval(0.85, 1.0),
              child: const _ContactCard(),
            ),

            const SizedBox(height: 40),

            // ── Footer ───────────────────────────────────────────────
            _AnimatedSection(
              controller: _staggerController,
              interval: const Interval(0.9, 1.0),
              child: const _FooterWidget(),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated section wrapper
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedSection extends StatelessWidget {
  final AnimationController controller;
  final Interval interval;
  final Widget child;
  const _AnimatedSection({
    required this.controller,
    required this.interval,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final anim = CurvedAnimation(parent: controller, curve: interval);
        final opacity =
            Tween<double>(begin: 0, end: 1)
                .animate(CurvedAnimation(parent: controller, curve: interval))
                .value;
        final offset =
            Tween<double>(begin: 30, end: 0)
                .animate(
                  CurvedAnimation(
                    parent: controller,
                    curve:
                        CurvedAnimation(
                          parent: controller,
                          curve: interval,
                        ).curve,
                  ),
                )
                .value;
        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, offset.clamp(0.0, 30.0)),
            child: child,
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Banner
// ─────────────────────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final Animation<double> heroScale;
  final Animation<double> heroOpacity;
  final VoidCallback onTapBanner;
  const _HeroBanner({
    required this.heroScale,
    required this.heroOpacity,
    required this.onTapBanner,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: heroScale,
      builder: (_, __) {
        return Opacity(
          opacity: heroOpacity.value,
          child: GestureDetector(
            onTap: onTapBanner,
            child: Stack(
              children: [
                // Background image
                SizedBox(
                  height: 320,
                  width: double.infinity,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=1200&auto=format&fit=crop',
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: const Color(0xFF2E7D32),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
                // Gradient overlay
                Container(
                  height: 320,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.25),
                        const Color(0xFF1B5E20).withOpacity(0.85),
                      ],
                    ),
                  ),
                ),
                // Tap hint
                Positioned(
                  top: 90,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.zoom_in, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Tap to expand',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
                // Logo + Title
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Transform.scale(
                    scale: heroScale.value,
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.eco_rounded,
                            size: 44,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'KRISHI SAKHI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'by Pranov Technologies Pvt. Ltd.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App Tagline Card
// ─────────────────────────────────────────────────────────────────────────────

class _AppTaglineCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PillBadge(label: 'v2.4.1', color: const Color(0xFF43A047)),
              const SizedBox(width: 8),
              _PillBadge(
                label: 'Agriculture Tech',
                color: const Color(0xFF1565C0),
              ),
              const SizedBox(width: 8),
              _PillBadge(
                label: 'Made in India 🇮🇳',
                color: const Color(0xFFE65100),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '"Bridging the gap between farmers\nand the digital world"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B5E20),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Krishi Sakhi is a comprehensive mobile platform designed to '
            'empower Indian farmers with AI-powered crop advisory, weather '
            'intelligence, market prices, and government scheme notifications — '
            'all in their native language.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Founder Spotlight
// ─────────────────────────────────────────────────────────────────────────────

class _FounderSpotlight extends StatelessWidget {
  final VoidCallback onImageTap;
  const _FounderSpotlight({required this.onImageTap});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(
            title: 'Founder & CEO',
            icon: Icons.person_pin_rounded,
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tappable profile photo
              GestureDetector(
                onTap: onImageTap,
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2E7D32).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=400&auto=format&fit=crop',
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.zoom_in,
                          color: Color(0xFF2E7D32),
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dr. Pranov JB',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Founder & CEO\nPranov Technologies Pvt. Ltd.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: const [
                        _SmallChip(label: 'AgriTech', icon: Icons.agriculture),
                        _SmallChip(label: 'AI/ML', icon: Icons.psychology),
                        _SmallChip(label: 'IoT', icon: Icons.sensors),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Bio
          _InfoBlock(
            icon: Icons.format_quote,
            text:
                '"Technology should serve the farmer, not intimidate him. '
                'Krishi Sakhi was born from a single question — why should a farmer '
                'in rural Kerala not have the same access to information as an '
                'urban entrepreneur?"',
            isQuote: true,
          ),
          const SizedBox(height: 14),

          _InfoBlock(
            icon: Icons.school_rounded,
            text:
                'Dr. Pranov JB holds a Ph.D in Agricultural Informatics from the '
                'University of Agricultural Sciences, Bangalore, and a Post-Doctoral '
                'fellowship from IIT Madras in Precision Farming Technologies.',
          ),
          const SizedBox(height: 12),

          _InfoBlock(
            icon: Icons.work_history_rounded,
            text:
                'With over 14 years of experience across agri-tech startups, government '
                'advisory roles, and academic research, Dr. Pranov leads Pranov Technologies '
                'with a vision to digitize India\'s 140 million farming households by 2030.',
          ),
          const SizedBox(height: 12),

          _InfoBlock(
            icon: Icons.emoji_events_rounded,
            text:
                'Recipient of the National Agri Innovation Award (2021), Forbes India '
                '30 Under 40 — AgriTech Edition (2022), and the CII Digital India '
                'Changemaker Award (2023).',
          ),
          const SizedBox(height: 12),

          _InfoBlock(
            icon: Icons.language_rounded,
            text:
                'Fluent in Malayalam, Tamil, Kannada, Hindi, and English. '
                'Passionate about multilingual accessibility and vernacular AI interfaces.',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mission & Vision
// ─────────────────────────────────────────────────────────────────────────────

class _MissionVisionCard extends StatelessWidget {
  const _MissionVisionCard();

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(title: 'Mission & Vision', icon: Icons.flag_rounded),
          const SizedBox(height: 16),
          _MVTile(
            icon: Icons.rocket_launch_rounded,
            color: const Color(0xFF1565C0),
            title: 'Our Mission',
            body:
                'To democratize agricultural knowledge by delivering AI-driven, '
                'multilingual, and affordable digital tools to every farmer in India '
                '— regardless of literacy, connectivity, or device capability.',
          ),
          const SizedBox(height: 12),
          _MVTile(
            icon: Icons.remove_red_eye_rounded,
            color: const Color(0xFF6A1B9A),
            title: 'Our Vision',
            body:
                'A future where every Indian farmer makes data-informed decisions, '
                'earns fair market value for their produce, and has zero dependency '
                'on exploitative intermediaries.',
          ),
          const SizedBox(height: 12),
          _MVTile(
            icon: Icons.favorite_rounded,
            color: const Color(0xFFC62828),
            title: 'Our Values',
            body:
                'Farmer-first design • Radical simplicity • Regional language pride • '
                'Transparency • Open data advocacy • Sustainable agriculture.',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats Row
// ─────────────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _StatBubble(
            value: '2M+',
            label: 'Farmers\nServed',
            color: const Color(0xFF2E7D32),
          ),
          const SizedBox(width: 8),
          _StatBubble(
            value: '18',
            label: 'States\nCovered',
            color: const Color(0xFF1565C0),
          ),
          const SizedBox(width: 8),
          _StatBubble(
            value: '11',
            label: 'Languages\nSupported',
            color: const Color(0xFF6A1B9A),
          ),
          const SizedBox(width: 8),
          _StatBubble(
            value: '4.8★',
            label: 'Play Store\nRating',
            color: const Color(0xFFE65100),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Technology Stack
// ─────────────────────────────────────────────────────────────────────────────

class _TechStackCard extends StatelessWidget {
  const _TechStackCard();

  @override
  Widget build(BuildContext context) {
    final techs = [
      _Tech('Flutter', Icons.phone_android, const Color(0xFF0288D1)),
      _Tech('Firebase', Icons.local_fire_department, const Color(0xFFFB8C00)),
      _Tech('Python AI', Icons.psychology, const Color(0xFF4CAF50)),
      _Tech('TensorFlow', Icons.memory, const Color(0xFFFF7043)),
      _Tech('REST API', Icons.api, const Color(0xFF7B1FA2)),
      _Tech('Google Maps', Icons.map_rounded, const Color(0xFF1976D2)),
    ];
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(
            title: 'Technology Stack',
            icon: Icons.developer_board_rounded,
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
            children:
                techs
                    .map(
                      (t) => Container(
                        decoration: BoxDecoration(
                          color: t.color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: t.color.withOpacity(0.25),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(t.icon, color: t.color, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              t.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: t.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Photo Gallery
// ─────────────────────────────────────────────────────────────────────────────

class _PhotoGallery extends StatelessWidget {
  final List<_GalleryItem> items;
  final void Function(_GalleryItem) onImageTap;
  const _PhotoGallery({required this.items, required this.onImageTap});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(title: 'Gallery', icon: Icons.photo_library_rounded),
          const SizedBox(height: 4),
          Text(
            'Tap any image to expand',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.3,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              return GestureDetector(
                onTap: () => onImageTap(item),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        item.url,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                      ),
                    ),
                    // Label gradient
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.65),
                            ],
                          ),
                        ),
                        child: Text(
                          item.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    // Zoom icon
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.zoom_in,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Timeline
// ─────────────────────────────────────────────────────────────────────────────

class _TimelineCard extends StatelessWidget {
  const _TimelineCard();

  @override
  Widget build(BuildContext context) {
    final events = [
      _TimelineEvent(
        year: '2018',
        title: 'Company Founded',
        body:
            'Pranov Technologies incorporated in Kochi, Kerala with a seed grant from KSUM.',
      ),
      _TimelineEvent(
        year: '2019',
        title: 'First Prototype',
        body:
            'Beta version of Krishi Sakhi tested with 500 farmers in Palakkad district.',
      ),
      _TimelineEvent(
        year: '2020',
        title: 'Series A Funding',
        body:
            '₹8 Cr raised from NABARD\'s RAFTAAR program and two angel investors.',
      ),
      _TimelineEvent(
        year: '2021',
        title: 'National Expansion',
        body:
            'App launched in Tamil Nadu, Karnataka, and Andhra Pradesh with local language support.',
      ),
      _TimelineEvent(
        year: '2022',
        title: 'AI Crop Doctor',
        body:
            'Launched AI-powered disease detection using smartphone camera — 94.2% accuracy.',
      ),
      _TimelineEvent(
        year: '2023',
        title: '1 Million Users',
        body:
            'Crossed 1 million active monthly farmers. Won Forbes AgriTech Innovation Award.',
      ),
      _TimelineEvent(
        year: '2024',
        title: 'Version 2.0',
        body:
            'Complete redesign, weather forecasting, drone advisory, and market integration.',
      ),
    ];
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(title: 'Our Journey', icon: Icons.timeline_rounded),
          const SizedBox(height: 16),
          ...events.asMap().entries.map((entry) {
            final isLast = entry.key == events.length - 1;
            final e = entry.value;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Year column
                  SizedBox(
                    width: 46,
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            e.year,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: const Color(0xFF4CAF50).withOpacity(0.3),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            e.body,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Awards
// ─────────────────────────────────────────────────────────────────────────────

class _AwardsCard extends StatelessWidget {
  const _AwardsCard();

  @override
  Widget build(BuildContext context) {
    final awards = [
      _Award('🏆', 'National Agri Innovation Award', '2021 — Govt. of India'),
      _Award('🌟', 'Forbes India 30 Under 40 — AgriTech', '2022'),
      _Award('🎖️', 'CII Digital India Changemaker', '2023'),
      _Award('🚀', 'NASSCOM Emerge 50', '2022 — Top AgriTech Startup'),
      _Award('🌱', 'NABARD Green Champion Award', '2023'),
    ];
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(
            title: 'Awards & Recognition',
            icon: Icons.emoji_events_rounded,
          ),
          const SizedBox(height: 16),
          ...awards.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(a.emoji, style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2E2E2E),
                          ),
                        ),
                        Text(
                          a.year,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Core Team
// ─────────────────────────────────────────────────────────────────────────────

class _CoreTeamCard extends StatelessWidget {
  final void Function(String url, String label) onImageTap;
  const _CoreTeamCard({required this.onImageTap});

  @override
  Widget build(BuildContext context) {
    final members = [
      _TeamMember(
        name: 'Ananya Krishnan',
        role: 'CTO',
        image:
            'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=300&auto=format&fit=crop',
        tags: ['Flutter', 'Architecture'],
      ),
      _TeamMember(
        name: 'Rohit Nair',
        role: 'Lead AI Engineer',
        image:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&auto=format&fit=crop',
        tags: ['ML', 'Python'],
      ),
      _TeamMember(
        name: 'Meera Pillai',
        role: 'Product Designer',
        image:
            'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=300&auto=format&fit=crop',
        tags: ['UX', 'Research'],
      ),
      _TeamMember(
        name: 'Siddharth Babu',
        role: 'DevOps Lead',
        image:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300&auto=format&fit=crop',
        tags: ['Cloud', 'Firebase'],
      ),
    ];
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(title: 'Core Team', icon: Icons.groups_rounded),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
            children:
                members
                    .map(
                      (m) => GestureDetector(
                        onTap: () => onImageTap(m.image, m.name),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F8E9),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFF4CAF50).withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(40),
                                    child: Image.network(
                                      m.image,
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF2E7D32),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.zoom_in,
                                        color: Colors.white,
                                        size: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                m.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1B5E20),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                m.role,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 4,
                                children:
                                    m.tags
                                        .map(
                                          (t) => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF4CAF50,
                                              ).withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              t,
                                              style: const TextStyle(
                                                fontSize: 9,
                                                color: Color(0xFF2E7D32),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Contact Card
// ─────────────────────────────────────────────────────────────────────────────

class _ContactCard extends StatelessWidget {
  const _ContactCard();

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(
            title: 'Contact Us',
            icon: Icons.contact_mail_rounded,
          ),
          const SizedBox(height: 16),
          _ContactRow(
            icon: Icons.email_rounded,
            label: 'hello@pranovic.com',
            color: const Color(0xFFD32F2F),
          ),
          _ContactRow(
            icon: Icons.language_rounded,
            label: 'www.krishisakhi.in',
            color: const Color(0xFF1565C0),
          ),
          _ContactRow(
            icon: Icons.location_on_rounded,
            label: 'Kakkanad, Kochi, Kerala — 682030',
            color: const Color(0xFF2E7D32),
          ),
          _ContactRow(
            icon: Icons.phone_rounded,
            label: '+91 484 260 5000',
            color: const Color(0xFF6A1B9A),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SocialBtn(
                label: 'LinkedIn',
                icon: Icons.business_rounded,
                color: const Color(0xFF0077B5),
              ),
              _SocialBtn(
                label: 'Twitter',
                icon: Icons.alternate_email,
                color: const Color(0xFF1DA1F2),
              ),
              _SocialBtn(
                label: 'YouTube',
                icon: Icons.play_circle_fill,
                color: const Color(0xFFFF0000),
              ),
              _SocialBtn(
                label: 'Instagram',
                icon: Icons.camera_alt_rounded,
                color: const Color(0xFFE1306C),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Footer
// ─────────────────────────────────────────────────────────────────────────────

class _FooterWidget extends StatelessWidget {
  const _FooterWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B5E20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.eco_rounded, color: Colors.white70, size: 32),
          const SizedBox(height: 10),
          const Text(
            'Krishi Sakhi v2.4.1',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '© 2024 Pranov Technologies Pvt. Ltd.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Made with 💚 for Indian farmers',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Image Preview Screen (Full-screen lightbox)
// ─────────────────────────────────────────────────────────────────────────────

class _ImagePreviewScreen extends StatefulWidget {
  final String imageUrl;
  final String label;
  const _ImagePreviewScreen({required this.imageUrl, required this.label});

  @override
  State<_ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<_ImagePreviewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late Animation<double> _scale;
  final TransformationController _transformController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scale = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ac, curve: Curves.easeOutBack));
    _ac.forward();
  }

  @override
  void dispose() {
    _ac.dispose();
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          color: Colors.black.withOpacity(0.9),
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // Close hint
              const Positioned(
                top: 52,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Tap anywhere to close  •  Pinch to zoom',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              ),
              // Image
              Center(
                child: AnimatedBuilder(
                  animation: _scale,
                  builder:
                      (_, child) =>
                          Transform.scale(scale: _scale.value, child: child),
                  child: GestureDetector(
                    onTap: () {}, // prevent propagation
                    child: InteractiveViewer(
                      transformationController: _transformController,
                      panEnabled: true,
                      scaleEnabled: true,
                      minScale: 0.8,
                      maxScale: 4.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          widget.imageUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return SizedBox(
                              width: 200,
                              height: 200,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  value:
                                      progress.expectedTotalBytes != null
                                          ? progress.cumulativeBytesLoaded /
                                              progress.expectedTotalBytes!
                                          : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Label
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              // X button
              Positioned(
                top: 50,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Shared small UI helpers
// ─────────────────────────────────────────────────────────────────────────────

class _CardShell extends StatelessWidget {
  final Widget child;
  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade100.withOpacity(0.3),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeading({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF2E7D32), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1B5E20),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _PillBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _PillBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SmallChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isQuote;
  const _InfoBlock({
    required this.icon,
    required this.text,
    this.isQuote = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isQuote
                ? const Color(0xFF1B5E20).withOpacity(0.05)
                : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border:
            isQuote
                ? Border(
                  left: BorderSide(color: const Color(0xFF2E7D32), width: 3),
                )
                : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: isQuote ? const Color(0xFF2E7D32) : Colors.grey[500],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: isQuote ? const Color(0xFF1B5E20) : Colors.grey[700],
                fontStyle: isQuote ? FontStyle.italic : FontStyle.normal,
                height: 1.55,
                fontWeight: isQuote ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MVTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _MVTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
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
}

class _StatBubble extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatBubble({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[600],
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF2E2E2E)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _SocialBtn({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data classes
// ─────────────────────────────────────────────────────────────────────────────

class _GalleryItem {
  final String url;
  final String label;
  const _GalleryItem({required this.url, required this.label});
}

class _Tech {
  final String label;
  final IconData icon;
  final Color color;
  const _Tech(this.label, this.icon, this.color);
}

class _TimelineEvent {
  final String year;
  final String title;
  final String body;
  const _TimelineEvent({
    required this.year,
    required this.title,
    required this.body,
  });
}

class _Award {
  final String emoji;
  final String title;
  final String year;
  const _Award(this.emoji, this.title, this.year);
}

class _TeamMember {
  final String name;
  final String role;
  final String image;
  final List<String> tags;
  const _TeamMember({
    required this.name,
    required this.role,
    required this.image,
    required this.tags,
  });
}
