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

  // Updated Categories: Movies, Anime, Drama, Indian, Action, Sci-Fi
  final List<String> _categories = const [
    'All',
    'Movies',
    'Anime',
    'Drama',
    'Indian',
    'Action',
    'Sci-Fi',
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
      backgroundColor: const Color(0xFF050508), // Pure OLED Deep Black
      body: movieProvider.isLoading
          ? const _HomeShimmerSkeleton()
          : Stack(
              children: [
                // Scrollable Content
                RefreshIndicator(
                  color: const Color(0xFF00F0FF),
                  backgroundColor: const Color(0xFF0D0D14),
                  onRefresh: () async {
                    await Future.delayed(const Duration(milliseconds: 600));
                  },
                  child: ListView(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // Full-Bleed Cinema Hero Header with Neon Edge Glow
                      if (heroMovie != null)
                        _NeonImmersiveHeroHeader(
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
                      _NeonMovieSectionRow(
                        title: 'Trending Worldwide',
                        accentColor: const Color(0xFF00F0FF),
                        movies: _filterMovies(movies, _selectedCategory),
                      ),

                      const SizedBox(height: 32),

                      // Indian Blockbusters & Desi Cinema Row
                      _NeonMovieSectionRow(
                        title: 'Indian Blockbusters & Desi Cinema',
                        accentColor: const Color(0xFFFF9900),
                        movies: _filterMovies(
                          movies.where((m) => m.category == 'Indian' || m.category == 'Drama').isNotEmpty
                              ? movies.where((m) => m.category == 'Indian' || m.category == 'Drama').toList()
                              : movies,
                          _selectedCategory,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Top Anime & Cyberpunk Row
                      _NeonMovieSectionRow(
                        title: 'Anime Universe & Animation',
                        accentColor: const Color(0xFFBD00FF),
                        movies: _filterMovies(
                          movies.where((m) => m.category == 'Anime').isNotEmpty
                              ? movies.where((m) => m.category == 'Anime').toList()
                              : movies.reversed.toList(),
                          _selectedCategory,
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),

                // Floating Neon Frosted Header
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _FloatingNeonHeader(
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
// FLOATING NEON HEADER (Clean Logo & Glowing Frosted Category Pills)
// -------------------------------------------------------------

class _FloatingNeonHeader extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelectCategory;

  const _FloatingNeonHeader({
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
            const Color(0xFF050508).withValues(alpha: 0.98),
            const Color(0xFF050508).withValues(alpha: 0.80),
            Colors.transparent,
          ],
          stops: const [0.0, 0.65, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Glowing Neon Logo + Notification Icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Luminous Neon StreamX Logo
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00F0FF), Color(0xFF0072FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00F0FF).withValues(alpha: 0.55),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.play,
                          color: Colors.black,
                          size: 17,
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
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.2,
                              ),
                            ),
                            TextSpan(
                              text: 'X',
                              style: TextStyle(
                                color: Color(0xFF00F0FF),
                                fontSize: 23,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.2,
                                shadows: [
                                  Shadow(
                                    color: Color(0xFF00F0FF),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Circular Glass Notification Button with Neon Glow
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 0.8,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(LucideIcons.bell, color: Colors.white, size: 16),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF00F0FF),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF00F0FF),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Neon Category Pills Row (Movies, Anime, Drama, Indian, Action, Sci-Fi)
            SizedBox(
              height: 38,
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
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF00F0FF)
                            : Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF00F0FF)
                              : Colors.white.withValues(alpha: 0.20),
                          width: isSelected ? 1.4 : 0.8,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF00F0FF).withValues(alpha: 0.45),
                                  blurRadius: 14,
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
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            fontSize: 12.5,
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

// -------------------------------------------------------------
// IMMERSIVE FULL-BLEED HERO SECTION WITH NEON AURA
// -------------------------------------------------------------

class _NeonImmersiveHeroHeader extends StatelessWidget {
  final MovieItem heroMovie;
  final bool isSaved;
  final VoidCallback onToggleMyList;
  final VoidCallback onPlay;

  const _NeonImmersiveHeroHeader({
    required this.heroMovie,
    required this.isSaved,
    required this.onToggleMyList,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final heroHeight = (screenHeight * 0.64).clamp(500.0, 580.0);

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Edge-to-Edge Poster Image
          CachedNetworkImage(
            imageUrl: heroMovie.bannerUrl,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            placeholder: (context, url) => Container(color: const Color(0xFF0D0D14)),
            errorWidget: (context, url, error) => Container(
              color: const Color(0xFF0D0D14),
              child: const Icon(LucideIcons.film, color: Colors.white24, size: 48),
            ),
          ),

          // Multi-layer Cinema Vignette with bottom fade into 0xFF050508
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF050508).withValues(alpha: 0.75),
                  Colors.transparent,
                  Colors.transparent,
                  const Color(0xFF050508).withValues(alpha: 0.45),
                  const Color(0xFF050508).withValues(alpha: 0.88),
                  const Color(0xFF050508),
                ],
                stops: const [0.0, 0.20, 0.45, 0.68, 0.86, 1.0],
              ),
            ),
          ),

          // Bottom Content: Badges, Title, Badges, and Neon Play/List Buttons
          Positioned(
            left: 20,
            right: 20,
            bottom: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glowing Neon Tag
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00F0FF).withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF00F0FF).withValues(alpha: 0.8),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00F0FF).withValues(alpha: 0.25),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.sparkles, color: Color(0xFF00F0FF), size: 11),
                          const SizedBox(width: 5),
                          Text(
                            'STREAMX EXCLUSIVE · ${heroMovie.category.toUpperCase()}',
                            style: const TextStyle(
                              color: Color(0xFF00F0FF),
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Bold Cinematic Title
                Text(
                  heroMovie.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                    height: 1.12,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 20,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Metadata Details: Rating, Badges, Year
                Row(
                  children: [
                    const Icon(LucideIcons.star, color: Color(0xFFFFB800), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${heroMovie.rating}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 0.6),
                      ),
                      child: const Text(
                        '4K ULTRA HD',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 0.6),
                      ),
                      child: const Text(
                        'DOLBY ATMOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${heroMovie.releaseYear}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 12,
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
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 12.5,
                    height: 1.35,
                    shadows: const [
                      Shadow(color: Colors.black87, blurRadius: 10),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Glowing Neon Buttons
                Row(
                  children: [
                    // Play Now: Radiant Neon Cyan Gradient Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onPlay,
                        borderRadius: BorderRadius.circular(22),
                        child: Ink(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00F0FF), Color(0xFF0088FF)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00F0FF).withValues(alpha: 0.5),
                                blurRadius: 18,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.play, color: Colors.black, size: 17),
                              SizedBox(width: 8),
                              Text(
                                'Watch Now',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // My List: Frosted Black Pill with Glowing Border
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onToggleMyList,
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isSaved
                                  ? const Color(0xFF00F0FF)
                                  : Colors.white.withValues(alpha: 0.28),
                              width: isSaved ? 1.4 : 1.0,
                            ),
                            boxShadow: isSaved
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF00F0FF).withValues(alpha: 0.35),
                                      blurRadius: 12,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSaved ? LucideIcons.check : LucideIcons.plus,
                                color: isSaved ? const Color(0xFF00F0FF) : Colors.white,
                                size: 16,
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
// NEON MOVIE SECTION ROW
// -------------------------------------------------------------

class _NeonMovieSectionRow extends StatelessWidget {
  final String title;
  final Color accentColor;
  final List<MovieItem> movies;

  const _NeonMovieSectionRow({
    required this.title,
    required this.accentColor,
    required this.movies,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with Neon Accent Strip
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 3.5,
                    height: 16,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.6),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              Text(
                'See All',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 210,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: movies.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final movie = movies[index];
              return SizedBox(
                width: 128,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlayerScreen(movie: movie),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster with subtle neon border
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF1E1E2C),
                              width: 0.9,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedNetworkImage(
                                imageUrl: movie.posterUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(color: const Color(0xFF0D0D14)),
                                errorWidget: (context, url, error) => Container(
                                  color: const Color(0xFF0D0D14),
                                  child: const Icon(LucideIcons.film, color: Colors.white24),
                                ),
                              ),
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.82),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      width: 0.5,
                                    ),
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
                      const SizedBox(height: 8),
                      Text(
                        movie.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
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
      baseColor: const Color(0xFF0D0D14),
      highlightColor: const Color(0xFF1E1E2C),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 500,
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
