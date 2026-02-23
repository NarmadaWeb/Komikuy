class Comic {
  final String title;
  final String href;
  final String cover;
  final String type; // Manga, Manhwa, Manhua
  final String latestChapter;
  final String timeAgo;
  final String? genre;
  final bool isColor;
  final String? rating; // For "Hot" section if available, or just use as is
  final String? lastReadChapter;
  final String? lastReadChapterEndpoint;

  Comic({
    required this.title,
    required this.href,
    required this.cover,
    this.type = 'Unknown',
    this.latestChapter = '',
    this.timeAgo = '',
    this.genre,
    this.isColor = false,
    this.rating,
    this.lastReadChapter,
    this.lastReadChapterEndpoint,
  });

  factory Comic.fromJson(Map<String, dynamic> json) {
    return Comic(
      title: json['title'] ?? '',
      href: json['href'] ?? '',
      cover: json['cover'] ?? '',
      type: json['type'] ?? 'Unknown',
      latestChapter: json['latestChapter'] ?? '',
      timeAgo: json['timeAgo'] ?? '',
      genre: json['genre'],
      isColor: json['isColor'] ?? false,
      rating: json['rating'],
      lastReadChapter: json['lastReadChapter'],
      lastReadChapterEndpoint: json['lastReadChapterEndpoint'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'href': href,
      'cover': cover,
      'type': type,
      'latestChapter': latestChapter,
      'timeAgo': timeAgo,
      'genre': genre,
      'isColor': isColor,
      'rating': rating,
      'lastReadChapter': lastReadChapter,
      'lastReadChapterEndpoint': lastReadChapterEndpoint,
    };
  }

  Comic copyWith({
    String? title,
    String? href,
    String? cover,
    String? type,
    String? latestChapter,
    String? timeAgo,
    String? genre,
    bool? isColor,
    String? rating,
    String? lastReadChapter,
    String? lastReadChapterEndpoint,
  }) {
    return Comic(
      title: title ?? this.title,
      href: href ?? this.href,
      cover: cover ?? this.cover,
      type: type ?? this.type,
      latestChapter: latestChapter ?? this.latestChapter,
      timeAgo: timeAgo ?? this.timeAgo,
      genre: genre ?? this.genre,
      isColor: isColor ?? this.isColor,
      rating: rating ?? this.rating,
      lastReadChapter: lastReadChapter ?? this.lastReadChapter,
      lastReadChapterEndpoint: lastReadChapterEndpoint ?? this.lastReadChapterEndpoint,
    );
  }
}
