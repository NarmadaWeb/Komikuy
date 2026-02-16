import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:komikuy/models/chapter.dart';
import 'package:komikuy/models/comic.dart';
import 'package:komikuy/providers/comic_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ReaderScreen extends StatefulWidget {
  final Chapter chapter;
  final Comic comic;

  const ReaderScreen({super.key, required this.chapter, required this.comic});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late Future<List<String>> _imagesFuture;
  bool _showUI = true;

  @override
  void initState() {
    super.initState();
    _imagesFuture = context.read<ComicProvider>().getChapterImages(widget.chapter.href);
    context.read<ComicProvider>().addToHistory(widget.comic);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          GestureDetector(
            onTap: _toggleUI,
            child: FutureBuilder<List<String>>(
              future: _imagesFuture,
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
              title: Text(widget.chapter.title, style: const TextStyle(color: Colors.white, fontSize: 16)),
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
                    onPressed: () {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Previous Chapter')));
                    },
                    icon: const Icon(Icons.skip_previous, color: Colors.white),
                    label: const Text('Prev', style: TextStyle(color: Colors.white)),
                  ),
                   TextButton.icon(
                    onPressed: () {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Next Chapter')));
                    },
                    label: const Text('Next', style: TextStyle(color: Colors.white)),
                    icon: const Icon(Icons.skip_next, color: Colors.white),
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
