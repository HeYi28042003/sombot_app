import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sombot_pc/controller/auth_controller.dart';
import 'package:sombot_pc/utils/app_images.dart';
import 'package:sombot_pc/utils/colors.dart';

// Optional: your own loading widget
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: 180,
            left: BorderSide.strokeAlignCenter,
            right: BorderSide.strokeAlignCenter,
            child: Center(
              child: Image.asset(
                AppImages.sombotLogo,
                width: 300,
              ),
            ),
          ),
          Positioned(
            bottom: 25,
            left: BorderSide.strokeAlignCenter,
            right: BorderSide.strokeAlignCenter,
            child: Column(
              children: [
                Text(
                  "© 2025 SOMBOT PC Super App",
                  style: TextStyle(color: AppColors.white),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Version : ",
                      style: TextStyle(color: AppColors.white),
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
