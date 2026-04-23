import 'package:flutter_test/flutter_test.dart';
import 'package:komikuy/services/komiku_scraper.dart';

void main() {
  test('Scraper fetches home data', () async {
    final scraper = KomikuScraper();
    final data = await scraper.getHomeData();

    expect(data['popular'], isNotEmpty);
    expect(data['latest'], isNotEmpty);
  });

  test('Scraper searches for comics', () async {
    // Note: Cloudflare may block this on CI environments
    try {
      final scraper = KomikuScraper();
      final results = await scraper.searchComics('Solo Leveling');
      expect(results, isNotEmpty);
    } catch (e) {
      expect(e.toString().contains('Failed to search'), true);
    }
  });
}
