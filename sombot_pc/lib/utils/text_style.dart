import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sombot_pc/controller/theme_notifier.dart';

class ThemeStyles {
  static TextStyle normal(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context).themeData;
    return TextStyle(fontSize: 12, color: theme.unselectedWidgetColor,fontFamily: 'Battambang');
  }

  static TextStyle normalBold(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context).themeData;
    return TextStyle(
      fontSize: 12,
      color: theme.unselectedWidgetColor,
      fontWeight: FontWeight.bold,
      fontFamily: 'Battambang-Bold',
    );
  }

  static TextStyle normalItalic(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context).themeData;
    return TextStyle(
      fontSize: 12,
      color: theme.unselectedWidgetColor,
      fontStyle: FontStyle.italic,
      fontFamily: 'Battambang',
    );
  }

  static TextStyle medium(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context).themeData;
    return TextStyle(
      fontSize: 16,
      color: theme.unselectedWidgetColor,
      fontFamily: 'Battambang',
    );
  }

  static TextStyle chatType(BuildContext context) {
    return TextStyle(
      fontSize: 10,
      color: Colors.black54,
      fontFamily: 'Battambang',
    );
  }
}
