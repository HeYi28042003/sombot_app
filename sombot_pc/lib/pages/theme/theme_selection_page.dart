import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sombot_pc/controller/theme_notifier.dart';
import 'package:sombot_pc/utils/colors.dart';

class ThemeSelectionPage extends StatelessWidget {
  const ThemeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    // final theme = themeNotifier.themeData;

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          _buildThemeCard(
            context,
            'Main Theme',
            ThemeModeType.main,
            themeNotifier,
            // theme,
          ),
          _buildThemeCard(
            context,
            'Light Theme',
            ThemeModeType.light,
            themeNotifier,
            // theme,
          ),
          _buildThemeCard(
            context,
            'Dark Theme',
            ThemeModeType.dark,
            themeNotifier,
            // theme,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(
    BuildContext context,
    String title,
    ThemeModeType themeMode,
    ThemeNotifier notifier,
    // ThemeData theme,
  ) {
    final isSelected = notifier.currentTheme == themeMode;

    return Card(
      color: AppColors.second2,
      // elevation: isSelected ? 4 : 2,
      margin: EdgeInsets.symmetric(vertical: 7),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          notifier.setTheme(themeMode);
          Navigator.pop(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.text,
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
