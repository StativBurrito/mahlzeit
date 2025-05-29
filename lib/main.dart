import 'package:flutter/material.dart';
import 'package:mahlzeit_va/speisekarte.dart';
import 'package:mahlzeit_va/components_overview.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mahlzeit!',
      theme: PeiraoTheme.themeData(useDarkMode: true),
      home: Speisekarte()
    );
  }
}
