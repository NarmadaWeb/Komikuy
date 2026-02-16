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
    };
  }
}
