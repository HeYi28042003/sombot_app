// ignore_for_file: use_build_context_synchronously

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sombot_pc/controller/auth_controller.dart';
import 'package:sombot_pc/controller/theme_notifier.dart';
import 'package:sombot_pc/utils/app_images.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // AuthController authController = AuthController();
    // authController.checkAuthentication(context);
    onChecking();
  }

  Future<void> onChecking() async {
    await Future.delayed(const Duration(seconds: 1));
    // FirebaseAuth.instance.authStateChanges().listen((user) async {
    //   if (user == null) {
    //     context.router.replaceNamed('/login');
    //   } else {
    //     context.router.replaceNamed('/root');
    //   }
    // });

    AuthController authController = AuthController();
    authController.checkAuthentication(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final theme = themeNotifier.themeData;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: 210,
            left: BorderSide.strokeAlignCenter,
            right: BorderSide.strokeAlignCenter,
            child: Center(
              child: Image.asset(
                AppImages.sombotWeb01,
                width: 270,
              ),
            ),
          ),
          Positioned(
            bottom: 35,
            left: BorderSide.strokeAlignCenter,
            right: BorderSide.strokeAlignCenter,
            child: Column(
              children: [
                Text(
                  "© 2025 SOMBOT PC Super App",
                  style: TextStyle(color: theme.unselectedWidgetColor),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Version : 1.0.0+1",
                      style: TextStyle(color: theme.unselectedWidgetColor),
                    ),
                    // get form app info
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
