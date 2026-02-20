import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

class NidoApp extends StatelessWidget {
  const NidoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nido',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
