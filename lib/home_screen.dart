import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'main.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = const [
    'All',
    'Action',
    'Sci-Fi',
    'Anime',
    'Trending',
    'Cyberpunk',
    '4K Ultra',
  ];

  @override
  Widget build(BuildContext context) {
    final movieProvider = context.watch<MovieCatalogProvider>();
    final authProvider = context.watch<AppAuthProvider>();

    final movies = movieProvider.movies;
    final heroMovie = movies.isNotEmpty ? movies.first : null;
    final isSaved = heroMovie != null && movieProvider.myListIds.contains(heroMovie.id);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0A0A0F),
      body: movieProvider.isLoading
          ? const _HomeShimmerSkeleton()
          : Stack(
              children: [
                // Scrollable Content
                RefreshIndicator(
                  color: const Color(0xFF00F0FF),
                  backgroundColor: const Color(0xFF14141E),
                  onRefresh: () async {
                    await Future.delayed(const Duration(milliseconds: 600));
                  },
                  child: ListView(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Full-Bleed Immersive Cinema Hero Section
                      if (heroMovie != null)
                        _ImmersiveHeroHeader(
                          heroMovie: heroMovie,
                          isSaved: isSaved,
                          onToggleMyList: () {
                            movieProvider.toggleMyList(heroMovie.id, authProvider.email);
                          },
                          onPlay: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PlayerScreen(movie: heroMovie),
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 24),

                      // Trending Movies Section
                      _MovieSectionRow(
                        title: 'Trending Worldwide',
                        movies: _filterMovies(movies, _selectedCategory),
                      ),

                      const SizedBox(height: 32),

                      // New Releases Section
                      _MovieSectionRow(
                        title: 'New Releases',
                        movies: _filterMovies(movies.reversed.toList(), _selectedCategory),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),

                // Floating Frosted Header (Apple TV / Netflix Style)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _FloatingPremiumHeader(
                    categories: _categories,
                    selectedCategory: _selectedCategory,
                    onSelectCategory: (cat) => setState(() => _selectedCategory = cat),
                  ),
                ),
              ],
            ),
    );
  }

  List<MovieItem> _filterMovies(List<MovieItem> list, String category) {
    if (category == 'All') return list;
    final filtered = list.where((m) => m.category.toLowerCase() == category.toLowerCase()).toList();
    return filtered.isNotEmpty ? filtered : list;
  }
}

// -------------------------------------------------------------
// FLOATING FROSTED HEADER (Logo, Actions & Glassmorphic Category Pills)
// -------------------------------------------------------------

