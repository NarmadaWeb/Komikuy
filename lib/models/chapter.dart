class Chapter {
  final String title;
  final String href;
  final String date;
  final String views;

  Chapter({
    required this.title,
    required this.href,
    required this.date,
    this.views = '',
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      title: json['title'] ?? '',
      href: json['href'] ?? '',
      date: json['date'] ?? '',
      views: json['views'] ?? '',
    );
  }
}
