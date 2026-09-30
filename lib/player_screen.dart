import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';

import 'main.dart';

class PlayerScreen extends StatefulWidget {
  final MovieItem movie;
  final String? localFilePath;

  const PlayerScreen({
    super.key,
    required this.movie,
    this.localFilePath,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = true;
  bool _showControls = true;
  bool _isLandscape = false;
  BoxFit _videoFit = BoxFit.contain;
  double _playbackSpeed = 1.0;

  // Gestures for Brightness (left side) and Volume (right side)
  double _brightness = 0.7;
  double _volume = 0.8;
  String? _gestureIndicatorText;

  int _selectedSeason = 1;
  int _currentEpisodeIndex = 0;

  @override
  void initState() {
    super.initState();
    _initPlayer(
      widget.localFilePath != null
          ? widget.localFilePath!
          : (widget.movie.episodes.isNotEmpty
              ? widget.movie.episodes.first.videoUrl
              : widget.movie.videoUrl),
    );
  }

  Future<void> _initPlayer(String mediaUrl) async {
    setState(() {
      _isInitialized = false;
    });

    _controller?.pause();
    _controller?.dispose();

    if (widget.localFilePath != null || mediaUrl.startsWith('/') || mediaUrl.startsWith('file://')) {
      final cleanPath = mediaUrl.replaceFirst('file://', '');
      _controller = VideoPlayerController.file(File(cleanPath));
    } else {
      _controller = VideoPlayerController.networkUrl(Uri.parse(mediaUrl));
    }

    try {
      await _controller!.initialize();
      _controller!.setLooping(true);
      _controller!.setPlaybackSpeed(_playbackSpeed);
      _controller!.play();
      _controller!.addListener(() {
        if (mounted) setState(() {});
      });
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isPlaying = true;
        });
      }
    } catch (e) {
      debugPrint('Video Player error: $e');
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _controller?.dispose();
    super.dispose();
  }

