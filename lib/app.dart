import 'package:flutter/material.dart';

import 'repositories/items_repository.dart';
import 'screens/home_screen.dart';

class NidoApp extends StatelessWidget {
  const NidoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = ItemsRepository.instance;

    return MaterialApp(
      title: 'Nido',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFC695B2)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8EFF4),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8EFF4),
          foregroundColor: Color(0xFF2B2328),
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF2B2328),
          foregroundColor: Colors.white,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: HomeScreen(repository: repository),
    );
  }
}
