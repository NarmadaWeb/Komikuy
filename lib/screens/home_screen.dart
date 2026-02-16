import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:komikuy/models/comic.dart';
import 'package:komikuy/providers/comic_provider.dart';
import 'package:komikuy/screens/detail_screen.dart';
import 'package:komikuy/screens/search_screen.dart';
import 'package:komikuy/widgets/comic_card.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ComicProvider>().fetchHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ComicProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingHome && provider.popularComics.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.homeError.isNotEmpty && provider.popularComics.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.homeError),
                  ElevatedButton(
                    onPressed: () => provider.fetchHomeData(refresh: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchHomeData(refresh: true),
            child: CustomScrollView(
              slivers: [
                _buildAppBar(context),
                if (provider.popularComics.isNotEmpty)
                   SliverToBoxAdapter(
                     child: Padding(
                       padding: const EdgeInsets.only(top: 16, bottom: 8),
                       child: _buildFeaturedCarousel(provider.popularComics.take(5).toList()),
                     ),
                   ),
                if (provider.popularComics.length > 5) ...[
                  SliverToBoxAdapter(
                    child: _buildSectionHeader('Hot Updates', icon: Icons.local_fire_department, color: Colors.orange),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 250,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: provider.popularComics.length - 5,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final comic = provider.popularComics[index + 5];
                          return SizedBox(
                            width: 130,
                            child: ComicCard(
                                comic: comic,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(url: comic.href)))
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                if (provider.latestComics.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _buildSectionHeader('Latest Updates', icon: Icons.schedule, color: Colors.blue),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final comic = provider.latestComics[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: ComicCard(
                              comic: comic,
                              isHorizontal: true,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => DetailScreen(url: comic.href)),
                              ),
                            ),
                          );
                        },
                        childCount: provider.latestComics.length,
                      ),
                    ),
                  ),
                ],
                const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      centerTitle: false,
      title: Row(
        children: [
          Text('Komikuy', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
        ),
      ],
    );
  }

  Widget _buildFeaturedCarousel(List<Comic> comics) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 220,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.85,
            aspectRatio: 16/9,
          ),
          items: comics.map((comic) {
            return Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(url: comic.href))),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: CachedNetworkImage(
                            imageUrl: comic.cover,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(color: Colors.grey[300]),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
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
                              Text(
                                comic.title,
                                style: const TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4)),
                                    child: const Text('HOT', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    comic.latestChapter,
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {IconData? icon, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (icon != null) Icon(icon, color: color, size: 20),
          if (icon != null) const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
