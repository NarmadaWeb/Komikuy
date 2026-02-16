import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komikuy/models/chapter.dart';
import 'package:komikuy/models/comic.dart';
import 'package:komikuy/providers/comic_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ReaderScreen extends StatefulWidget {
  final Chapter initialChapter;
  final List<Chapter> chapters;
  final Comic comic;

  const ReaderScreen({
    super.key,
    required this.initialChapter,
    required this.chapters,
    required this.comic,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late Chapter _currentChapter;
  late Future<List<String>> _imagesFuture;
  bool _showUI = true;

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.initialChapter;
    _imagesFuture = context.read<ComicProvider>().getChapterImages(_currentChapter.href);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ComicProvider>().addToHistory(widget.comic);
      }
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _navigateToChapter(Chapter chapter) {
    setState(() {
      _currentChapter = chapter;
      _imagesFuture = context.read<ComicProvider>().getChapterImages(_currentChapter.href);
    });
    context.read<ComicProvider>().addToHistory(widget.comic);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleUI() {
    setState(() {
      _showUI = !_showUI;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.chapters.indexWhere((c) => c.href == _currentChapter.href);

    // Assuming standard manga list order: Newest (Index 0) -> Oldest (Index N)
    // "Next" usually means reading forward in the story (e.g. Ch 1 -> Ch 2).
    // If list is [Ch 10, Ch 9, ... Ch 1]
    // Ch 1 is at Index N. Next is Ch 2 (Index N-1).
    // So Next is index - 1.
    // Prev is index + 1.

    final hasNext = currentIndex > 0;
    final hasPrev = currentIndex != -1 && currentIndex < widget.chapters.length - 1;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          GestureDetector(
            onTap: _toggleUI,
            child: FutureBuilder<List<String>>(
              future: _imagesFuture,
              key: ValueKey(_currentChapter.href), // Force rebuild on chapter change
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No images found', style: TextStyle(color: Colors.white)));
                }

                final images = snapshot.data!;
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return CachedNetworkImage(
                      imageUrl: images[index],
                      fit: BoxFit.fitWidth,
                      width: double.infinity,
                      placeholder: (context, url) => SizedBox(
                        height: 300,
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[900]!,
                          highlightColor: Colors.grey[800]!,
                          child: Container(color: Colors.black),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 200,
                        color: Colors.grey[900],
                        child: const Center(child: Icon(Icons.broken_image, color: Colors.white)),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Top Bar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: _showUI ? 0 : -80,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.black.withValues(alpha: 0.8),
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(_currentChapter.title, style: const TextStyle(color: Colors.white, fontSize: 16)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () {
                    context.read<ComicProvider>().toggleBookmark(widget.comic);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Toggled Bookmark')));
                  },
                ),
              ],
            ),
          ),

          // Bottom Bar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: _showUI ? 0 : -80,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withValues(alpha: 0.8),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: hasPrev ? () {
                       _navigateToChapter(widget.chapters[currentIndex + 1]);
                    } : null,
                    icon: Icon(Icons.skip_previous, color: hasPrev ? Colors.white : Colors.grey),
                    label: Text('Prev', style: TextStyle(color: hasPrev ? Colors.white : Colors.grey)),
                  ),
                   TextButton.icon(
                    onPressed: hasNext ? () {
                       _navigateToChapter(widget.chapters[currentIndex - 1]);
                    } : null,
                    label: Text('Next', style: TextStyle(color: hasNext ? Colors.white : Colors.grey)),
                    icon: Icon(Icons.skip_next, color: hasNext ? Colors.white : Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
