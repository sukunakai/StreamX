import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_screen.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'downloads_screen.dart';
import 'profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enforce 120Hz high refresh rate display mode on supported Android devices
  if (!kIsWeb && Platform.isAndroid) {
    try {
      await FlutterDisplayMode.setHighRefreshRate();
    } catch (e) {
      debugPrint('DisplayMode error: $e');
    }
  }

  // Initialize Firebase (safely handles when options are default or pre-configured)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init notice: $e');
  }

  // Initialize FlutterDownloader for background downloading
  try {
    await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  } catch (e) {
    debugPrint('Downloader init notice: $e');
  }

  // System UI Overlay Styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0A0F),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
        ChangeNotifierProvider(create: (_) => MovieCatalogProvider()),
        ChangeNotifierProvider(create: (_) => OfflineDownloadProvider()),
      ],
      child: const StreamXApp(),
    ),
  );
}

class StreamXApp extends StatelessWidget {
  const StreamXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StreamX',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00F0FF),
          secondary: Color(0xFF00F0FF),
          surface: Color(0xFF14141E),
          surfaceContainerHighest: Color(0xFF1F1F2E),
          onPrimary: Colors.black,
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0A0F),
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0A0A0F),
          selectedItemColor: Color(0xFF00F0FF),
          unselectedItemColor: Color(0xFF7E849E),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
        ),
        cardTheme: const CardTheme(
          color: Color(0xFF14141E),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    if (auth.isAuthenticated) {
      return const MainNavigation();
    }
    return const AuthScreen();
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    DownloadsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0A0A0F),
          border: Border(
            top: BorderSide(color: Color(0xFF1E1E2C), width: 1.0),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.home),
              activeIcon: Icon(LucideIcons.home, color: Color(0xFF00F0FF)),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.search),
              activeIcon: Icon(LucideIcons.search, color: Color(0xFF00F0FF)),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.downloadCloud),
              activeIcon: Icon(LucideIcons.downloadCloud, color: Color(0xFF00F0FF)),
              label: 'Offline',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.user),
              activeIcon: Icon(LucideIcons.user, color: Color(0xFF00F0FF)),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// MODELS & PROVIDERS
// -------------------------------------------------------------

class MovieItem {
  final String id;
  final String title;
  final String description;
  final String posterUrl;
  final String bannerUrl;
  final String videoUrl;
  final String category;
  final double rating;
  final int releaseYear;
  final int seasonsCount;
  final List<EpisodeItem> episodes;

  const MovieItem({
    required this.id,
    required this.title,
    required this.description,
    required this.posterUrl,
    required this.bannerUrl,
    required this.videoUrl,
    required this.category,
    required this.rating,
    required this.releaseYear,
    this.seasonsCount = 3,
    required this.episodes,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'posterUrl': posterUrl,
      'bannerUrl': bannerUrl,
      'videoUrl': videoUrl,
      'category': category,
      'rating': rating,
      'releaseYear': releaseYear,
      'seasonsCount': seasonsCount,
    };
  }
}

class EpisodeItem {
  final int episodeNumber;
  final String title;
  final String duration;
  final String videoUrl;

  const EpisodeItem({
    required this.episodeNumber,
    required this.title,
    required this.duration,
    required this.videoUrl,
  });
}

class AppAuthProvider extends ChangeNotifier {
  User? _user;
  String _displayName = 'CyberStreamer';
  String _email = 'verseshow94@gmail.com';
  bool _isAuthenticated = true; // Enabled by default for frictionless demo & testing

  User? get user => _user;
  String get displayName => _displayName;
  String get email => _email;
  bool get isAuthenticated => _isAuthenticated;

  AppAuthProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    try {
      FirebaseAuth.instance.authStateChanges().listen((User? u) {
        if (u != null) {
          _user = u;
          _email = u.email ?? _email;
          _displayName = u.displayName ?? _displayName;
          _isAuthenticated = true;
          notifyListeners();
        }
      });
    } catch (_) {}
  }

  Future<void> signIn(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      _user = credential.user;
      _email = _user?.email ?? email;
      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      // Local fallback for offline/development resilience
      _email = email.trim();
      _displayName = email.split('@').first;
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> updateProfileName(String newName) async {
    _displayName = newName;
    try {
      await _user?.updateDisplayName(newName);
    } catch (_) {}
    notifyListeners();
  }

  void switchEmailForTesting(String newEmail) {
    _email = newEmail;
    notifyListeners();
  }
}

class MovieCatalogProvider extends ChangeNotifier {
  final Set<String> _myListIds = {};
  List<MovieItem> _movies = [];
  bool _isLoading = false;

  Set<String> get myListIds => _myListIds;
  List<MovieItem> get movies => _movies;
  bool get isLoading => _isLoading;

  MovieCatalogProvider() {
    _loadSeedData();
    _listenToFirestore();
  }

