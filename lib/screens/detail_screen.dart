import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:komikuy/models/comic_detail.dart';
import 'package:komikuy/providers/comic_provider.dart';
import 'package:komikuy/screens/reader_screen.dart';
import 'package:provider/provider.dart';

class DetailScreen extends StatefulWidget {
  final String url;
  const DetailScreen({super.key, required this.url});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<ComicDetail> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = context.read<ComicProvider>().getDetail(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<ComicDetail>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
          }

          final detail = snapshot.data!;
          final comic = detail.toComic(widget.url);
          final provider = context.watch<ComicProvider>();
          final isBookmarked = provider.isBookmarked(widget.url);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                actions: [
                  IconButton(
                    icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                    onPressed: () {
                      provider.toggleBookmark(comic);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isBookmarked ? 'Removed from Library' : 'Added to Library')),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {},
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: detail.cover,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: Colors.grey[300]),
                        errorWidget: (context, url, error) => Container(color: Colors.grey, child: const Icon(Icons.broken_image)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (detail.type.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  detail.type.toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              detail.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.person, color: Colors.white70, size: 14),
                                const SizedBox(width: 4),
                                Expanded(child: Text(detail.author, style: const TextStyle(color: Colors.white70), overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                             const SizedBox(height: 4),
                             Row(
                              children: [
                                const Icon(Icons.info_outline, color: Colors.white70, size: 14),
                                const SizedBox(width: 4),
                                Text(detail.status, style: const TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (detail.chapters.isNotEmpty) {
                                  // Assuming chapters are Descending, so Last is First Chapter
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => ReaderScreen(chapter: detail.chapters.last, comic: comic)),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 4,
                                shadowColor: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Start Reading', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 2),
                                  Text(
                                    detail.chapters.isNotEmpty ? detail.chapters.last.title : 'N/A',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                if (detail.chapters.isNotEmpty) {
                                   Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => ReaderScreen(chapter: detail.chapters.first, comic: comic)),
                                  );
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                side: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.5)),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Latest Update', style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                                  const SizedBox(height: 2),
                                  Text(
                                    detail.chapters.isNotEmpty ? detail.chapters.first.title : 'N/A',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text('Synopsis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        detail.description.isNotEmpty ? detail.description : 'No synopsis available.',
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8), height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                           const Text('Chapters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                           Text('${detail.chapters.length} Chapters', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final chapter = detail.chapters[index];
                    return ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ReaderScreen(chapter: chapter, comic: comic)),
                        );
                      },
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.menu_book, color: Theme.of(context).primaryColor, size: 20),
                      ),
                      title: Text(chapter.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(chapter.date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      trailing: const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                    );
                  },
                  childCount: detail.chapters.length,
                ),
              ),
               const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
            ],
          );
        },
      ),
    );
  }
}
