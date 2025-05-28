import 'package:flutter/material.dart';
import 'package:mahlzeit_va/speisekarte.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mahlzeit!',
      home: Speisekarte()
    );
  }
}
