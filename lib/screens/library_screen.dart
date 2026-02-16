import 'package:flutter/material.dart';
import 'package:komikuy/providers/comic_provider.dart';
import 'package:komikuy/screens/detail_screen.dart';
import 'package:komikuy/widgets/comic_card.dart';
import 'package:provider/provider.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<ComicProvider>(
        builder: (context, provider, child) {
          if (provider.bookmarks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.collections_bookmark_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Your library is empty', style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('Bookmark comics to see them here', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Use 2 for mobile standard
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.6,
            ),
            itemCount: provider.bookmarks.length,
            itemBuilder: (context, index) {
              final comic = provider.bookmarks[index];
              return ComicCard(
                comic: comic,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(url: comic.href))),
              );
            },
          );
        },
      ),
    );
  }
}