class _FloatingPremiumHeader extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelectCategory;

  const _FloatingPremiumHeader({
    required this.categories,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0A0A0F).withValues(alpha: 0.95),
            const Color(0xFF0A0A0F).withValues(alpha: 0.75),
            Colors.transparent,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Clean Cinematic Branding + Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Premium Brand Typography (No ugly box outline)
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00F0FF), Color(0xFF0072FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00F0FF).withValues(alpha: 0.45),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.play,
                          color: Colors.black,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'STREAM',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                              ),
                            ),
                            TextSpan(
                              text: 'X',
                              style: TextStyle(
                                color: Color(0xFF00F0FF),
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Circular Glass Action Buttons
                  Row(
                    children: [
                      _GlassIconButton(
                        icon: LucideIcons.bell,
                        hasBadge: true,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notifications: 4K HDR releases refreshed!'),
                              backgroundColor: Color(0xFF14141E),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Ultra-Sleek Frosted Glass Category Pills
            SizedBox(
              height: 36,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = cat == selectedCategory;

                  return InkWell(
                    onTap: () => onSelectCategory(cat),
                    borderRadius: BorderRadius.circular(18),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF00F0FF)
                            : Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF00F0FF)
                              : Colors.white.withValues(alpha: 0.18),
                          width: isSelected ? 1.2 : 0.8,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF00F0FF).withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white.withValues(alpha: 0.9),
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 12,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final bool hasBadge;
  final VoidCallback onTap;

  const _GlassIconButton({
    required this.icon,
    this.hasBadge = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 0.8,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          if (hasBadge)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF00F0FF),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// IMMERSIVE FULL-BLEED HERO SECTION (Apple TV / Netflix Style)
// -------------------------------------------------------------

class _ImmersiveHeroHeader extends StatelessWidget {
  final MovieItem heroMovie;
  final bool isSaved;
  final VoidCallback onToggleMyList;
  final VoidCallback onPlay;

  const _ImmersiveHeroHeader({
    required this.heroMovie,
    required this.isSaved,
    required this.onToggleMyList,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final heroHeight = (screenHeight * 0.62).clamp(480.0, 560.0);

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Edge-to-Edge Full-Bleed Artwork
          CachedNetworkImage(
            imageUrl: heroMovie.bannerUrl,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            placeholder: (context, url) => Container(color: const Color(0xFF14141E)),
            errorWidget: (context, url, error) => Container(
              color: const Color(0xFF14141E),
              child: const Icon(LucideIcons.film, color: Colors.white24, size: 48),
            ),
          ),

          // Multi-layer Cinema Vignettes (Seamless bottom transition into 0xFF0A0A0F)
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0A0A0F).withValues(alpha: 0.7),
                  Colors.transparent,
                  Colors.transparent,
                  const Color(0xFF0A0A0F).withValues(alpha: 0.5),
                  const Color(0xFF0A0A0F).withValues(alpha: 0.9),
                  const Color(0xFF0A0A0F),
                ],
                stops: const [0.0, 0.22, 0.45, 0.70, 0.88, 1.0],
              ),
            ),
          ),

          // Bottom Content: Badges, Title, Metadata & Sleek Action Buttons
          Positioned(
            left: 20,
            right: 20,
            bottom: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cinema Series / Feature Badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00F0FF).withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFF00F0FF).withValues(alpha: 0.8),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.sparkles, color: Color(0xFF00F0FF), size: 10),
                          const SizedBox(width: 4),
                          Text(
                            'STREAMX ORIGINAL · ${heroMovie.category.toUpperCase()}',
                            style: const TextStyle(
                              color: Color(0xFF00F0FF),
                              fontWeight: FontWeight.w800,
                              fontSize: 9.5,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Main Cinematic Title
                Text(
                  heroMovie.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    height: 1.12,
                    shadows: [
                      Shadow(
                        color: Colors.black87,
                        blurRadius: 18,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Metadata Details: Rating, Year, 4K HDR, Dolby
                Row(
                  children: [
                    const Icon(LucideIcons.star, color: Color(0xFFFFB800), size: 13),
                    const SizedBox(width: 4),
                    Text(
                      '${heroMovie.rating}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Text(
                        '4K ULTRA HD',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Text(
                        'DOLBY ATMOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${heroMovie.releaseYear}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Plot Synopsis
                Text(
                  heroMovie.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 12,
                    height: 1.35,
                    shadows: const [
                      Shadow(color: Colors.black54, blurRadius: 10),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Sleek, Minimalist Action Buttons (Apple TV / Netflix Style)
                Row(
                  children: [
                    // Primary Play Button: Crisp, elegant white pill with black icon & text
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onPlay,
                        borderRadius: BorderRadius.circular(22),
                        child: Ink(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.25),
                                blurRadius: 14,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.play, color: Colors.black, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Play Now',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13.5,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Secondary My List Button: Frosted Glass Pill
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onToggleMyList,
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isSaved
                                  ? const Color(0xFF00F0FF)
                                  : Colors.white.withValues(alpha: 0.25),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSaved ? LucideIcons.check : LucideIcons.plus,
                                color: isSaved ? const Color(0xFF00F0FF) : Colors.white,
                                size: 15,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                isSaved ? 'In List' : 'My List',
                                style: TextStyle(
                                  color: isSaved ? const Color(0xFF00F0FF) : Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
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
    );
  }
}

// -------------------------------------------------------------
// CLEANER ROWS: MOVIE SECTION
// -------------------------------------------------------------

class _MovieSectionRow extends StatelessWidget {
  final String title;
  final List<MovieItem> movies;

  const _MovieSectionRow({
    required this.title,
    required this.movies,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with proper typography and spacing
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
              const Text(
                'See All',
                style: TextStyle(
                  color: Color(0xFF00F0FF),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 205,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: movies.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final movie = movies[index];
              return SizedBox(
                width: 125,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlayerScreen(movie: movie),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster Image with subtle border radius
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF1E1E2C),
                              width: 0.8,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                imageUrl: movie.posterUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(color: const Color(0xFF14141E)),
                                errorWidget: (context, url, error) => Container(
                                  color: const Color(0xFF14141E),
                                  child: const Icon(LucideIcons.film, color: Colors.white24),
                                ),
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.78),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(LucideIcons.star, color: Color(0xFFFFB800), size: 9),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${movie.rating}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
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
                      const SizedBox(height: 7),
                      Text(
                        movie.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${movie.releaseYear} · ${movie.category}',
                        style: const TextStyle(
                          color: Color(0xFF7E849E),
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------
// SHIMMER SKELETON
// -------------------------------------------------------------

class _HomeShimmerSkeleton extends StatelessWidget {
  const _HomeShimmerSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF14141E),
      highlightColor: const Color(0xFF242436),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 480,
            width: double.infinity,
            color: Colors.white,
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(width: 140, height: 18, color: Colors.white),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 190,
            child: Row(
              children: List.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.only(left: 20),
                  width: 125,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
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
