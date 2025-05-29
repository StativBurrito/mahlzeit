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
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    TextTheme textTheme = createTextTheme(context, "Barlow", "Barlow Semi Condensed");
    MaterialTheme theme = MaterialTheme(textTheme);
    return MaterialApp(
      title: 'Mahlzeit!',
      theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      home: Speisekarte()
    );
  }
}
