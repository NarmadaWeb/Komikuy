import 'package:flutter/material.dart';
import 'package:komikuy/providers/comic_provider.dart';
import 'package:komikuy/screens/detail_screen.dart';
import 'package:komikuy/widgets/comic_card.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _controller.text = widget.initialQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _search();
      });
    } else {
      _focusNode.requestFocus();
    }
  }

  void _search() {
    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      context.read<ComicProvider>().search(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search manga, authors...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                context.read<ComicProvider>().clearSearch();
              },
            ),
          ),
          onSubmitted: (_) => _search(),
          textInputAction: TextInputAction.search,
        ),
      ),
      body: Consumer<ComicProvider>(
        builder: (context, provider, child) {
          if (provider.isSearching) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.searchError.isNotEmpty) {
             return Center(child: Text('Error: ${provider.searchError}'));
          }

          if (provider.searchResults.isEmpty) {
            if (_controller.text.isNotEmpty) {
               return const Center(child: Text('No results found'));
            }
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.search, size: 64, color: Colors.grey),
                   SizedBox(height: 16),
                   Text('Find your favorite comics', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.searchResults.length,
            itemBuilder: (context, index) {
              final comic = provider.searchResults[index];
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
