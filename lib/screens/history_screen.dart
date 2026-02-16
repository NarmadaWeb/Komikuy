import 'package:flutter/material.dart';
import 'package:komikuy/providers/comic_provider.dart';
import 'package:komikuy/screens/detail_screen.dart';
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
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(url: comic.href))),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