  void _loadSeedData() {
    _movies = [
      MovieItem(
        id: 'streamx_indian_1',
        title: 'RRR: Rise of the Revolution',
        description: 'Two legendary revolutionaries embark on an epic fight against ruthless colonial rulers in an electrifying, action-packed spectacle.',
        posterUrl: 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=800&auto=format&fit=crop&q=80',
        bannerUrl: 'https://images.unsplash.com/photo-1485846234645-a62644f84728?w=1200&auto=format&fit=crop&q=80',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        category: 'Indian',
        rating: 9.8,
        releaseYear: 2025,
        seasonsCount: 1,
        episodes: const [
          EpisodeItem(episodeNumber: 1, title: 'The Fire Within', duration: '182m', videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'),
        ],
      ),
      MovieItem(
        id: 'streamx_indian_2',
        title: 'Cyber Mirzapur: King of Underworld',
        description: 'Rule, power, and high-stakes revenge collide in the ruthless digital crime syndicate of Uttar Pradesh.',
        posterUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800&auto=format&fit=crop&q=80',
        bannerUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1200&auto=format&fit=crop&q=80',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
        category: 'Drama',
        rating: 9.4,
        releaseYear: 2026,
        seasonsCount: 3,
        episodes: const [
          EpisodeItem(episodeNumber: 1, title: 'Kahin Ka Badla', duration: '52m', videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4'),
          EpisodeItem(episodeNumber: 2, title: 'Bhaukaal Reloaded', duration: '56m', videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4'),
        ],
      ),
      MovieItem(
        id: 'streamx_movie_1',
        title: 'Oppenheimer: The Atomic Core',
        description: 'The pulse-pounding true paradox of the enigmatic man who risked destroying the world in order to save it.',
        posterUrl: 'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?w=800&auto=format&fit=crop&q=80',
        bannerUrl: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=1200&auto=format&fit=crop&q=80',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
        category: 'Movies',
        rating: 9.6,
        releaseYear: 2025,
        seasonsCount: 1,
        episodes: const [
          EpisodeItem(episodeNumber: 1, title: 'Trinity Test', duration: '180m', videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4'),
        ],
      ),
      MovieItem(
        id: 'streamx_1',
        title: 'Cyberpulse: Neo Tokyo',
        description: 'In 2099, an underground neon synthesis hacker discovers a rogue neural core threatening the mega-metropolis.',
        posterUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800&auto=format&fit=crop&q=80',
        bannerUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=1200&auto=format&fit=crop&q=80',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        category: 'Sci-Fi',
        rating: 9.6,
        releaseYear: 2026,
        seasonsCount: 4,
        episodes: const [
          EpisodeItem(episodeNumber: 1, title: 'Neural Boot', duration: '48m', videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'),
          EpisodeItem(episodeNumber: 2, title: 'Ghost in Grid', duration: '52m', videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4'),
          EpisodeItem(episodeNumber: 3, title: 'Zero Day Override', duration: '45m', videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4'),
          EpisodeItem(episodeNumber: 4, title: 'Cybernetic Echoes', duration: '50m', videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4'),
        ],
      ),
      MovieItem(
        id: 'streamx_2',
        title: 'Quantum Abyss',
        description: 'Deep sea explorers uncover an ancient extraterrestrial monolith radiating temporal anomalies off the Mariana Trench.',
        posterUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&auto=format&fit=crop&q=80',
        bannerUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1200&auto=format&fit=crop&q=80',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
        category: 'Action',
        rating: 9.2,
        releaseYear: 2025,
        seasonsCount: 2,
        episodes: const [
          EpisodeItem(episodeNumber: 1, title: 'Descent 11000m', duration: '54m', videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4'),
          EpisodeItem(episodeNumber: 2, title: 'Black Current', duration: '49m', videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4'),
          EpisodeItem(episodeNumber: 3, title: 'The Monolith', duration: '58m', videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'),
        ],
      ),
      MovieItem(
        id: 'streamx_3',
        title: 'Chrono Blade: Ronin',
        description: 'A time-traveling samurai armed with an ionized katana tracks an immortal syndicate across three centuries.',
        posterUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800&auto=format&fit=crop&q=80',
        bannerUrl: 'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=1200&auto=format&fit=crop&q=80',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
        category: 'Anime',
        rating: 9.4,
        releaseYear: 2026,
        seasonsCount: 3,
        episodes: const [
          EpisodeItem(episodeNumber: 1, title: 'Blade of Dawn', duration: '24m', videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4'),
          EpisodeItem(episodeNumber: 2, title: 'Kyoto Paradox', duration: '24m', videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4'),
          EpisodeItem(episodeNumber: 3, title: 'Infinite Slash', duration: '26m', videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'),
        ],
      ),
      MovieItem(
        id: 'streamx_4',
        title: 'Solaris Protocol',
        description: 'When the first orbital dyson ring malfunctions, a lone repair engineer must confront an artificial consciousness with a soul.',
        posterUrl: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800&auto=format&fit=crop&q=80',
        bannerUrl: 'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?w=1200&auto=format&fit=crop&q=80',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        category: 'Sci-Fi',
        rating: 8.9,
        releaseYear: 2024,
        seasonsCount: 1,
        episodes: const [
          EpisodeItem(episodeNumber: 1, title: 'Coronal Flare', duration: '47m', videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4'),
          EpisodeItem(episodeNumber: 2, title: 'Stellar Heartbeat', duration: '51m', videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'),
        ],
      ),
    ];
  }

  void _listenToFirestore() {
    try {
      FirebaseFirestore.instance.collection('movies').snapshots().listen((snapshot) {
        final List<MovieItem> liveList = [];
        for (var doc in snapshot.docs) {
          final data = doc.data();
          liveList.add(
            MovieItem(
              id: doc.id,
              title: data['title'] ?? 'Untitled Stream',
              description: data['description'] ?? '',
              posterUrl: data['posterUrl'] ?? 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800',
              bannerUrl: data['posterUrl'] ?? 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=1200',
              videoUrl: data['videoUrl'] ?? 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
              category: data['category'] ?? 'Trending',
              rating: (data['rating'] as num?)?.toDouble() ?? 9.0,
              releaseYear: (data['releaseYear'] as num?)?.toInt() ?? 2026,
              seasonsCount: 1,
              episodes: [
                EpisodeItem(
                  episodeNumber: 1,
                  title: 'Pilot Premiere',
                  duration: '45m',
                  videoUrl: data['videoUrl'] ?? 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
                ),
              ],
            ),
          );
        }
        if (liveList.isNotEmpty) {
          _movies = [...liveList, ..._movies.where((m) => !liveList.any((l) => l.id == m.id))];
          notifyListeners();
        }
      });
    } catch (_) {}
  }

  void toggleMyList(String movieId, String? userEmail) {
    if (_myListIds.contains(movieId)) {
      _myListIds.remove(movieId);
    } else {
      _myListIds.add(movieId);
    }
    notifyListeners();

    // Sync to user's Firestore document
    if (userEmail != null && userEmail.isNotEmpty) {
      try {
        FirebaseFirestore.instance.collection('users').doc(userEmail).set({
          'watchlist': _myListIds.toList(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {}
    }
  }

  void addMovieDirectly(MovieItem movie) {
    _movies.insert(0, movie);
    notifyListeners();
  }
}

class DownloadedItem {
  final String id;
  final String title;
  final String filePath;
  final String posterUrl;
  final int fileSizeMb;
  final double progress; // 0.0 to 1.0
  final bool isCompleted;

  DownloadedItem({
    required this.id,
    required this.title,
    required this.filePath,
    required this.posterUrl,
    required this.fileSizeMb,
    required this.progress,
    required this.isCompleted,
  });

  DownloadedItem copyWith({
    double? progress,
    bool? isCompleted,
    String? filePath,
  }) {
    return DownloadedItem(
      id: id,
      title: title,
      filePath: filePath ?? this.filePath,
      posterUrl: posterUrl,
      fileSizeMb: fileSizeMb,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class OfflineDownloadProvider extends ChangeNotifier {
  final List<DownloadedItem> _downloads = [];

  List<DownloadedItem> get downloads => _downloads;

  OfflineDownloadProvider() {
    _initSampleDownloads();
  }

  void _initSampleDownloads() {
    _downloads.addAll([
      DownloadedItem(
        id: 'dl_1',
        title: 'Cyberpulse: Neo Tokyo - E1',
        filePath: 'local_storage/cyberpulse_e1.mp4',
        posterUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800',
        fileSizeMb: 420,
        progress: 1.0,
        isCompleted: true,
      ),
      DownloadedItem(
        id: 'dl_2',
        title: 'Quantum Abyss - E1',
        filePath: 'local_storage/quantum_abyss_e1.mp4',
        posterUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800',
        fileSizeMb: 680,
        progress: 0.74,
        isCompleted: false,
      ),
    ]);
  }

  void startDownload({
    required String title,
    required String posterUrl,
    required String videoUrl,
  }) {
    final newId = 'dl_${DateTime.now().millisecondsSinceEpoch}';
    final item = DownloadedItem(
      id: newId,
      title: title,
      filePath: 'downloads/$newId.mp4',
      posterUrl: posterUrl,
      fileSizeMb: 450,
      progress: 0.1,
      isCompleted: false,
    );
    _downloads.insert(0, item);
    notifyListeners();

    // Realistically advance download progress
    _simulateDownloadFlow(newId);
  }

  void _simulateDownloadFlow(String id) async {
    for (int step = 1; step <= 9; step++) {
      await Future.delayed(const Duration(milliseconds: 700));
      final index = _downloads.indexWhere((d) => d.id == id);
      if (index != -1) {
        final current = _downloads[index];
        _downloads[index] = current.copyWith(
          progress: (step * 0.1).clamp(0.0, 1.0),
          isCompleted: step == 10,
        );
        notifyListeners();
      }
    }
    final index = _downloads.indexWhere((d) => d.id == id);
    if (index != -1) {
      _downloads[index] = _downloads[index].copyWith(
        progress: 1.0,
        isCompleted: true,
      );
      notifyListeners();
    }
  }

  void removeDownload(String id) {
    _downloads.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}
