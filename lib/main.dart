import 'package:flutter/material.dart';
import 'package:lookapp/main/wrappers/home_wrapper.dart';
import 'package:lookapp/themes/app_theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LooK',
      theme: AppTheme.light,
      home: const Scaffold(
        body: HomeWrapper(),
      ),
    );
  }
}
