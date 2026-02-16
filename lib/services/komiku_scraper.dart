import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:komikuy/models/comic.dart';
import 'package:komikuy/models/comic_detail.dart';
import 'package:komikuy/models/chapter.dart';

class KomikuScraper {
  static const String baseUrl = 'https://komiku.org';

  // Helper to fix relative URLs
  String _fixUrl(String url) {
    if (url.startsWith('//')) {
      return 'https:$url';
    }
    if (url.startsWith('/')) {
      return '$baseUrl$url';
    }
    return url;
  }

  // Helper to extract image source (data-src or src)
  String _extractImage(Element element) {
    Element? img;
    if (element.localName == 'img') {
      img = element;
    } else {
      img = element.querySelector('img');
    }

    if (img == null) return '';

    // Check data-src first for lazy loaded images
    var src = img.attributes['data-src'];
    if (src != null && src.isNotEmpty) return _fixUrl(src);

    src = img.attributes['src'];
    return src != null ? _fixUrl(src) : '';
  }

  Future<Map<String, List<Comic>>> getHomeData() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to load home page');
      }

      var document = parse(response.body);

      List<Comic> popularComics = [];
      List<Comic> latestComics = [];

      // Parse Popular (Hot) - Section "Manga Populer", "Manhwa Populer", etc.
      var popularArticles = document.querySelectorAll('.ls12 .ls2');
      for (var article in popularArticles) {
        try {
          var titleEl = article.querySelector('h3 a');
          var title = titleEl?.text.trim() ?? 'Unknown';
          var href = _fixUrl(titleEl?.attributes['href'] ?? '');
          var cover = _extractImage(article);

          var typeInfo = article.querySelector('.ls2t');
          var typeText = typeInfo?.text.trim() ?? '';

          var chapterEl = article.querySelector('.ls2l');
          var latestChapter = chapterEl?.text.trim() ?? '';

          popularComics.add(Comic(
            title: title,
            href: href,
            cover: cover,
            type: 'Hot',
            latestChapter: latestChapter,
            rating: typeText,
          ));
        } catch (e) {
          // print('Error parsing popular comic: $e');
        }
      }

      // Parse Latest Updates
      var latestArticles = document.querySelectorAll('article.ls4');
      for (var article in latestArticles) {
        try {
          var titleEl = article.querySelector('h3 a');
          var title = titleEl?.text.trim() ?? 'Unknown';
          var href = _fixUrl(titleEl?.attributes['href'] ?? '');
          var cover = _extractImage(article);

          var infoEl = article.querySelector('.ls4s');
          var infoText = infoEl?.text.trim() ?? ''; // "Manhwa Fantasi 3 jam lalu"

          var type = 'Manga';
          if (infoText.toLowerCase().contains('manhwa')) type = 'Manhwa';
          if (infoText.toLowerCase().contains('manhua')) type = 'Manhua';

          var timeAgo = '';
           var parts = infoText.split(' ');
           if (parts.length > 2) {
             timeAgo = parts.sublist(parts.length - 3).join(' ');
           }

          var chapterEl = article.querySelector('.ls24');
          var latestChapter = chapterEl?.text.trim() ?? '';

          var upEl = article.querySelector('.up');
          var upCount = upEl?.text.trim() ?? '';

          var colorEl = article.querySelector('.warna');
          var isColor = colorEl != null;

          latestComics.add(Comic(
            title: title,
            href: href,
            cover: cover,
            type: type,
            latestChapter: latestChapter,
            timeAgo: timeAgo.isNotEmpty ? timeAgo : infoText,
            isColor: isColor,
            rating: upCount
          ));
        } catch (e) {
            // print('Error parsing latest comic: $e');
        }
      }

      return {
        'popular': popularComics,
        'latest': latestComics,
      };

    } catch (e) {
      // print('Error fetching home data: $e');
      rethrow;
    }
  }

  Future<List<Comic>> searchComics(String query) async {
    // Use the API endpoint for search
    final url = 'https://api.komiku.org/?s=$query&post_type=manga';
    try {
      final response = await http.get(Uri.parse(url));
       if (response.statusCode != 200) {
        throw Exception('Failed to search');
      }

      var document = parse(response.body);
      List<Comic> results = [];

      var articles = document.querySelectorAll('.bge');

      for (var article in articles) {
         try {
            var titleEl = article.querySelector('.kan h3');
            if (titleEl == null) continue;

            var title = titleEl.text.trim();
            var hrefEl = article.querySelector('.kan a');
            var href = _fixUrl(hrefEl?.attributes['href'] ?? '');
            var cover = _extractImage(article);

            var typeEl = article.querySelector('.tpe1_inf b');
            var type = typeEl?.text.trim() ?? 'Unknown';

            var genreEl = article.querySelector('.tpe1_inf');
            var genre = genreEl?.text.replaceAll(type, '').trim() ?? '';

            var latestChapter = '';
            // Look for "Terbaru"
            var newEls = article.querySelectorAll('.new1');
            for (var newEl in newEls) {
               if (newEl.text.contains('Terbaru')) {
                 latestChapter = newEl.querySelector('span:last-child')?.text.trim() ?? '';
               }
            }
            if (latestChapter.isEmpty && newEls.isNotEmpty) {
               // Fallback to last one
               latestChapter = newEls.last.querySelector('span:last-child')?.text.trim() ?? '';
            }

            var p = article.querySelector('.kan p');
            var timeAgo = p?.text.trim() ?? '';

            results.add(Comic(
                title: title,
                href: href,
                cover: cover,
                type: type,
                latestChapter: latestChapter,
                timeAgo: timeAgo,
                genre: genre
            ));

         } catch (e) {
             // print('Error parsing search result: $e');
         }
      }

      return results;

    } catch (e) {
      // print('Error searching: $e');
      rethrow;
    }
  }

  Future<ComicDetail> getComicDetail(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to load detail page');
      }
      var document = parse(response.body);

      var titleEl = document.querySelector('#Judul h1');
      var title = titleEl?.text.trim().replaceFirst('Komik ', '') ?? 'Unknown';

      var coverEl = document.querySelector('.ims img');
      var cover = '';
      if (coverEl != null) {
         cover = _extractImage(coverEl);
      }

      // Info Table
      var author = '';
      var status = '';
      var type = '';
      var rating = '';

      var tableRows = document.querySelectorAll('table.inftable tr');
      for (var row in tableRows) {
        var tds = row.querySelectorAll('td');
        if (tds.length >= 2) {
          var key = tds[0].text.trim();
          var value = tds[1].text.trim();
          if (key.contains('Jenis')) type = value;
          if (key.contains('Pengarang')) author = value;
          if (key.contains('Status')) status = value;
        }
      }

      // Description
      var desc = '';
      var descEls = document.querySelectorAll('#Judul p');
      for (var p in descEls) {
          if (p.className != 'j2' && p.text.length > 30) {
              desc = p.text.trim();
              break; // Take the first long paragraph
          }
      }

      // Chapters
      List<Chapter> chapters = [];
      var chapterRows = document.querySelectorAll('#Daftar_Chapter tbody tr');
      for (var row in chapterRows) {
         var titleCell = row.querySelector('.judulseries a');
         if (titleCell != null) {
            var chTitle = titleCell.querySelector('span')?.text.trim() ?? titleCell.text.trim();
            var chHref = _fixUrl(titleCell.attributes['href'] ?? '');

            var dateCell = row.querySelector('.tanggalseries');
            var date = dateCell?.text.trim() ?? '';

            var viewCell = row.querySelector('.pembaca i');
            var views = viewCell?.text.trim() ?? '';

            chapters.add(Chapter(
                title: chTitle,
                href: chHref,
                date: date,
                views: views
            ));
         }
      }

      return ComicDetail(
        title: title,
        cover: cover,
        type: type,
        description: desc,
        author: author,
        status: status,
        rating: rating,
        chapters: chapters
      );

    } catch (e) {
      // print('Error fetching detail: $e');
      rethrow;
    }
  }

  Future<List<String>> getChapterImages(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to load chapter page');
      }
      var document = parse(response.body);

      List<String> images = [];
      var imgContainer = document.querySelector('#Baca_Komik');
      if (imgContainer != null) {
          var imgs = imgContainer.querySelectorAll('img');
          for (var img in imgs) {
              var src = _extractImage(img);
              if (src.isNotEmpty) {
                  images.add(src);
              }
          }
      }
      return images;

    } catch (e) {
      // print('Error fetching chapter images: $e');
      rethrow;
    }
  }
}
