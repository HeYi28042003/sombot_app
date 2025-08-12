import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sombot_pc/controller/theme_notifier.dart';

class ThemeStyles {
  static TextStyle normal(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context).themeData;
    return TextStyle(fontSize: 12, color: theme.unselectedWidgetColor);
  }

  static TextStyle normalBold(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context).themeData;
    return TextStyle(
      fontSize: 12,
      color: theme.unselectedWidgetColor,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle normalItalic(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context).themeData;
    return TextStyle(
      fontSize: 12,
      color: theme.unselectedWidgetColor,
      fontStyle: FontStyle.italic,
    );
  }

  static TextStyle medium(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context).themeData;
    return TextStyle(
      fontSize: 16,
      color: theme.unselectedWidgetColor,
    );
  }

  static TextStyle chatType(BuildContext context) {
    return TextStyle(
      fontSize: 10,
      color: Colors.black54,
    );
  }
}
