import 'package:flutter/material.dart';
import 'package:komikuy/screens/search_screen.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  final List<Map<String, dynamic>> genres = const [
    {'name': 'Action', 'icon': Icons.sports_martial_arts, 'color': Colors.orange},
    {'name': 'Romance', 'icon': Icons.favorite, 'color': Colors.pink},
    {'name': 'Isekai', 'icon': Icons.auto_fix_high, 'color': Colors.purple},
    {'name': 'Comedy', 'icon': Icons.sentiment_very_satisfied, 'color': Colors.yellow},
    {'name': 'Fantasy', 'icon': Icons.fort, 'color': Colors.blue},
    {'name': 'Horror', 'icon': Icons.coronavirus, 'color': Colors.red},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse by Genre', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search genres...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              onSubmitted: (value) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen(initialQuery: value)));
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: genres.length,
                itemBuilder: (context, index) {
                  final genre = genres[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen(initialQuery: genre['name'].toString())));
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: (genre['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: (genre['color'] as Color).withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: genre['color'] as Color,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(genre['icon'] as IconData, color: Colors.white, size: 32),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            genre['name'].toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
