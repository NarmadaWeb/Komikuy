import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komikuy/l10n/app_localizations.dart';
import 'package:komikuy/models/chapter.dart';
import 'package:komikuy/models/comic.dart';
import 'package:komikuy/providers/comic_provider.dart';
import 'package:komikuy/screens/reader_screen.dart';
import 'package:komikuy/screens/settings_screen.dart';
import 'package:provider/provider.dart';

void main() {
  final sampleComic = Comic(
    title: 'Test Comic',
    href: '/manga/test-comic/',
    cover: 'https://example.com/cover.jpg',
    type: 'Manga',
  );

  final sampleChapters = [
    Chapter(title: 'Chapter 2', href: '/ch/2/', date: '1 day ago'),
    Chapter(title: 'Chapter 1', href: '/ch/1/', date: '2 days ago'),
  ];

  Widget buildTestWidget(Widget child) {
    return ChangeNotifierProvider(
      create: (_) => ComicProvider(),
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('id'),
        ],
        home: child,
      ),
    );
  }

  testWidgets('ReaderScreen renders auto scroll and speed controls',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        ReaderScreen(
          initialChapter: sampleChapters[1],
          chapters: sampleChapters,
          comic: sampleComic,
        ),
      ),
    );
    await tester.pump();

    // Verify play button and speed text '1x' are present
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.text('1x'), findsOneWidget);

    // Tap speed button to change speed to 1.5x
    await tester.tap(find.text('1x'));
    await tester.pump();
    expect(find.text('1.5x'), findsOneWidget);

    // Tap play button to toggle auto-scroll ON
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();
    expect(find.byIcon(Icons.pause), findsWidgets);

    // Tap pause button to toggle auto-scroll OFF before test ends
    await tester.tap(find.byIcon(Icons.pause).first);
    await tester.pump();
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });

  testWidgets('SettingsScreen displays version 1.3.0',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget(const SettingsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Version 1.3.0'), findsOneWidget);
  });
}
