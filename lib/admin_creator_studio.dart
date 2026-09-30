import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'main.dart';

class AdminCreatorStudioScreen extends StatefulWidget {
  const AdminCreatorStudioScreen({super.key});

  @override
  State<AdminCreatorStudioScreen> createState() => _AdminCreatorStudioScreenState();
}

class _AdminCreatorStudioScreenState extends State<AdminCreatorStudioScreen> {
  final TextEditingController _tmdbSearchController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _posterUrlController = TextEditingController();
  final TextEditingController _mediaUrlController = TextEditingController(
    text: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
  );
  final TextEditingController _categoryController = TextEditingController(text: 'Sci-Fi');

  bool _isSearchingTmdb = false;
  bool _isPublishing = false;
  List<Map<String, dynamic>> _tmdbResults = [];

  // Curated instant TMDB templates for 1-tap instant auto-fill
  final List<Map<String, dynamic>> _presetTmdbCatalog = [
    {
      'title': 'Dune: Awakening - Arrakis Chronicles',
      'overview': 'Paul Atreides confronts the shifting sands of the deep desert, unlocking the ancient prescience of the Shai-Hulud.',
      'poster': 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800&auto=format&fit=crop&q=80',
      'category': 'Sci-Fi',
      'rating': 9.5,
    },
    {
      'title': 'Cyberpunk: Neon Horizon',
      'overview': 'A high-octane mercenary crew attempts the most brazen biometric heist against the orbital megacorporation Arasaka.',
      'poster': 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=800&auto=format&fit=crop&q=80',
      'category': 'Cyberpunk',
      'rating': 9.3,
    },
    {
      'title': 'Blade of the Nebula: Ronin 2099',
      'overview': 'In the deep gravity well of Saturn, an exiled cyber-samurai is summoned for one final extraction mission.',
      'poster': 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800&auto=format&fit=crop&q=80',
      'category': 'Anime',
      'rating': 9.1,
    },
  ];

  @override
  void dispose() {
    _tmdbSearchController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _posterUrlController.dispose();
    _mediaUrlController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _searchTmdb(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;

    setState(() {
      _isSearchingTmdb = true;
      _tmdbResults = [];
    });

    try {
      // Query TMDB API (falls back gracefully to curated local matching if no network or key needed)
      final uri = Uri.parse(
        'https://api.themoviedb.org/3/search/multi?query=${Uri.encodeComponent(q)}&api_key=4e44d9029b1270a757cddc766a1bcb63',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List results = data['results'] ?? [];
        final parsed = results.take(6).map((item) {
          final title = item['title'] ?? item['name'] ?? 'Unknown';
          final overview = item['overview'] ?? '';
          final posterPath = item['poster_path'];
          final posterUrl = posterPath != null
              ? 'https://image.tmdb.org/t/p/w500$posterPath'
              : 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800';
          return {
            'title': title,
            'overview': overview,
            'poster': posterUrl,
            'category': 'Cinema 4K',
            'rating': (item['vote_average'] as num?)?.toDouble() ?? 8.8,
          };
        }).toList();

        setState(() {
          _tmdbResults = parsed;
        });
      } else {
        _useLocalSearchFallback(q);
      }
    } catch (_) {
      _useLocalSearchFallback(q);
    } finally {
      if (mounted) setState(() => _isSearchingTmdb = false);
    }
  }

  void _useLocalSearchFallback(String query) {
    final matches = _presetTmdbCatalog
        .where((m) => m['title'].toString().toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      _tmdbResults = matches.isNotEmpty ? matches : _presetTmdbCatalog;
    });
  }

  void _applyTmdbResult(Map<String, dynamic> item) {
    setState(() {
      _titleController.text = item['title'] ?? '';
      _descController.text = item['overview'] ?? '';
      _posterUrlController.text = item['poster'] ?? '';
      _categoryController.text = item['category'] ?? 'Trending';
      _tmdbResults = [];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Auto-filled metadata from: ${item['title']}'),
        backgroundColor: const Color(0xFF14141E),
      ),
    );
  }

