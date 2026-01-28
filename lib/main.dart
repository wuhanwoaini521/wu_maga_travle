import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/comic_theme.dart';
import 'presentation/screens/home/home_screen.dart'; // 使用 Google Maps 版本

void main() {
  runApp(
    const ProviderScope(
      child: MangaTravelApp(),
    ),
  );
}

class MangaTravelApp extends StatelessWidget {
  const MangaTravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '漫游记',
      debugShowCheckedModeBanner: false,
      theme: ComicTheme.lightTheme,
      darkTheme: ComicTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}
