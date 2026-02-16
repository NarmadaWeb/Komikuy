import 'package:flutter_test/flutter_test.dart';
import 'package:komikuy/services/komiku_scraper.dart';

void main() {
  test('Scraper fetches comic detail', () async {
    final scraper = KomikuScraper();
    final detail = await scraper.getComicDetail('https://komiku.org/manga/superstar-from-age-0/');

    expect(detail.title, contains('Superstar From Age 0'));
    expect(detail.chapters, isNotEmpty);
  });

  test('Scraper fetches chapter images', () async {
    final scraper = KomikuScraper();
    final images = await scraper.getChapterImages('https://komiku.org/superstar-from-age-0-chapter-86/');

    expect(images, isNotEmpty);
  });
}
