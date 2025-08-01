import 'package:flutter/material.dart';
import 'package:sombot_pc/controller/theme_notifier.dart';

// class AppColors {
//   // Primary Colors
//   // static const Color primary = Color(0xFF1976D2); // Blue
//   static const Color primaryLight = Color(0xFF63A4FF);
//   static const Color primaryDark = Color(0xFF004BA0);

//   // Accent Colors
//   static const Color accent = Color(0xFFFFC107); // Amber
//   static const Color accentDark = Color(0xFFFFA000);

//   // Neutral Colors
//   static const Color white = Colors.white;
//   static const Color black = Colors.black;
//   static const Color grey = Colors.grey;
//   static const Color lightGrey = Color(0xFFF5F5F5);
//   static const Color darkGrey = Color(0xFF424242);

//   // Status Colors
//   static const Color success = Color(0xFF4CAF50); // Green
//   static const Color error = Color(0xFFF44336); // Red
//   static const Color warning = Color(0xFFFF9800); // Orange
//   static const Color info = Color(0xFF2196F3); // Blue

//   // Background
//   // static const Color background = Color(0xFFF0F2F5);

//   // Transparent
//   static const Color transparent = Colors.transparent;

//   // New Colors
//   static const Color background = Color(0xFF1a1d3c);
//   static const Color primary = Color(0xFF5788ff);
//   static const Color second = Color(0xFF2e324d);
//   static const Color second2 = Color(0xFF22274f);
//   static const Color black50 = Color.fromARGB(127, 0, 0, 0);
// }

// ===============================

class ThemeMainColor {
  // primary color
  static const Color primary = Color(0xFF5788ff);
  static const Color second = Color(0xFF2e324d);
  static const Color second2 = Color(0xFF22274f);

  // bg color
  static const Color background = Color(0xFF1a1d3c);

  // text color
  static const Color text = Colors.white;
}

class ThemeLightColor {
  // primary color
  static const Color primary = Color(0xFF5788ff);
  static const Color second = Color(0xFFe4e5f1);
  static const Color second2 = Color(0xFFf7f7f7);

  // bg color
  static const Color background = Color(0xFFffffff);

  // text color
  static const Color text = Colors.black;
}

class ThemeDarkColor {
  // primary color
  static const Color primary = Color(0xFF5788ff);
  static const Color second = Color(0xFFe4e5f1);
  static const Color second2 = Color(0xFF333333);

  // bg color
  static const Color background = Color(0xFF1e1e1e);

  // text color
  static const Color text = Colors.white;
}

// ====================
// class AppColors {
//   static ThemeNotifier? _notifier;

//   static void init(ThemeNotifier notifier) {
//     _notifier = notifier;
//   }

//   static ThemeModeType get currentThemeType =>
//       _notifier?.currentTheme ?? ThemeModeType.main;

//   static Color get primary {
//     switch (currentThemeType) {
//       case ThemeModeType.light:
//         return ThemeLightColor.primary;
//       case ThemeModeType.dark:
//         return ThemeDarkColor.primary;
//       default:
//         return ThemeMainColor.primary;
//     }
//   }

//   static Color get background {
//     switch (currentThemeType) {
//       case ThemeModeType.light:
//         return ThemeLightColor.background;
//       case ThemeModeType.dark:
//         return ThemeDarkColor.background;
//       default:
//         return ThemeMainColor.background;
//     }
//   }

//   static Color get second {
//     switch (currentThemeType) {
//       case ThemeModeType.light:
//         return ThemeLightColor.second;
//       case ThemeModeType.dark:
//         return ThemeDarkColor.second;
//       default:
//         return ThemeMainColor.second;
//     }
//   }

//   static Color get second2 {
//     switch (currentThemeType) {
//       case ThemeModeType.light:
//         return ThemeLightColor.second2;
//       case ThemeModeType.dark:
//         return ThemeDarkColor.second2;
//       default:
//         return ThemeMainColor.second2;
//     }
//   }

//   static Color get text {
//     switch (currentThemeType) {
//       case ThemeModeType.light:
//         return ThemeLightColor.text;
//       case ThemeModeType.dark:
//         return ThemeDarkColor.text;
//       default:
//         return ThemeMainColor.text;
//     }
//   }

//   // status color
//   static const Color success = Color(0xFF4CAF50);
//   static const Color error = Color(0xFFF44336);
//   static const Color warning = Color(0xFFFF9800);

//   // neutral color
//   static const Color grey = Colors.grey;
//   static const Color transparent = Colors.transparent;
//   static const Color accentDark = Color(0xFFFFA000);
// }

class AppColors {
  static ThemeNotifier? _notifier;

  static void init(ThemeNotifier notifier) {
    _notifier = notifier;
    _notifier?.addListener(() {});
  }

  static ThemeModeType get currentThemeType {
    if (_notifier == null) {
      // Return default theme if not initialized yet
      return ThemeModeType.main;
    }
    return _notifier!.currentTheme;
  }

  static Color get primary => _getColor(
        light: ThemeLightColor.primary,
        dark: ThemeDarkColor.primary,
        main: ThemeMainColor.primary,
      );

  static Color get background => _getColor(
        light: ThemeLightColor.background,
        dark: ThemeDarkColor.background,
        main: ThemeMainColor.background,
      );

  static Color get second => _getColor(
        light: ThemeLightColor.second,
        dark: ThemeDarkColor.second,
        main: ThemeMainColor.second,
      );

  static Color get second2 => _getColor(
        light: ThemeLightColor.second2,
        dark: ThemeDarkColor.second2,
        main: ThemeMainColor.second2,
      );

  static Color get text => _getColor(
        light: ThemeLightColor.text,
        dark: ThemeDarkColor.text,
        main: ThemeMainColor.text,
      );

  // Helper method to reduce code duplication
  static Color _getColor({
    required Color light,
    required Color dark,
    required Color main,
  }) {
    switch (currentThemeType) {
      case ThemeModeType.light:
        return light;
      case ThemeModeType.dark:
        return dark;
      default:
        return main;
    }
  }

  // status colors (unchanged)
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);

  // neutral colors (unchanged)
  static const Color grey = Colors.grey;
  static const Color transparent = Colors.transparent;
  static const Color accentDark = Color(0xFFFFA000);
}
