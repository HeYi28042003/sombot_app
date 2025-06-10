import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sombot_pc/controller/locale_provider.dart';
import 'package:sombot_pc/l10n/app_localizations.dart';

class LanguageSwitcherScreen extends StatelessWidget {
  const LanguageSwitcherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);
    final currentLocale = provider.locale;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.localeName)),
      body: Column(
        children: L10n.all.map((locale) {
          final isSelected = locale == currentLocale;
          return ListTile(
            leading: Text(L10n.getFlag(locale), style: const TextStyle(fontSize: 32)),
            title: Text(L10n.getLanguageName(locale)),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: Colors.blue)
                : null,
            onTap: () {
              provider.setLocale(locale);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }
}
