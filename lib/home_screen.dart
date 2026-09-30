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
    'Drama',
    'Cyberpunk',
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF00F0FF).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF00F0FF), width: 1.0),
          ),
          child: const Text(
            'STREAMX',
            style: TextStyle(
              color: Color(0xFF00F0FF),
              fontWeight: FontWeight.w900,
              fontSize: 15,
              letterSpacing: 2.2,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell, color: Colors.white, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications: 4K HDR releases refreshed today!'),
                  backgroundColor: Color(0xFF14141E),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: movieProvider.isLoading
          ? const _HomeShimmerSkeleton()
          : RefreshIndicator(
              color: const Color(0xFF00F0FF),
              backgroundColor: const Color(0xFF14141E),
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 600));
              },
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                children: [
                  // 1. TOP CATEGORIES ROW: Instantly below AppBar & completely ABOVE Hero Image
                  SafeArea(
                    bottom: false,
                    child: Container(
                      margin: const EdgeInsets.only(top: 4, bottom: 12),
                      height: 36,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final isSelected = cat == _selectedCategory;
                          return InkWell(
                            onTap: () => setState(() => _selectedCategory = cat),
                            borderRadius: BorderRadius.circular(18),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF00F0FF)
                                    : const Color(0xFF14141E).withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF00F0FF)
                                      : const Color(0xFF262638),
                                  width: 0.8,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF00F0FF).withValues(alpha: 0.25),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : Colors.white.withValues(alpha: 0.85),
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                    fontSize: 12,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // 2. EDGE-TO-EDGE HERO IMAGE SECTION
                  if (heroMovie != null)
                    _EdgeToEdgeHeroSection(
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

                  const SizedBox(height: 28),

                  // 4. CLEANER ROWS: Trending Worldwide
                  _MovieSectionRow(
                    title: 'Trending Worldwide',
                    movies: _filterMovies(movies, _selectedCategory),
                  ),

                  const SizedBox(height: 32),

                  // 4. CLEANER ROWS: New Releases
                  _MovieSectionRow(
                    title: 'New Releases',
                    movies: _filterMovies(movies.reversed.toList(), _selectedCategory),
                  ),

                  const SizedBox(height: 48),
                ],
              ),
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
// EDGE-TO-EDGE HERO IMAGE COMPONENT (Apple TV / Netflix style)
// -------------------------------------------------------------

class _EdgeToEdgeHeroSection extends StatelessWidget {
  final MovieItem heroMovie;
  final bool isSaved;
  final VoidCallback onToggleMyList;
  final VoidCallback onPlay;

  const _EdgeToEdgeHeroSection({
    required this.heroMovie,
    required this.isSaved,
    required this.onToggleMyList,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 470,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Edge-to-Edge Poster Image
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

          // Multi-layer cinema vignette: top subtle shade & smooth gradient seamlessly fading into 0xFF0A0A0F
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0A0A0F).withValues(alpha: 0.35),
                    Colors.transparent,
                    const Color(0xFF0A0A0F).withValues(alpha: 0.4),
                    const Color(0xFF0A0A0F).withValues(alpha: 0.85),
                    const Color(0xFF0A0A0F),
                  ],
                  stops: const [0.0, 0.22, 0.55, 0.82, 1.0],
                ),
              ),
            ),
          ),

          // Hero Details & Sleek Buttons
          Positioned(
            left: 20,
            right: 20,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tag & IMDB Badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00F0FF).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFF00F0FF), width: 0.8),
                      ),
                      child: Text(
                        heroMovie.category.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF00F0FF),
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(LucideIcons.star, color: Color(0xFFFFB800), size: 13),
                    const SizedBox(width: 4),
                    Text(
                      '${heroMovie.rating} IMDB',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '·  ${heroMovie.releaseYear}  ·  Ultra 4K',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Title
                Text(
                  heroMovie.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                    height: 1.15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Description
                Text(
                  heroMovie.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // 3. SLEEKER, SMALLER, PREMIUM BUTTON STYLING (No chunky blocky look)
                Row(
                  children: [
                    // Sleek Watch Now Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onPlay,
                        borderRadius: BorderRadius.circular(20),
                        child: Ink(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00F0FF), Color(0xFF00B4D8)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00F0FF).withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.play, color: Colors.black, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Watch Now',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Sleek Translucent My List Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onToggleMyList,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF14141E).withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSaved
                                  ? const Color(0xFF00F0FF)
                                  : Colors.white.withValues(alpha: 0.25),
                              width: 0.9,
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
                              const SizedBox(width: 6),
                              Text(
                                isSaved ? 'In List' : 'My List',
                                style: TextStyle(
                                  color: isSaved ? const Color(0xFF00F0FF) : Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
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
// CLEANER ROWS WITH SUBTLE BORDER RADIUS & AMPLE MARGINS
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
        // Section Header with generous horizontal padding & clean margin
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
        // Proper spacing between title and cards
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
          SafeArea(
            bottom: false,
            child: Container(
              margin: const EdgeInsets.only(top: 8, bottom: 12),
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(
                  4,
                  (index) => Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 70,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 420,
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
