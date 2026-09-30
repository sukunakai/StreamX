import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'main.dart';
import 'player_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _recentSearches = [];
  String _selectedCategory = 'All';
  String _query = '';

  final List<String> _categories = const [
    'All',
    'Sci-Fi',
    'Action',
    'Anime',
    'Cyberpunk',
    '4K Ultra',
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('streamx_recent_searches') ?? ['Cyberpulse', 'Quantum Abyss', 'Chrono Blade'];
      setState(() => _recentSearches = list);
    } catch (_) {}
  }

  Future<void> _addRecentSearch(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _recentSearches.remove(trimmed);
      _recentSearches.insert(0, trimmed);
      if (_recentSearches.length > 8) _recentSearches = _recentSearches.sublist(0, 8);
      await prefs.setStringList('streamx_recent_searches', _recentSearches);
      setState(() {});
    } catch (_) {}
  }

  Future<void> _clearRecentSearch(String text) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _recentSearches.remove(text);
      await prefs.setStringList('streamx_recent_searches', _recentSearches);
      setState(() {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final movieCatalog = context.watch<MovieCatalogProvider>();
    final allMovies = movieCatalog.movies;

    final filteredMovies = allMovies.where((movie) {
      final matchesQuery = _query.isEmpty ||
          movie.title.toLowerCase().contains(_query.toLowerCase()) ||
          movie.description.toLowerCase().contains(_query.toLowerCase());
      final matchesCat = _selectedCategory == 'All' ||
          movie.category.toLowerCase() == _selectedCategory.toLowerCase();
      return matchesQuery && matchesCat;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: const Text('Search & Explore'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom Search TextField
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF14141E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF262638)),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                onChanged: (val) {
                  setState(() => _query = val);
                },
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) {
                    _addRecentSearch(val);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Search movies, series, anime, 4K...',
                  hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                  prefixIcon: const Icon(LucideIcons.search, color: Color(0xFF00F0FF), size: 20),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(LucideIcons.x, color: Colors.white60, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // Categories Filter Chip Row Below Search Bar
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat == _selectedCategory;
                return FilterChip(
                  label: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedCategory = cat);
                  },
                  backgroundColor: const Color(0xFF14141E),
                  selectedColor: const Color(0xFF00F0FF),
                  checkmarkColor: Colors.black,
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF00F0FF) : const Color(0xFF262638),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Main View: Either Recent Searches (if query is empty) or Results List
          Expanded(
            child: _query.isEmpty
                ? ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      if (_recentSearches.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'RECENT SEARCHES',
                              style: TextStyle(
                                color: Color(0xFF7E849E),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.remove('streamx_recent_searches');
                                setState(() => _recentSearches = []);
                              },
                              child: const Text(
                                'Clear All',
                                style: TextStyle(color: Color(0xFF00F0FF), fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ..._recentSearches.map(
                          (item) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(LucideIcons.history, color: Color(0xFF7E849E), size: 18),
                            title: Text(
                              item,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            trailing: IconButton(
                              icon: const Icon(LucideIcons.x, color: Color(0xFF7E849E), size: 16),
                              onPressed: () => _clearRecentSearch(item),
                            ),
                            onTap: () {
                              _searchController.text = item;
                              setState(() => _query = item);
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      const Text(
                        'DISCOVER TOP PICKS',
                        style: TextStyle(
                          color: Color(0xFF7E849E),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 14),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: allMovies.length,
                        itemBuilder: (context, index) {
                          final m = allMovies[index];
                          return _SearchMovieCard(movie: m);
                        },
                      ),
                    ],
                  )
                : filteredMovies.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.searchX, color: Color(0xFF7E849E), size: 48),
                            const SizedBox(height: 14),
                            Text(
                              'No streams found for "$_query"',
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Try checking spelling or changing the filter chip.',
                              style: TextStyle(color: Color(0xFF7E849E), fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: filteredMovies.length,
                        itemBuilder: (context, index) {
                          final m = filteredMovies[index];
                          return _SearchMovieCard(movie: m);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _SearchMovieCard extends StatelessWidget {
  final MovieItem movie;

  const _SearchMovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlayerScreen(movie: movie),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF14141E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1E1E2C)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: movie.posterUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: const Color(0xFF14141E)),
                    errorWidget: (_, __, ___) => Container(
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
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${movie.rating} ★',
                        style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${movie.releaseYear} · ${movie.category}',
                    style: const TextStyle(color: Color(0xFF7E849E), fontSize: 11),
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
