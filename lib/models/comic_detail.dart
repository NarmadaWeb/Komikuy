import 'package:komikuy/models/chapter.dart';
import 'package:komikuy/models/comic.dart';

class ComicDetail {
  final String title;
  final String cover;
  final String type;
  final String description;
  final String author;
  final String status;
  final String rating;
  final List<String> genres;
  final List<Chapter> chapters;
  final List<Comic> recommendations;

  ComicDetail({
    required this.title,
    required this.cover,
    required this.type,
    required this.description,
    this.author = '',
    this.status = '',
    this.rating = '',
    this.genres = const [],
    this.chapters = const [],
    this.recommendations = const [],
  });

  Comic toComic(String href) {
      return Comic(
          title: title,
          href: href,
          cover: cover,
          type: type,
          latestChapter: chapters.isNotEmpty ? chapters.first.title : '',
          timeAgo: '', // Not available in detail
          rating: rating
      );
  }
}
