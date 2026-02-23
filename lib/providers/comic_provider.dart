import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:komikuy/models/chapter.dart';
import 'package:komikuy/models/comic.dart';
import 'package:komikuy/models/comic_detail.dart';
import 'package:komikuy/services/komiku_scraper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComicProvider with ChangeNotifier {
  final KomikuScraper _scraper = KomikuScraper();

  // Theme State
  ThemeMode _themeMode = ThemeMode.system;

  // Home State
  List<Comic> _popularComics = [];
  List<Comic> _latestComics = [];
  bool _isLoadingHome = false;
  String _homeError = '';

  // Search State
  List<Comic> _searchResults = [];
  bool _isSearching = false;
  String _searchError = '';

  // Local Storage State
  List<Comic> _history = [];
  List<Comic> _bookmarks = [];

  // Getters
  ThemeMode get themeMode => _themeMode;

  List<Comic> get popularComics => _popularComics;
  List<Comic> get latestComics => _latestComics;
  bool get isLoadingHome => _isLoadingHome;
  String get homeError => _homeError;

  List<Comic> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String get searchError => _searchError;

  List<Comic> get history => _history;
  List<Comic> get bookmarks => _bookmarks;

  ComicProvider() {
    _loadStorage();
  }

  Future<void> _loadStorage() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Theme
    final themeIndex = prefs.getInt('theme_mode');
    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
    }

    // Load History
    final historyJson = prefs.getString('history');
    if (historyJson != null) {
      final List<dynamic> decoded = jsonDecode(historyJson);
      _history = decoded.map((e) => Comic.fromJson(e)).toList();
    }

    // Load Bookmarks
    final bookmarksJson = prefs.getString('bookmarks');
    if (bookmarksJson != null) {
      final List<dynamic> decoded = jsonDecode(bookmarksJson);
      _bookmarks = decoded.map((e) => Comic.fromJson(e)).toList();
    }
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('theme_mode', _themeMode.index);
  }

  Future<void> addToHistory(Comic comic, {Chapter? chapter}) async {
    // Check if it already exists to preserve previous reading state if not provided
    final existingIndex = _history.indexWhere((c) => c.href == comic.href);
    Comic newEntry = comic;

    if (chapter != null) {
      newEntry = comic.copyWith(
        lastReadChapter: chapter.title,
        lastReadChapterEndpoint: chapter.href,
      );
    } else if (existingIndex != -1) {
      // Preserve existing reading progress if just updating position
      final existing = _history[existingIndex];
      newEntry = comic.copyWith(
        lastReadChapter: existing.lastReadChapter,
        lastReadChapterEndpoint: existing.lastReadChapterEndpoint,
      );
    }

    if (existingIndex != -1) {
      _history.removeAt(existingIndex);
    }
    _history.insert(0, newEntry);
    if (_history.length > 50) _history.removeLast(); // Limit history

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('history', jsonEncode(_history.map((e) => e.toJson()).toList()));
  }

  Future<void> toggleBookmark(Comic comic) async {
    final index = _bookmarks.indexWhere((c) => c.href == comic.href);
    if (index != -1) {
      _bookmarks.removeAt(index);
    } else {
      _bookmarks.insert(0, comic);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('bookmarks', jsonEncode(_bookmarks.map((e) => e.toJson()).toList()));
  }

  bool isBookmarked(String href) {
    return _bookmarks.any((c) => c.href == href);
  }

  Future<void> clearHistory() async {
    _history.clear();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('history');
  }

  Future<void> fetchHomeData({bool refresh = false}) async {
    if (!refresh && (_popularComics.isNotEmpty || _latestComics.isNotEmpty)) return;

    _isLoadingHome = true;
    _homeError = '';
    notifyListeners();

    try {
      final data = await _scraper.getHomeData();
      _popularComics = data['popular'] ?? [];
      _latestComics = data['latest'] ?? [];
    } catch (e) {
      _homeError = e.toString();
    } finally {
      _isLoadingHome = false;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    _searchError = '';
    notifyListeners();

    try {
      _searchResults = await _scraper.searchComics(query);
    } catch (e) {
      _searchError = e.toString();
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    _searchError = '';
    notifyListeners();
  }

  // Helper for Detail/Reader (stateless fetch)
  Future<ComicDetail> getDetail(String url) => _scraper.getComicDetail(url);
  Future<List<String>> getChapterImages(String url) => _scraper.getChapterImages(url);
}
