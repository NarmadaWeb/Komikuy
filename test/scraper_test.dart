import 'package:flutter_test/flutter_test.dart';
import 'package:komikuy/services/komiku_scraper.dart';

void main() {
  test('Scraper fetches home data', () async {
    final scraper = KomikuScraper();
    final data = await scraper.getHomeData();

    expect(data['popular'], isNotEmpty);
    expect(data['latest'], isNotEmpty);

    for (var comic in data['popular']!) {
      expect(comic.cover, isNotEmpty);
      expect(comic.cover.contains('lazy.jpg'), false,
          reason: 'Popular comic cover should not be placeholder lazy.jpg: ${comic.cover}');
      expect(comic.cover.startsWith('http'), true,
          reason: 'Popular comic cover should be full URL: ${comic.cover}');
    }

    for (var comic in data['latest']!) {
      expect(comic.cover, isNotEmpty);
      expect(comic.cover.contains('lazy.jpg'), false,
          reason: 'Latest comic cover should not be placeholder lazy.jpg: ${comic.cover}');
      expect(comic.cover.startsWith('http'), true,
          reason: 'Latest comic cover should be full URL: ${comic.cover}');
    }
  });

  test('Scraper searches for comics', () async {
    final scraper = KomikuScraper();
    try {
      final results = await scraper.searchComics('Solo Leveling');
      expect(results, isNotEmpty);
      for (var comic in results) {
        expect(comic.cover, isNotEmpty);
        expect(comic.cover.contains('lazy.jpg'), false,
            reason: 'Search result comic cover should not be placeholder lazy.jpg: ${comic.cover}');
        expect(comic.cover.startsWith('http'), true,
            reason: 'Search result comic cover should be full URL: ${comic.cover}');
      }
    } catch (e) {
      // Cloudflare may block requests in some environments.
      // If it fails, ensure it's a known failure type and not a code error.
      final errorMessage = e.toString();
      expect(
          errorMessage.contains('Failed to search') ||
              errorMessage.contains('Failed to fetch data'),
          true,
          reason: 'Search failed with unexpected error: $errorMessage');
    }
  });

  test('Scraper fetches comics by genre', () async {
    final scraper = KomikuScraper();
    try {
      final results = await scraper.getComicsByGenre('Action');
      expect(results, isNotEmpty);
      for (var comic in results) {
        expect(comic.cover, isNotEmpty);
        expect(comic.cover.contains('lazy.jpg'), false,
            reason: 'Genre comic cover should not be placeholder lazy.jpg: ${comic.cover}');
        expect(comic.cover.startsWith('http'), true,
            reason: 'Genre comic cover should be full URL: ${comic.cover}');
      }
    } catch (e) {
      final errorMessage = e.toString();
      expect(errorMessage.contains('Failed to fetch data'), true,
          reason: 'Genre fetch failed with unexpected error: $errorMessage');
    }
  });
}
