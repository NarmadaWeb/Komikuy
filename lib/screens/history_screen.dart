import 'package:flutter/material.dart';
import 'package:komikuy/providers/comic_provider.dart';
import 'package:komikuy/screens/detail_screen.dart';
import 'package:komikuy/screens/reader_screen.dart';
import 'package:komikuy/widgets/comic_card.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear History'),
                  content: const Text('Are you sure you want to clear your reading history?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        context.read<ComicProvider>().clearHistory();
                        Navigator.pop(ctx);
                      },
                      child: const Text('Clear', style: TextStyle(color: Colors.red))
                    ),
                  ],
                )
              );
            },
          ),
        ],
      ),
      body: Consumer<ComicProvider>(
        builder: (context, provider, child) {
          if (provider.history.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No history yet', style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('Start reading to build your history', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.history.length,
            itemBuilder: (context, index) {
              final comic = provider.history[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ComicCard(
                  comic: comic,
                  isHorizontal: true,
                  showLastRead: true,
                  onTap: () async {
                    if (comic.lastReadChapterEndpoint != null) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) => const Center(child: CircularProgressIndicator()),
                      );

                      try {
                        final detail = await provider.getDetail(comic.href);
                        final chapterIndex = detail.chapters.indexWhere((c) => c.href == comic.lastReadChapterEndpoint);

                        if (context.mounted) {
                          Navigator.pop(context); // Dismiss loading
                          if (chapterIndex != -1) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReaderScreen(
                                  comic: comic,
                                  chapters: detail.chapters,
                                  initialChapter: detail.chapters[chapterIndex],
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(url: comic.href)));
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          Navigator.pop(context); // Dismiss loading
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                          Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(url: comic.href)));
                        }
                      }
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(url: comic.href)));
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
