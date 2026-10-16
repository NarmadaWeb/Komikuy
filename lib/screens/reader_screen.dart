import 'dart:async';
import 'package:komikuy/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:komikuy/models/chapter.dart';
import 'package:komikuy/models/comic.dart';
import 'package:komikuy/services/komiku_scraper.dart';
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
  late int _currentIndex;
  late final ScrollController _scrollController;

  bool _showUI = true;
  bool _isAutoScrolling = false;
  double _autoScrollSpeed = 1.0;
  Timer? _autoScrollTimer;

  static const List<double> _speeds = [0.5, 1.0, 1.5, 2.0, 3.0];

  double _accumulatedOverscroll = 0.0;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _currentChapter = widget.initialChapter;
    _currentIndex =
        widget.chapters.indexWhere((c) => c.href == _currentChapter.href);
    _imagesFuture =
        context.read<ComicProvider>().getChapterImages(_currentChapter.href);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context
            .read<ComicProvider>()
            .addToHistory(widget.comic, chapter: _currentChapter);
      }
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _navigateToChapter(Chapter chapter, {bool keepAutoScroll = false}) {
    if (!keepAutoScroll) {
      _stopAutoScroll();
    }
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    setState(() {
      _currentChapter = chapter;
      _currentIndex =
          widget.chapters.indexWhere((c) => c.href == _currentChapter.href);
      _imagesFuture =
          context.read<ComicProvider>().getChapterImages(_currentChapter.href);
    });
    context
        .read<ComicProvider>()
        .addToHistory(widget.comic, chapter: _currentChapter);
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    setState(() {
      _isAutoScrolling = true;
    });
    _autoScrollTimer =
        Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!_isAutoScrolling || !_scrollController.hasClients) return;
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      final step = _autoScrollSpeed * 1.5;
      if (maxScroll > 0 && currentScroll + step >= maxScroll) {
        final currentIndex = _currentIndex;
        final hasNext = currentIndex > 0;
        if (hasNext && !_isNavigating) {
          _isNavigating = true;
          _navigateToChapter(widget.chapters[currentIndex - 1],
              keepAutoScroll: true);
          Future.delayed(const Duration(milliseconds: 500), () {
            _isNavigating = false;
          });
        } else if (!hasNext) {
          _scrollController.jumpTo(maxScroll);
          _stopAutoScroll();
        }
      } else if (maxScroll > 0) {
        _scrollController.jumpTo(currentScroll + step);
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
    if (_isAutoScrolling) {
      setState(() {
        _isAutoScrolling = false;
      });
    }
  }

  void _toggleAutoScroll() {
    if (_isAutoScrolling) {
      _stopAutoScroll();
    } else {
      _startAutoScroll();
    }
  }

  void _cycleSpeed() {
    setState(() {
      final currentIndex = _speeds.indexOf(_autoScrollSpeed);
      final nextIndex = (currentIndex + 1) % _speeds.length;
      _autoScrollSpeed = _speeds[nextIndex];
    });
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _scrollController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleUI() {
    setState(() {
      _showUI = !_showUI;
    });
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification) {
      if (notification.direction != ScrollDirection.idle && _isAutoScrolling) {
        _stopAutoScroll();
      }
    }

    final currentIndex = _currentIndex;
    final hasNext = currentIndex > 0;
    final hasPrev =
        currentIndex != -1 && currentIndex < widget.chapters.length - 1;

    if (notification is OverscrollNotification) {
      _accumulatedOverscroll += notification.overscroll;
      if (!_isNavigating) {
        // Dragging/pulling UP at bottom -> next chapter (newer)
        if (_scrollController.hasClients &&
            _scrollController.position.pixels >=
                _scrollController.position.maxScrollExtent - 10 &&
            _accumulatedOverscroll > 40 &&
            hasNext) {
          _isNavigating = true;
          _accumulatedOverscroll = 0;
          _navigateToChapter(widget.chapters[currentIndex - 1]);
          Future.delayed(const Duration(milliseconds: 500), () {
            _isNavigating = false;
          });
        }
        // Dragging/pulling DOWN at top -> previous chapter (older)
        else if (_scrollController.hasClients &&
            _scrollController.position.pixels <= 10 &&
            _accumulatedOverscroll < -40 &&
            hasPrev) {
          _isNavigating = true;
          _accumulatedOverscroll = 0;
          _navigateToChapter(widget.chapters[currentIndex + 1]);
          Future.delayed(const Duration(milliseconds: 500), () {
            _isNavigating = false;
          });
        }
      }
    }

    if (notification is ScrollUpdateNotification) {
      if (!_isNavigating && notification.scrollDelta != null) {
        if (_scrollController.hasClients &&
            _scrollController.position.pixels >=
                _scrollController.position.maxScrollExtent - 10 &&
            notification.scrollDelta! > 0) {
          _accumulatedOverscroll += notification.scrollDelta!;
          if (_accumulatedOverscroll > 40 && hasNext) {
            _isNavigating = true;
            _accumulatedOverscroll = 0;
            _navigateToChapter(widget.chapters[currentIndex - 1]);
            Future.delayed(const Duration(milliseconds: 500), () {
              _isNavigating = false;
            });
          }
        } else if (_scrollController.hasClients &&
            _scrollController.position.pixels <= 10 &&
            notification.scrollDelta! < 0) {
          _accumulatedOverscroll += notification.scrollDelta!;
          if (_accumulatedOverscroll < -40 && hasPrev) {
            _isNavigating = true;
            _accumulatedOverscroll = 0;
            _navigateToChapter(widget.chapters[currentIndex + 1]);
            Future.delayed(const Duration(milliseconds: 500), () {
              _isNavigating = false;
            });
          }
        }
      }
    }

    if (notification is ScrollEndNotification) {
      _accumulatedOverscroll = 0.0;
    }

    return false;
  }

  void _showChaptersSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ListView.builder(
          itemCount: widget.chapters.length,
          itemBuilder: (context, index) {
            final chapter = widget.chapters[index];
            final isCurrent = chapter.href == _currentChapter.href;
            return ListTile(
              title: Text(
                chapter.title,
                style: TextStyle(
                  color: isCurrent ? Colors.blue : Colors.white,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _navigateToChapter(chapter);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final cacheWidth =
        (mediaQuery.size.width * mediaQuery.devicePixelRatio).round();

    final currentIndex = _currentIndex;
    final hasNext = currentIndex > 0;
    final hasPrev =
        currentIndex != -1 && currentIndex < widget.chapters.length - 1;

    final l10n = AppLocalizations.of(context)!;
    final formattedSpeed =
        '${_autoScrollSpeed.toStringAsFixed(1).replaceAll('.0', '')}x';

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          GestureDetector(
            onTap: _toggleUI,
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScrollNotification,
              child: FutureBuilder<List<String>>(
                future: _imagesFuture,
                key: ValueKey(_currentChapter.href),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.white)));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                        child: Text(l10n.noImagesFound,
                            style: const TextStyle(color: Colors.white)));
                  }

                  final images = snapshot.data!;
                  return ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.zero,
                    // ignore: deprecated_member_use
                    cacheExtent: 2000.0,
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        httpHeaders: KomikuScraper.getImageHeaders(
                            referer: _currentChapter.href),
                        imageUrl: images[index],
                        fit: BoxFit.fitWidth,
                        width: double.infinity,
                        memCacheWidth: cacheWidth,
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
                          child: const Center(
                              child: Icon(Icons.broken_image,
                                  color: Colors.white)),
                        ),
                      );
                    },
                  );
                },
              ),
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
              title: Text(_currentChapter.title,
                  style: const TextStyle(color: Colors.white, fontSize: 16)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () {
                    context.read<ComicProvider>().toggleBookmark(widget.comic);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.toggledBookmark)));
                  },
                ),
              ],
            ),
          ),

          // Floating Auto-Scroll Control when UI is hidden
          if (!_showUI && _isAutoScrolling)
            Positioned(
              bottom: 24,
              right: 16,
              child: Material(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.pause, color: Colors.white),
                        onPressed: _stopAutoScroll,
                        tooltip: 'Pause',
                      ),
                      InkWell(
                        onTap: _cycleSpeed,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            formattedSpeed,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: hasPrev
                        ? () {
                            _navigateToChapter(
                                widget.chapters[currentIndex + 1]);
                          }
                        : null,
                    icon: Icon(Icons.skip_previous,
                        color: hasPrev ? Colors.white : Colors.grey),
                    label: Text(l10n.prev,
                        style: TextStyle(
                            color: hasPrev ? Colors.white : Colors.grey)),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: _toggleAutoScroll,
                        icon: Icon(
                          _isAutoScrolling ? Icons.pause : Icons.play_arrow,
                          color: _isAutoScrolling ? Colors.blue : Colors.white,
                        ),
                        tooltip: l10n.autoScroll,
                      ),
                      TextButton(
                        onPressed: _cycleSpeed,
                        child: Text(
                          formattedSpeed,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _showChaptersSheet,
                        icon: const Icon(Icons.list, color: Colors.white),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: hasNext
                        ? () {
                            _navigateToChapter(
                                widget.chapters[currentIndex - 1]);
                          }
                        : null,
                    label: Text(l10n.next,
                        style: TextStyle(
                            color: hasNext ? Colors.white : Colors.grey)),
                    icon: Icon(Icons.skip_next,
                        color: hasNext ? Colors.white : Colors.grey),
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