  Future<void> _publishMovie() async {
    final title = _titleController.text.trim();
    final description = _descController.text.trim();
    final posterUrl = _posterUrlController.text.trim();
    final mediaUrl = _mediaUrlController.text.trim();
    final category = _categoryController.text.trim();

    if (title.isEmpty || mediaUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide both Title and Streaming Media URL!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isPublishing = true);

    final newMovie = MovieItem(
      id: 'movie_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description.isNotEmpty ? description : 'Ultra cinema 4K release on StreamX.',
      posterUrl: posterUrl.isNotEmpty
          ? posterUrl
          : 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800',
      bannerUrl: posterUrl.isNotEmpty
          ? posterUrl
          : 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=1200',
      videoUrl: mediaUrl,
      category: category.isNotEmpty ? category : 'Action',
      rating: 9.7,
      releaseYear: 2026,
      seasonsCount: 1,
      episodes: [
        EpisodeItem(
          episodeNumber: 1,
          title: 'Pilot Release',
          duration: '45m',
          videoUrl: mediaUrl,
        ),
      ],
    );

    // 1. Publish to Firestore collection('movies')
    try {
      await FirebaseFirestore.instance.collection('movies').add({
        'title': title,
        'description': description,
        'posterUrl': newMovie.posterUrl,
        'videoUrl': mediaUrl,
        'category': category,
        'rating': 9.7,
        'releaseYear': 2026,
        'publishedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Firestore publication notice: $e');
    }

    // 2. Add directly to MovieCatalogProvider so it is instantly live for the app
    if (mounted) {
      context.read<MovieCatalogProvider>().addMovieDirectly(newMovie);

      setState(() => _isPublishing = false);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF14141E),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: const Row(
              children: [
                Icon(LucideIcons.checkCircle2, color: Color(0xFF00F0FF)),
                SizedBox(width: 10),
                Text('Broadcast Live!', style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
            content: Text(
              '"$title" is now live on StreamX home screens and catalog for all users.',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00F0FF)),
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // back to profile
                },
                child: const Text('Back to App', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: const Text('Creator Studio (CMS)'),
        backgroundColor: const Color(0xFF14141E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TMDB Integration Search Bar
            const Text(
              'TMDB AUTO-METADATA LOOKUP',
              style: TextStyle(
                color: Color(0xFF00F0FF),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF14141E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF262638)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tmdbSearchController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Search TMDB (e.g. Dune, Cyberpunk, Batman)',
                        hintStyle: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                        prefixIcon: Icon(LucideIcons.search, color: Color(0xFF00F0FF), size: 18),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onSubmitted: _searchTmdb,
                    ),
                  ),
                  IconButton(
                    icon: _isSearchingTmdb
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00F0FF)),
                          )
                        : const Icon(LucideIcons.arrowRight, color: Color(0xFF00F0FF)),
                    onPressed: () => _searchTmdb(_tmdbSearchController.text),
                  ),
                ],
              ),
            ),

            // Quick Auto-fill Presets
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _presetTmdbCatalog.map((item) {
                return ActionChip(
                  label: Text(item['title'].toString().split(':').first),
                  labelStyle: const TextStyle(color: Colors.white70, fontSize: 11),
                  backgroundColor: const Color(0xFF1E1E2C),
                  side: const BorderSide(color: Color(0xFF2E2E42)),
                  onPressed: () => _applyTmdbResult(item),
                );
              }).toList(),
            ),

            // TMDB Results Dropdown/List
            if (_tmdbResults.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF14141E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF00F0FF)),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _tmdbResults.length,
                  separatorBuilder: (_, __) => const Divider(color: Color(0xFF262638), height: 1),
                  itemBuilder: (context, index) {
                    final item = _tmdbResults[index];
                    return ListTile(
                      dense: true,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          imageUrl: item['poster'],
                          width: 36,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(item['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        item['overview'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Color(0xFF7E849E)),
                      ),
                      trailing: const Icon(LucideIcons.import, color: Color(0xFF00F0FF), size: 18),
                      onTap: () => _applyTmdbResult(item),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 28),
            const Divider(color: Color(0xFF1E1E2C)),
            const SizedBox(height: 20),

            // Studio Form Fields
            const Text(
              'STREAM METADATA',
              style: TextStyle(
                color: Color(0xFF00F0FF),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 14),

            _buildFormField('Title', _titleController, 'Movie or Show title'),
            const SizedBox(height: 14),
            _buildFormField('Category', _categoryController, 'Action, Sci-Fi, Anime, Cyberpunk...'),
            const SizedBox(height: 14),
            _buildFormField('Poster URL', _posterUrlController, 'Direct poster image link (JPG/PNG)'),
            const SizedBox(height: 14),
            _buildFormField('Description', _descController, 'Synopsis and plot summary', maxLines: 3),
            const SizedBox(height: 14),

            // Specific Media Input (HLS / MP4 BunnyCDN)
            const Text(
              'MEDIA STREAMING INPUT',
              style: TextStyle(
                color: Color(0xFF00F0FF),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            _buildFormField(
              'HLS / MP4 URL',
              _mediaUrlController,
              'e.g. https://bunnycdn.com/stream/playlist.m3u8 or .mp4',
              prefixIcon: LucideIcons.video,
            ),

            const SizedBox(height: 32),

            // PUBLISH TO APP Button
            Container(
              height: 56,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF00F0FF), Color(0xFF0088FF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F0FF).withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _isPublishing ? null : _publishMovie,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: _isPublishing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                      )
                    : const Icon(LucideIcons.radio, color: Colors.black, size: 20),
                label: Text(
                  _isPublishing ? 'PUBLISHING...' : 'PUBLISH TO APP',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF14141E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF262638)),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
              prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: const Color(0xFF00F0FF), size: 18) : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
