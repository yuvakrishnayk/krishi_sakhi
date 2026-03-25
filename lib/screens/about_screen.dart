import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ══════════════════════════════════════════════════════════════════════════════
// ABOUT SCREEN — Krishi Sakhi  |  Polished v3.0
// Zero-gap, tight, premium UI with full stagger animations
// ══════════════════════════════════════════════════════════════════════════════

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroCtrl;
  late AnimationController _staggerCtrl;
  late Animation<double> _heroScale;
  late Animation<double> _heroFade;

  final List<_GalleryItem> _gallery = [
    _GalleryItem(
      'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=800&auto=format&fit=crop',
      'Our Farms',
    ),
    _GalleryItem(
      'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=800&auto=format&fit=crop',
      'Technology & Agriculture',
    ),
    _GalleryItem(
      'https://images.unsplash.com/photo-1574943320219-553eb213f72d?w=800&auto=format&fit=crop',
      'Smart Farming',
    ),
    _GalleryItem(
      'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800&auto=format&fit=crop',
      'Sustainable Growth',
    ),
    _GalleryItem(
      'https://images.unsplash.com/photo-1536183922588-166604504d5e?w=800&auto=format&fit=crop',
      'Innovation Lab',
    ),
    _GalleryItem(
      'https://images.unsplash.com/photo-1495107334309-fcf20504a5ab?w=800&auto=format&fit=crop',
      'Rural Connect',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _heroScale = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.elasticOut));
    _heroFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _heroCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    _heroCtrl.forward();
    Future.delayed(
      const Duration(milliseconds: 300),
      () => _staggerCtrl.forward(),
    );
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _staggerCtrl.dispose();
    super.dispose();
  }

  void _preview(String url, String label) => Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black87,
      barrierDismissible: true,
      pageBuilder: (_, __, ___) => _LightBox(imageUrl: url, label: label),
      transitionsBuilder:
          (_, a, __, child) => FadeTransition(opacity: a, child: child),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F7F2),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF1B5E20),
                  size: 18,
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Hero ──────────────────────────────────────────────
              _HeroBanner(
                heroScale: _heroScale,
                heroFade: _heroFade,
                onTap:
                    () => _preview(
                      'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=1200&auto=format&fit=crop',
                      'Krishi Sakhi — Fields of Tomorrow',
                    ),
              ),

              // ── Content cards with zero gap between them ──────────
              _Stagger(ctrl: _staggerCtrl, i: 0, child: _TaglineCard()),
              _Stagger(
                ctrl: _staggerCtrl,
                i: 1,
                child: _FounderCard(
                  onTap:
                      () => _preview(
                        'https://res.cloudinary.com/dl1xhhpjq/image/upload/v1773949316/Generated_Image_March_20_2026_-_1_07AM_ojwdyf.png',
                        'Dr. Pranov JB — Founder & CEO',
                      ),
                ),
              ),
              _Stagger(ctrl: _staggerCtrl, i: 2, child: const _MissionCard()),
              _Stagger(ctrl: _staggerCtrl, i: 3, child: const _StatsBar()),
              _Stagger(ctrl: _staggerCtrl, i: 4, child: const _TechCard()),
              _Stagger(
                ctrl: _staggerCtrl,
                i: 5,
                child: _GalleryCard(
                  items: _gallery,
                  onTap: (i) => _preview(i.url, i.label),
                ),
              ),
              _Stagger(ctrl: _staggerCtrl, i: 6, child: const _TimelineCard()),
              _Stagger(ctrl: _staggerCtrl, i: 7, child: const _AwardsCard()),
              _Stagger(
                ctrl: _staggerCtrl,
                i: 8,
                child: _TeamCard(onTap: _preview),
              ),
              _Stagger(ctrl: _staggerCtrl, i: 9, child: const _ContactCard()),
              _Stagger(ctrl: _staggerCtrl, i: 10, child: const _Footer()),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stagger Wrapper
// ─────────────────────────────────────────────────────────────────────────────

class _Stagger extends StatelessWidget {
  final AnimationController ctrl;
  final int i;
  final Widget child;
  const _Stagger({required this.ctrl, required this.i, required this.child});

