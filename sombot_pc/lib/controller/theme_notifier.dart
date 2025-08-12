// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sombot_pc/utils/colors.dart';

enum ThemeModeType { main, light, dark }

// class ThemeNotifier with ChangeNotifier {
//   ThemeModeType _currentTheme = ThemeModeType.main;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   ThemeModeType get currentTheme => _currentTheme;

//   ThemeNotifier() {
//     _loadTheme();
//   }

//   Future<void> _loadTheme() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       final doc = await _firestore.collection('users').doc(user.uid).get();
//       if (doc.exists) {
//         final themeMode = doc.data()?['themeMode'] as String?;
//         if (themeMode == 'light') {
//           _currentTheme = ThemeModeType.light;
//         } else if (themeMode == 'dark') {
//           _currentTheme = ThemeModeType.dark;
//         } else {
//           _currentTheme = ThemeModeType.main;
//         }
//         notifyListeners();
//       }
//     }
//   }

//   Future<void> setTheme(ThemeModeType theme) async {
//     _currentTheme = theme;
//     notifyListeners();

//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       await _firestore.collection('users').doc(user.uid).set({
//         'themeMode': theme.toString().split('.').last,
//       }, SetOptions(merge: true));
//     }
//   }

//   ThemeData get themeData {
//     switch (_currentTheme) {
//       case ThemeModeType.light:
//         return ThemeData(
//           primaryColor: ThemeLightColor.primary,
//           scaffoldBackgroundColor: ThemeLightColor.background,
//           colorScheme: ColorScheme.light(
//             primary: ThemeLightColor.primary,
//             secondary: ThemeLightColor.second,
//             surface: ThemeLightColor.second2,
//             background: ThemeLightColor.background,
//           ),
//           unselectedWidgetColor: ThemeLightColor.text,
//         );
//       case ThemeModeType.dark:
//         return ThemeData(
//           primaryColor: ThemeDarkColor.primary,
//           scaffoldBackgroundColor: ThemeDarkColor.background,
//           colorScheme: ColorScheme.dark(
//             primary: ThemeDarkColor.primary,
//             secondary: ThemeDarkColor.second,
//             surface: ThemeDarkColor.second2,
//             background: ThemeDarkColor.background,
//           ),
//           unselectedWidgetColor: ThemeDarkColor.text,
//         );
//       default: // main
//         return ThemeData(
//           primaryColor: ThemeMainColor.primary,
//           scaffoldBackgroundColor: ThemeMainColor.background,
//           colorScheme: ColorScheme.dark(
//             primary: ThemeMainColor.primary,
//             secondary: ThemeMainColor.second,
//             surface: ThemeMainColor.second2,
//             background: ThemeMainColor.background,
//           ),
//           unselectedWidgetColor: ThemeMainColor.text,
//         );
//     }
//   }
// }

class ThemeNotifier with ChangeNotifier {
  ThemeModeType _currentTheme = ThemeModeType.main;
  bool _isInitialized = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ThemeModeType get currentTheme => _currentTheme;
  bool get isInitialized => _isInitialized;

  ThemeNotifier() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadTheme();
    _isInitialized = true;
    AppColors.init(this); // Initialize AppColors here
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final themeMode = doc.data()?['themeMode'] as String?;
          if (themeMode == 'light') {
            _currentTheme = ThemeModeType.light;
          } else if (themeMode == 'dark') {
            _currentTheme = ThemeModeType.dark;
          } else {
            _currentTheme = ThemeModeType.main;
          }
        }
      } catch (e) {
        print('Error loading theme: $e');
        _currentTheme = ThemeModeType.main;
      }
    }
    notifyListeners();
  }

  Future<void> setTheme(ThemeModeType theme) async {
    _currentTheme = theme;
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'themeMode': theme.toString().split('.').last,
      }, SetOptions(merge: true));
    }
  }

  ThemeData get themeData {
    switch (_currentTheme) {
      case ThemeModeType.light:
        return ThemeData(
          primaryColor: ThemeLightColor.primary,
          scaffoldBackgroundColor: ThemeLightColor.background,
          colorScheme: ColorScheme.light(
            primary: ThemeLightColor.primary,
            secondary: ThemeLightColor.second,
            surface: ThemeLightColor.second2,
            background: ThemeLightColor.background,
            onBackground: ThemeLightColor.text,
          ),
          unselectedWidgetColor: ThemeLightColor.text,
        );
      case ThemeModeType.dark:
        return ThemeData(
          primaryColor: ThemeDarkColor.primary,
          scaffoldBackgroundColor: ThemeDarkColor.background,
          colorScheme: ColorScheme.dark(
            primary: ThemeDarkColor.primary,
            secondary: ThemeDarkColor.second,
            surface: ThemeDarkColor.second2,
            background: ThemeDarkColor.background,
          ),
          unselectedWidgetColor: ThemeDarkColor.text,
        );
      default: // main
        return ThemeData(
          primaryColor: ThemeMainColor.primary,
          scaffoldBackgroundColor: ThemeMainColor.background,
          colorScheme: ColorScheme.dark(
            primary: ThemeMainColor.primary,
            secondary: ThemeMainColor.second,
            surface: ThemeMainColor.second2,
            background: ThemeMainColor.background,
          ),
          unselectedWidgetColor: ThemeMainColor.text,
        );
    }
  }
}
