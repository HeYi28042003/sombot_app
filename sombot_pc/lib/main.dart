// ignore_for_file: duplicate_import

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:sombot_pc/api/notification.dart';
import 'package:sombot_pc/controller/auth_controller.dart';
import 'package:sombot_pc/controller/locale_provider.dart';
import 'package:sombot_pc/controller/product_controller.dart';
import 'package:sombot_pc/controller/theme_notifier.dart';
import 'package:sombot_pc/firebase_options.dart';
import 'package:sombot_pc/l10n/app_localizations.dart';
import 'package:sombot_pc/router/app_route.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().init();
  FlutterNativeSplash.remove();

  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ChangeNotifierProvider(create: (_) => AuthController()),
      ChangeNotifierProvider(create: (_) => ProductController()..init()),
      ChangeNotifierProvider(create: (_) => ThemeNotifier()),
    ], child: const MyApp()),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);

    return MaterialApp.router(
      title: 'SOMBOT PC Super App',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: provider.locale,
      routerConfig: _appRouter.config(),
      // theme: ThemeData(brightness: Brightness.dark),
      darkTheme: ThemeData.dark(),
      themeMode: themeNotifier.currentTheme == ThemeModeType.light
          ? ThemeMode.light
          : themeNotifier.currentTheme == ThemeModeType.dark
              ? ThemeMode.dark
              : ThemeMode.dark,
    );
  }
}

// flutter gen-l10n