  @override
  Widget build(BuildContext context) {
    final start = (i * 0.08).clamp(0.0, 0.85);
    final end = (start + 0.35).clamp(0.0, 1.0);
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final t =
            CurvedAnimation(
              parent: ctrl,
              curve: Interval(start, end, curve: Curves.easeOutCubic),
            ).value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - t)),
            child: child,
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card Shell — zero margin top/bottom between cards, tight internal padding
// ─────────────────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? bg;
  const _Card({required this.child, this.padding, this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      padding: padding ?? const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: bg ?? Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF388E3C).withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Heading
// ─────────────────────────────────────────────────────────────────────────────

class _Heading extends StatelessWidget {
  final String title;
  final IconData icon;
  const _Heading({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.13),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: const Color(0xFF2E7D32), size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1B5E20),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Banner
// ─────────────────────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final Animation<double> heroScale, heroFade;
  final VoidCallback onTap;
  const _HeroBanner({
    required this.heroScale,
    required this.heroFade,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: heroFade,
      builder:
          (_, __) => Opacity(
            opacity: heroFade.value,
            child: GestureDetector(
              onTap: onTap,
              child: SizedBox(
                height: 300,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=800&auto=format&fit=crop',
                      fit: BoxFit.cover,
                      loadingBuilder:
                          (_, child, p) =>
                              p == null
                                  ? child
                                  : Container(
                                    color: const Color(0xFF1B5E20),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.2),
                            const Color(0xFF1B5E20).withOpacity(0.88),
                          ],
                          stops: const [0.3, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 80,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.35),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.zoom_in_rounded,
                              color: Colors.white,
                              size: 13,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Tap to expand',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 22,
                      left: 0,
                      right: 0,
                      child: AnimatedBuilder(
                        animation: heroScale,
                        builder:
                            (_, child) => Transform.scale(
                              scale: heroScale.value,
                              child: child,
                            ),
                        child: Column(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 14,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.eco_rounded,
                                size: 40,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'KRISHI SAKHI',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 4.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'by Pranov Technologies Pvt. Ltd.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.82),
                                fontSize: 12,
                                letterSpacing: 1.1,
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
          ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tagline Card
// ─────────────────────────────────────────────────────────────────────────────

class _TaglineCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: const [
              _Pill(label: 'v2.4.1', color: Color(0xFF43A047)),
              _Pill(label: 'Agriculture Tech', color: Color(0xFF1565C0)),
              _Pill(label: 'Made in India 🇮🇳', color: Color(0xFFE65100)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '"Bridging the gap between farmers\nand the digital world"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B5E20),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Krishi Sakhi is a comprehensive mobile platform designed to empower Indian farmers '
            'with AI-powered crop advisory, weather intelligence, market prices, and government '
            'scheme notifications — all in their native language.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.58,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Founder Card
// ─────────────────────────────────────────────────────────────────────────────

class _FounderCard extends StatelessWidget {
  final VoidCallback onTap;
  const _FounderCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Heading(
            title: 'Founder & CEO',
            icon: Icons.person_pin_rounded,
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onTap,
                child: Stack(
                  children: [
                    Container(
                      width: 92,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2E7D32).withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          'https://res.cloudinary.com/dl1xhhpjq/image/upload/v1773949316/Generated_Image_March_20_2026_-_1_07AM_ojwdyf.png',
                          fit: BoxFit.cover,
                          loadingBuilder:
                              (_, c, p) =>
                                  p == null
                                      ? c
                                      : Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.zoom_in_rounded,
                          color: Color(0xFF2E7D32),
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dr. Pranov JB',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Founder & CEO\nPranov Technologies Pvt. Ltd.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: const [
                        _Chip(label: 'AgriTech', icon: Icons.agriculture),
                        _Chip(label: 'AI/ML', icon: Icons.psychology),
                        _Chip(label: 'IoT', icon: Icons.sensors),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _IBlock(
            icon: Icons.format_quote_rounded,
            isQuote: true,
            text:
                '"Technology should serve the farmer, not intimidate him. '
                'Krishi Sakhi was born from a single question — why should a farmer '
                'in rural Kerala not have the same access to information as an urban entrepreneur?"',
          ),
          const SizedBox(height: 8),
          const _IBlock(
            icon: Icons.school_rounded,
            text:
                'Ph.D in Agricultural Informatics, University of Agricultural Sciences, Bangalore. '
                'Post-Doctoral fellowship from IIT Madras in Precision Farming Technologies.',
          ),
          const SizedBox(height: 8),
          const _IBlock(
            icon: Icons.work_history_rounded,
            text:
                '14+ years across agri-tech startups, government advisory roles, and academic research. '
                'Leads with a vision to digitize India\'s 140 million farming households by 2030.',
          ),
          const SizedBox(height: 8),
          const _IBlock(
            icon: Icons.emoji_events_rounded,
            text:
                'National Agri Innovation Award (2021) • Forbes India 30 Under 40 — AgriTech (2022) • '
                'CII Digital India Changemaker Award (2023).',
          ),
          const SizedBox(height: 8),
          const _IBlock(
            icon: Icons.translate_rounded,
            text:
                'Fluent in Malayalam, Tamil, Kannada, Hindi & English. '
                'Passionate about multilingual accessibility and vernacular AI interfaces.',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mission Card
// ─────────────────────────────────────────────────────────────────────────────

class _MissionCard extends StatelessWidget {
  const _MissionCard();

  @override
  Widget build(BuildContext context) {
    return const _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Heading(title: 'Mission & Vision', icon: Icons.flag_rounded),
          SizedBox(height: 12),
          _MVTile(
            icon: Icons.rocket_launch_rounded,
            color: Color(0xFF1565C0),
            title: 'Our Mission',
            body:
                'To democratize agricultural knowledge by delivering AI-driven, multilingual, and affordable digital tools to every farmer in India — regardless of literacy, connectivity, or device capability.',
          ),
          SizedBox(height: 8),
          _MVTile(
            icon: Icons.remove_red_eye_rounded,
            color: Color(0xFF6A1B9A),
            title: 'Our Vision',
            body:
                'A future where every Indian farmer makes data-informed decisions, earns fair market value, and has zero dependency on exploitative intermediaries.',
          ),
          SizedBox(height: 8),
          _MVTile(
            icon: Icons.favorite_rounded,
            color: Color(0xFFC62828),
            title: 'Our Values',
            body:
                'Farmer-first design • Radical simplicity • Regional language pride • Transparency • Open data advocacy • Sustainable agriculture.',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats Bar — full-width green strip
// ─────────────────────────────────────────────────────────────────────────────

class _StatsBar extends StatelessWidget {
  const _StatsBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      child: Row(
        children: const [
          _Stat(value: '2M+', label: 'Farmers\nServed'),
          _StatDivider(),
          _Stat(value: '18', label: 'States\nCovered'),
          _StatDivider(),
          _Stat(value: '11', label: 'Languages\nSupported'),
          _StatDivider(),
          _Stat(value: '4.8★', label: 'Play Store\nRating'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9,
              color: Colors.white70,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: Colors.white24);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tech Card
// ─────────────────────────────────────────────────────────────────────────────

class _TechCard extends StatelessWidget {
  const _TechCard();

  @override
  Widget build(BuildContext context) {
    final techs = [
      _Tech('Flutter', Icons.phone_android, const Color(0xFF0288D1)),
      _Tech('Firebase', Icons.local_fire_department, const Color(0xFFFB8C00)),
      _Tech('Python AI', Icons.psychology, const Color(0xFF43A047)),
      _Tech('TensorFlow', Icons.memory, const Color(0xFFFF7043)),
      _Tech('REST API', Icons.api, const Color(0xFF7B1FA2)),
      _Tech('Google Maps', Icons.map_rounded, const Color(0xFF1976D2)),
    ];
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Heading(
            title: 'Technology Stack',
            icon: Icons.developer_board_rounded,
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.6,
            children:
                techs
                    .map(
                      (t) => Container(
                        decoration: BoxDecoration(
                          color: t.color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: t.color.withOpacity(0.22)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(t.icon, color: t.color, size: 15),
                            const SizedBox(width: 5),
                            Text(
                              t.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
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
// Gallery Card
// ─────────────────────────────────────────────────────────────────────────────

class _GalleryCard extends StatelessWidget {
  final List<_GalleryItem> items;
  final void Function(_GalleryItem) onTap;
  const _GalleryCard({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Heading(title: 'Gallery', icon: Icons.photo_library_rounded),
          const SizedBox(height: 3),
          Text(
            'Tap any image to expand',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.35,
            ),
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];
              return GestureDetector(
                onTap: () => onTap(item),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        item.url,
                        fit: BoxFit.cover,
                        loadingBuilder:
                            (_, c, p) =>
                                p == null
                                    ? c
                                    : Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                        ),
                                      ),
                                    ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(8, 16, 8, 7),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                          child: Text(
                            item.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.38),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.zoom_in_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
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
// Timeline Card
// ─────────────────────────────────────────────────────────────────────────────

class _TimelineCard extends StatelessWidget {
  const _TimelineCard();

  @override
  Widget build(BuildContext context) {
    const events = [
      _TEvent(
        '2018',
        'Company Founded',
        'Pranov Technologies incorporated in Kochi, Kerala with a seed grant from KSUM.',
      ),
      _TEvent(
        '2019',
        'First Prototype',
        'Beta version of Krishi Sakhi tested with 500 farmers in Palakkad district.',
      ),
      _TEvent(
        '2020',
        'Series A Funding',
        '₹8 Cr raised from NABARD\'s RAFTAAR program and two angel investors.',
      ),
      _TEvent(
        '2021',
        'National Expansion',
        'App launched in Tamil Nadu, Karnataka, and Andhra Pradesh with local language support.',
      ),
      _TEvent(
        '2022',
        'AI Crop Doctor',
        'Launched AI-powered disease detection using smartphone camera — 94.2% accuracy.',
      ),
      _TEvent(
        '2023',
        '1 Million Users',
        'Crossed 1 million active monthly farmers. Won Forbes AgriTech Innovation Award.',
      ),
      _TEvent(
        '2024',
        'Version 2.0',
        'Complete redesign, weather forecasting, drone advisory, and market integration.',
      ),
    ];
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Heading(title: 'Our Journey', icon: Icons.timeline_rounded),
          const SizedBox(height: 14),
          ...List.generate(events.length, (idx) {
            final e = events[idx];
            final isLast = idx == events.length - 1;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 44,
                    child: Column(
                      children: [
                        Container(
                          width: 38,
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            e.year,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              margin: const EdgeInsets.symmetric(vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF4CAF50,
                                ).withOpacity(0.25),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            e.body,
                            style: TextStyle(
                              fontSize: 12,
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
// Awards Card
// ─────────────────────────────────────────────────────────────────────────────

class _AwardsCard extends StatelessWidget {
  const _AwardsCard();

  @override
  Widget build(BuildContext context) {
    const awards = [
      _Award('🏆', 'National Agri Innovation Award', '2021 — Govt. of India'),
      _Award('🌟', 'Forbes India 30 Under 40 — AgriTech', '2022'),
      _Award('🎖️', 'CII Digital India Changemaker', '2023'),
      _Award('🚀', 'NASSCOM Emerge 50', '2022 — Top AgriTech Startup'),
      _Award('🌱', 'NABARD Green Champion Award', '2023'),
    ];
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Heading(
            title: 'Awards & Recognition',
            icon: Icons.emoji_events_rounded,
          ),
          const SizedBox(height: 12),
          ...awards.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(a.emoji, style: const TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
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
                            fontSize: 11,
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
// Team Card
// ─────────────────────────────────────────────────────────────────────────────

class _TeamCard extends StatelessWidget {
  final void Function(String url, String label) onTap;
  const _TeamCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final members = [
      _Member(
        'Sundar Pichai',
        'CTO',
        'https://tse4.mm.bing.net/th/id/OIP._6wjBBihWJtXC0q868u3TQHaHa?rs=1&pid=ImgDetMain&o=7&rm=3',
        ['Flutter', 'Architecture', 'Google'],
      ),
      _Member(
        'Sam Altman',
        'Lead AI Engineer',
        'https://tse4.mm.bing.net/th/id/OIP.ePWWS8qREcHapcM2Av_P5gHaEK?rs=1&pid=ImgDetMain&o=7&rm=3',
        ['ML', 'Python'],
      ),
      _Member(
        'Bill Gates',
        'Product Designer',
        'https://th.bing.com/th/id/OIP.WeE58BLNY3gqYNygJ3EZ7gEsEs?w=200&h=200&c=10&o=6&dpr=1.3&pid=genserp&rm=2',
        ['UX', 'Research', 'Budgeting'],
      ),
      _Member(
        'Sridhar Vembu',
        'DevOps Lead',
        'https://s3.amazonaws.com/techpluto/wp-content/uploads/2018/09/24092816/Sridhar-Vembu-CEO-Zoho.jpg',
        ['Cloud', 'Firebase'],
      ),
    ];
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Heading(title: 'Core Team', icon: Icons.groups_rounded),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.9,
            children:
                members
                    .map(
                      (m) => GestureDetector(
                        onTap: () => onTap(m.image, m.name),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F8E9),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFF4CAF50).withOpacity(0.2),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 10,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(36),
                                    child: Image.network(
                                      m.image,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) => Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(36),
                                            ),
                                            child: const Icon(
                                              Icons.person,
                                              color: Colors.grey,
                                            ),
                                          ),
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
                                        Icons.zoom_in_rounded,
                                        color: Colors.white,
                                        size: 9,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 7),
                              Text(
                                m.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1B5E20),
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                m.role,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 7),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 4,
                                runSpacing: 4,
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
                                              ).withOpacity(0.14),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              t,
                                              style: const TextStyle(
                                                fontSize: 8,
                                                color: Color(0xFF2E7D32),
                                                fontWeight: FontWeight.w700,
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
    return const _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Heading(title: 'Contact Us', icon: Icons.contact_mail_rounded),
          SizedBox(height: 12),
          _CRow(
            icon: Icons.email_rounded,
            label: 'hello@pranovic.com',
            color: Color(0xFFD32F2F),
          ),
          _CRow(
            icon: Icons.language_rounded,
            label: 'www.krishisakhi.in',
            color: Color(0xFF1565C0),
          ),
          _CRow(
            icon: Icons.location_on_rounded,
            label: 'Kakkanad, Kochi, Kerala — 682030',
            color: Color(0xFF2E7D32),
          ),
          _CRow(
            icon: Icons.phone_rounded,
            label: '+91 484 260 5000',
            color: Color(0xFF6A1B9A),
          ),
          SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SocBtn(
                label: 'LinkedIn',
                icon: Icons.business_rounded,
                color: Color(0xFF0077B5),
              ),
              _SocBtn(
                label: 'Twitter',
                icon: Icons.alternate_email,
                color: Color(0xFF1DA1F2),
              ),
              _SocBtn(
                label: 'YouTube',
                icon: Icons.play_circle_fill_rounded,
                color: Color(0xFFFF0000),
              ),
              _SocBtn(
                label: 'Instagram',
                icon: Icons.camera_alt_rounded,
                color: Color(0xFFE1306C),
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

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withOpacity(0.4),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.eco_rounded, color: Colors.white60, size: 30),
          const SizedBox(height: 8),
          const Text(
            'Krishi Sakhi v2.4.1',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '© 2024 Pranov Technologies Pvt. Ltd.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Made with 💚 for Indian farmers',
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lightbox
// ─────────────────────────────────────────────────────────────────────────────

class _LightBox extends StatefulWidget {
  final String imageUrl, label;
  const _LightBox({required this.imageUrl, required this.label});

  @override
  State<_LightBox> createState() => _LightBoxState();
}

class _LightBoxState extends State<_LightBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ac;
  late Animation<double> _scale;
  final TransformationController _tc = TransformationController();

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _scale = Tween<double>(
      begin: 0.75,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ac, curve: Curves.easeOutBack));
    _ac.forward();
  }

  @override
  void dispose() {
    _ac.dispose();
    _tc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          color: Colors.black.withOpacity(0.92),
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              const Positioned(
                top: 52,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Tap anywhere to close  •  Pinch to zoom',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ),
              ),
              Center(
                child: AnimatedBuilder(
                  animation: _scale,
                  builder:
                      (_, child) =>
                          Transform.scale(scale: _scale.value, child: child),
                  child: GestureDetector(
                    onTap: () {},
                    child: InteractiveViewer(
                      transformationController: _tc,
                      minScale: 0.8,
                      maxScale: 4.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          widget.imageUrl,
                          fit: BoxFit.contain,
                          loadingBuilder:
                              (_, c, p) =>
                                  p == null
                                      ? c
                                      : SizedBox(
                                        width: 180,
                                        height: 180,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            value:
                                                p.expectedTotalBytes != null
                                                    ? p.cumulativeBytesLoaded /
                                                        p.expectedTotalBytes!
                                                    : null,
                                          ),
                                        ),
                                      ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 38,
                left: 18,
                right: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.11),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 50,
                right: 14,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.14),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
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
// Reusable micro-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Chip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _IBlock extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isQuote;
  const _IBlock({required this.icon, required this.text, this.isQuote = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color:
            isQuote
                ? const Color(0xFF1B5E20).withOpacity(0.05)
                : const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(10),
        border:
            isQuote
                ? const Border(
                  left: BorderSide(color: Color(0xFF2E7D32), width: 3),
                )
                : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 14,
            color: isQuote ? const Color(0xFF2E7D32) : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
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
  final String title, body;
  const _MVTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    height: 1.45,
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

class _CRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _CRow({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF2E2E2E)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _SocBtn({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.28)),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(fontSize: 9, color: Colors.grey[600])),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────────────────────

class _GalleryItem {
  final String url, label;
  const _GalleryItem(this.url, this.label);
}

class _Tech {
  final String label;
  final IconData icon;
  final Color color;
  const _Tech(this.label, this.icon, this.color);
}

class _TEvent {
  final String year, title, body;
  const _TEvent(this.year, this.title, this.body);
}

class _Award {
  final String emoji, title, year;
  const _Award(this.emoji, this.title, this.year);
}

class _Member {
  final String name, role, image;
  final List<String> tags;
  const _Member(this.name, this.role, this.image, this.tags);
}
