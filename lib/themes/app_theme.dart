import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light {
    const fontFamily = 'Montserrat';
    const themeColor = Color.fromARGB(255, 255, 0, 85);
    const primary = Colors.white;
    final surface = Colors.grey.shade200;
    final button = Colors.grey.shade800;
    const lightText = Colors.black87;

    return ThemeData(
      fontFamily: fontFamily,
      useMaterial3: true,

      // Colors
      primaryColor: themeColor,
      colorScheme: ColorScheme.light(
        surface: surface,
        onSurface: button,
        primary: Colors.white,
        onPrimary: Colors.black,
        secondary: themeColor,
        tertiary: button,
        scrim: Colors.grey.shade400,
        error: Colors.red.shade600,
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: fontFamily),
        displayMedium: TextStyle(fontFamily: fontFamily),
        displaySmall: TextStyle(fontFamily: fontFamily),
        headlineLarge: TextStyle(fontFamily: fontFamily),
        headlineMedium: TextStyle(fontFamily: fontFamily),
        headlineSmall: TextStyle(fontFamily: fontFamily),
        titleLarge: TextStyle(fontFamily: fontFamily),
        titleMedium: TextStyle(fontFamily: fontFamily),
        titleSmall: TextStyle(fontFamily: fontFamily),
        bodyLarge: TextStyle(fontFamily: fontFamily),
        bodyMedium: TextStyle(fontFamily: fontFamily),
        bodySmall: TextStyle(fontFamily: fontFamily),
        labelLarge: TextStyle(fontFamily: fontFamily),
        labelMedium: TextStyle(fontFamily: fontFamily),
        labelSmall: TextStyle(fontFamily: fontFamily),
      ),

      // General Theme
      scaffoldBackgroundColor: surface,
      dividerColor: button,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: button, // For icons
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: fontFamily,
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: button,
        ),
        actionsIconTheme: IconThemeData(
          color: button,
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black87,
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w500,
          ),
          padding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          backgroundColor: surface,
          foregroundColor: lightText,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.disabled)
                ? Colors.grey.shade300
                : null;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.disabled)
                ? Colors.black87
                : null;
          }),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: button,
        ).copyWith(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.disabled)
                ? Colors.grey.shade400
                : null;
          }),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: themeColor,
        disabledColor: Colors.grey.shade300,
        labelStyle: const TextStyle(
          fontFamily: fontFamily,
          color: Colors.black87,
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: fontFamily,
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: themeColor,
        inactiveTrackColor: themeColor.withOpacity(0.2),
        thumbColor: themeColor,
        overlayColor: themeColor.withOpacity(0.1),
        valueIndicatorColor: themeColor,
        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: surface),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: surface),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: themeColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red.shade600),
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: primary,
        selectedItemColor: themeColor,
        unselectedItemColor: button,
      ),
    );
  }
}