  void _toggleOrientation() {
    setState(() => _isLandscape = !_isLandscape);
    if (_isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  void _cycleSpeed() {
    setState(() {
      if (_playbackSpeed == 1.0) {
        _playbackSpeed = 1.5;
      } else if (_playbackSpeed == 1.5) {
        _playbackSpeed = 2.0;
      } else {
        _playbackSpeed = 1.0;
      }
    });
    _controller?.setPlaybackSpeed(_playbackSpeed);
  }

  void _cycleAspectFit() {
    setState(() {
      _videoFit = _videoFit == BoxFit.contain ? BoxFit.cover : BoxFit.contain;
    });
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details, double screenWidth) {
    final isLeft = details.globalPosition.dx < (screenWidth / 2);
    final delta = -details.primaryDelta! / 200.0;

    setState(() {
      if (isLeft) {
        _brightness = (_brightness + delta).clamp(0.1, 1.0);
        _gestureIndicatorText = 'Brightness: ${(_brightness * 100).toInt()}%';
      } else {
        _volume = (_volume + delta).clamp(0.0, 1.0);
        _gestureIndicatorText = 'Volume: ${(_volume * 100).toInt()}%';
        _controller?.setVolume(_volume);
      }
    });
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() => _gestureIndicatorText = null);
      }
    });
  }

  void _showSeasonsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF14141E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Season',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0xFF262638), height: 1),
              ListView.builder(
                shrinkWrap: true,
                itemCount: widget.movie.seasonsCount,
                itemBuilder: (context, index) {
                  final sNum = index + 1;
                  final isCurrent = sNum == _selectedSeason;
                  return ListTile(
                    leading: Icon(
                      LucideIcons.tv,
                      color: isCurrent ? const Color(0xFF00F0FF) : Colors.white60,
                    ),
                    title: Text(
                      'Season $sNum',
                      style: TextStyle(
                        color: isCurrent ? const Color(0xFF00F0FF) : Colors.white,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      '${widget.movie.episodes.length} Episodes · Ultra HD',
                      style: const TextStyle(color: Color(0xFF7E849E), fontSize: 12),
                    ),
                    trailing: isCurrent ? const Icon(LucideIcons.check, color: Color(0xFF00F0FF)) : null,
                    onTap: () {
                      setState(() => _selectedSeason = sNum);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _triggerDownload(BuildContext context) async {
    // Request storage / notification permissions cleanly
    try {
      await [Permission.storage, Permission.notification].request();
    } catch (_) {}

    final currentEpisode = widget.movie.episodes[_currentEpisodeIndex];
    if (context.mounted) {
      context.read<OfflineDownloadProvider>().startDownload(
            title: '${widget.movie.title} - E${currentEpisode.episodeNumber}',
            posterUrl: widget.movie.posterUrl,
            videoUrl: currentEpisode.videoUrl,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(LucideIcons.downloadCloud, color: Color(0xFF00F0FF)),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Downloading ${widget.movie.title} - Episode ${currentEpisode.episodeNumber}...'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF14141E),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Column(
          children: [
            // Video Player Container
            AspectRatio(
              aspectRatio: _isLandscape ? 16 / 9 : 16 / 9,
              child: GestureDetector(
                onTap: () => setState(() => _showControls = !_showControls),
                onVerticalDragUpdate: (details) => _handleVerticalDragUpdate(details, screenWidth),
                onVerticalDragEnd: _handleVerticalDragEnd,
                child: Container(
                  color: Colors.black,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Video Surface
                      if (_isInitialized && _controller != null)
                        FittedBox(
                          fit: _videoFit,
                          child: SizedBox(
                            width: _controller!.value.size.width > 0 ? _controller!.value.size.width : 1280,
                            height: _controller!.value.size.height > 0 ? _controller!.value.size.height : 720,
                            child: VideoPlayer(_controller!),
                          ),
                        )
                      else
                        const Center(
                          child: CircularProgressIndicator(color: Color(0xFF00F0FF)),
                        ),

                      // Gesture Feedback Overlay
                      if (_gestureIndicatorText != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF00F0FF)),
                          ),
                          child: Text(
                            _gestureIndicatorText!,
                            style: const TextStyle(
                              color: Color(0xFF00F0FF),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),

                      // Custom Minimalist Video Controls
                      if (_showControls) ...[
                        Container(color: Colors.black.withValues(alpha: 0.45)),

                        // Top Toolbar: Back, Title, Landscape, Stretch, Speed
                        Positioned(
                          top: 10,
                          left: 10,
                          right: 10,
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
                                onPressed: () => Navigator.pop(context),
                              ),
                              Expanded(
                                child: Text(
                                  widget.movie.title,
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Speed (1x, 1.5x, 2x) Icon
                              InkWell(
                                onTap: _cycleSpeed,
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.white30),
                                  ),
                                  child: Text(
                                    '${_playbackSpeed}x',
                                    style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Stretch/Crop Toggle Icon
                              IconButton(
                                icon: Icon(
                                  _videoFit == BoxFit.cover ? LucideIcons.minimize : LucideIcons.maximize,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                onPressed: _cycleAspectFit,
                              ),
                              // Landscape / Orientation Toggle Icon
                              IconButton(
                                icon: const Icon(LucideIcons.screenShare, color: Colors.white, size: 18),
                                onPressed: _toggleOrientation,
                              ),
                            ],
                          ),
                        ),

                        // Center Play / Pause Button
                        Center(
                          child: IconButton(
                            iconSize: 48,
                            icon: Icon(
                              _isPlaying ? LucideIcons.pauseCircle : LucideIcons.playCircle,
                              color: const Color(0xFF00F0FF),
                            ),
                            onPressed: () {
                              setState(() {
                                if (_isPlaying) {
                                  _controller?.pause();
                                  _isPlaying = false;
                                } else {
                                  _controller?.play();
                                  _isPlaying = true;
                                }
                              });
                            },
                          ),
                        ),

                        // Bottom Scrub Bar
                        if (_isInitialized && _controller != null)
                          Positioned(
                            bottom: 8,
                            left: 16,
                            right: 16,
                            child: VideoProgressIndicator(
                              _controller!,
                              allowScrubbing: true,
                              colors: const VideoProgressColors(
                                playedColor: Color(0xFF00F0FF),
                                bufferedColor: Color(0xFF2E2E42),
                                backgroundColor: Color(0xFF14141E),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Metadata & Episodes Content
            if (!_isLandscape)
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Title and Metadata Info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.movie.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    '${widget.movie.releaseYear} · ${widget.movie.category} · 4K HDR',
                                    style: const TextStyle(color: Color(0xFF7E849E), fontSize: 12),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00F0FF).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${widget.movie.rating} ★',
                                      style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // "Season X" Pill Button -> triggers showModalBottomSheet
                        InkWell(
                          onTap: _showSeasonsBottomSheet,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF14141E),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF00F0FF), width: 1.2),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Season $_selectedSeason',
                                  style: const TextStyle(
                                    color: Color(0xFF00F0FF),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(LucideIcons.chevronDown, color: Color(0xFF00F0FF), size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),
                    Text(
                      widget.movie.description,
                      style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                    ),

                    const SizedBox(height: 24),
                    const Divider(color: Color(0xFF1E1E2C)),
                    const SizedBox(height: 16),

                    // Episodes Header & Download Action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'EPISODES',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        // Download Icon next to episode row
                        InkWell(
                          onTap: () => _triggerDownload(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF14141E),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF262638)),
                            ),
                            child: const Row(
                              children: [
                                Icon(LucideIcons.download, color: Color(0xFF00F0FF), size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Download Episode',
                                  style: TextStyle(color: Color(0xFF00F0FF), fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // SQUARE Episode Buttons: strictly square, exact text "E1", "E2", "E3"
                    SizedBox(
                      height: 58,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: widget.movie.episodes.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final ep = widget.movie.episodes[index];
                          final isCurrent = index == _currentEpisodeIndex;
                          return InkWell(
                            onTap: () {
                              setState(() => _currentEpisodeIndex = index);
                              _initPlayer(ep.videoUrl);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 58,
                              height: 58, // strictly square
                              decoration: BoxDecoration(
                                color: const Color(0xFF14141E),
                                borderRadius: BorderRadius.circular(10),
                                border: isCurrent
                                    ? Border.all(color: const Color(0xFF00F0FF), width: 2) // glowing neon cyan border
                                    : Border.all(color: const Color(0xFF262638), width: 1),
                                boxShadow: isCurrent
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF00F0FF).withValues(alpha: 0.4),
                                          blurRadius: 10,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  'E${ep.episodeNumber}', // strictly "E1", "E2", "E3"
                                  style: TextStyle(
                                    color: isCurrent ? const Color(0xFF00F0FF) : Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),
                    // Active episode title & duration
                    if (_currentEpisodeIndex < widget.movie.episodes.length) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF14141E),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.disc, color: Color(0xFF00F0FF), size: 18),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Episode ${widget.movie.episodes[_currentEpisodeIndex].episodeNumber}: ${widget.movie.episodes[_currentEpisodeIndex].title}',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  Text(
                                    'Duration: ${widget.movie.episodes[_currentEpisodeIndex].duration} · 1080p Stream',
                                    style: const TextStyle(color: Color(0xFF7E849E), fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
}
