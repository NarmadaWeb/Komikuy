import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:komikuy/providers/comic_provider.dart';
import 'package:komikuy/screens/main_screen.dart';

void main() {
  runApp(const KomikuyApp());
}

class KomikuyApp extends StatelessWidget {
  const KomikuyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ComicProvider()),
      ],
      child: MaterialApp(
        title: 'Komikuy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0a63c2),
            primary: const Color(0xFF0a63c2),
            secondary: const Color(0xFF084a91),
            surface: const Color(0xFFf5f7f8),
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.plusJakartaSansTextTheme(),
          scaffoldBackgroundColor: const Color(0xFFf5f7f8),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0a63c2),
            primary: const Color(0xFF0a63c2),
            secondary: const Color(0xFF084a91),
            surface: const Color(0xFF101922),
            brightness: Brightness.dark,
          ),
          textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
          scaffoldBackgroundColor: const Color(0xFF101922),
        ),
        themeMode: ThemeMode.system,
        home: const MainScreen(),
      ),
    );
  }
}
