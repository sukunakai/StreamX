import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'main.dart';
import 'player_screen.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  Future<void> _deletePhysicalFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Physical file deletion error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final downloadProvider = context.watch<OfflineDownloadProvider>();
    final downloads = downloadProvider.downloads;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: const Text('Offline Vault'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.hardDrive, color: Color(0xFF00F0FF)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Storage Vault: 1.1 GB used of 64 GB internal storage'),
                  backgroundColor: Color(0xFF14141E),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: downloads.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14141E),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF262638)),
                    ),
                    child: const Icon(
                      LucideIcons.downloadCloud,
                      color: Color(0xFF7E849E),
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'No Offline Videos Yet',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap the download icon on any episode to watch offline.',
                    style: TextStyle(color: Color(0xFF7E849E), fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: downloads.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final item = downloads[index];

                // Swipe-to-Delete functionality
                return Dismissible(
                  key: Key(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(LucideIcons.trash2, color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Delete File',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  onDismissed: (direction) async {
                    await _deletePhysicalFile(item.filePath);
                    if (context.mounted) {
                      context.read<OfflineDownloadProvider>().removeDownload(item.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${item.title} deleted from storage'),
                          backgroundColor: const Color(0xFF14141E),
                        ),
                      );
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14141E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF1E1E2C)),
                    ),
                    child: Row(
                      children: [
                        // Poster Thumbnail with Stack Progress
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 80,
                            height: 60,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: item.posterUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(color: const Color(0xFF262638)),
                                  errorWidget: (_, __, ___) => Container(
                                    color: const Color(0xFF262638),
                                    child: const Icon(LucideIcons.film, color: Colors.white30),
                                  ),
                                ),
                                if (!item.isCompleted)
                                  Container(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    child: Center(
                                      child: SizedBox(
                                        width: 28,
                                        height: 28,
                                        child: CircularProgressIndicator(
                                          value: item.progress,
                                          strokeWidth: 3,
                                          color: const Color(0xFF00F0FF),
                                          backgroundColor: Colors.white24,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Title & Download Progress Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              if (item.isCompleted)
                                Row(
                                  children: [
                                    const Icon(LucideIcons.checkCircle2, color: Color(0xFF00F0FF), size: 14),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Ready · ${item.fileSizeMb} MB · 1080p',
                                      style: const TextStyle(color: Color(0xFF7E849E), fontSize: 12),
                                    ),
                                  ],
                                )
                              else
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Downloading: ${(item.progress * 100).toInt()}% (${(item.fileSizeMb * item.progress).toInt()} MB / ${item.fileSizeMb} MB)',
                                      style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 11),
                                    ),
                                    const SizedBox(height: 6),
                                    LinearProgressIndicator(
                                      value: item.progress,
                                      backgroundColor: const Color(0xFF262638),
                                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00F0FF)),
                                      minHeight: 4,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Action Icon: Play if completed, or circular progress
                        if (item.isCompleted)
                          IconButton(
                            icon: const Icon(LucideIcons.playCircle, color: Color(0xFF00F0FF), size: 30),
                            onPressed: () {
                              // Passes the absolute physical File path to player_screen.dart
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PlayerScreen(
                                    movie: MovieItem(
                                      id: item.id,
                                      title: item.title,
                                      description: 'Downloaded offline high-definition copy.',
                                      posterUrl: item.posterUrl,
                                      bannerUrl: item.posterUrl,
                                      videoUrl: item.filePath,
                                      category: 'Offline',
                                      rating: 9.9,
                                      releaseYear: 2026,
                                      episodes: [
                                        EpisodeItem(
                                          episodeNumber: 1,
                                          title: 'Offline Video',
                                          duration: 'Offline File',
                                          videoUrl: item.filePath,
                                        ),
                                      ],
                                    ),
                                    localFilePath: item.filePath,
                                  ),
                                ),
                              );
                            },
                          )
                        else
                          Text(
                            '${(item.progress * 100).toInt()}%',
                            style: const TextStyle(color: Color(0xFF00F0FF), fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
