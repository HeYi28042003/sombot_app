import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sombot_pc/controller/auth_controller.dart';

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
    AuthController authController = AuthController();
    authController.checkAuthentication(context);
   // onChecking();
  }

  // onChecking() async {
  //   await Future.delayed(const Duration(seconds: 1));
  //   FirebaseAuth.instance.authStateChanges().listen((user) async {
  //     if (user == null) {
  //       context.router.replaceNamed('/login');
  //     } else {
  //       context.router.replaceNamed('/root');
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.blue,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
