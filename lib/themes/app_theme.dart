import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      fontFamily: 'Montserrat',
      primaryColor: const Color.fromARGB(255, 238, 54, 115),
      highlightColor: Colors.white,
      dividerColor: Colors.white,
      scaffoldBackgroundColor: Colors.grey.shade200,
      // const Color.fromARGB(255, 170, 0, 255)
      // textTheme: TextTheme(
      //   displayLarge: TextStyle(fontFamily: platformFont),
      //   displayMedium: TextStyle(fontFamily: platformFont),
      //   displaySmall: TextStyle(fontFamily: platformFont),
      //   headlineLarge: TextStyle(fontFamily: platformFont),
      //   headlineMedium: TextStyle(fontFamily: platformFont),
      //   headlineSmall: TextStyle(fontFamily: platformFont),
      //   titleLarge: TextStyle(fontFamily: platformFont),
      //   titleMedium: TextStyle(fontFamily: platformFont),
      //   titleSmall: TextStyle(fontFamily: platformFont),
      //   bodyLarge: TextStyle(fontFamily: platformFont),
      //   bodyMedium: TextStyle(fontFamily: platformFont),
      //   bodySmall: TextStyle(fontFamily: platformFont),
      // ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.amber.shade800;
          }
          return Colors.transparent;
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.amber.shade800,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
