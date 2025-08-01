// ignore_for_file: use_build_context_synchronously

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sombot_pc/controller/auth_controller.dart';
import 'package:sombot_pc/utils/app_images.dart';
import 'package:sombot_pc/utils/colors.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final authController = Provider.of<AuthController>(context, listen: false);
    final error = await authController.login(_email.text, _password.text);

    setState(() => _isLoading = false);

    if (error == null) {
      // Login successful, navigate to home or root
      context.router.replaceNamed('/root');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful')),
      );
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AppImages.sombotApp01,
                  width: 120,
                ),
                const SizedBox(height: 24),
                Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _email,
                  cursorColor: AppColors.primary,
                  style: TextStyle(color: AppColors.text),
                  decoration: InputDecoration(
                    // labelText: 'Email',
                    hintText: "Email",
                    hintStyle: TextStyle(
                      color: AppColors.grey,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      borderSide: BorderSide(
                        color: AppColors.text,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    suffixIcon: Icon(
                      Icons.email,
                      color: AppColors.text,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email required';
                    }
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Invalid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _password,
                  obscureText: !_isPasswordVisible,
                  cursorColor: AppColors.primary,
                  style: TextStyle(color: AppColors.text),
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(
                      color: AppColors.grey,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      borderSide: BorderSide(
                        color: AppColors.text,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.text,
                      ),
                      onPressed: () {
                        setState(
                            () => _isPasswordVisible = !_isPasswordVisible);
                      },
                    ),
                  ),
                  validator: (value) => (value == null || value.length < 6)
                      ? ('Min 6 characters')
                      : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ButtonStyle(
                      foregroundColor:
                          WidgetStatePropertyAll(AppColors.background),
                      backgroundColor:
                          WidgetStatePropertyAll(AppColors.primary),
                      side: WidgetStatePropertyAll(
                        BorderSide(
                          color: AppColors.second2,
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : Text(
                              'Login',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // TextButton(
                //   onPressed: () {
                //     context.router.pushNamed('/signup');
                //   },
                //   child: Text(
                //     "Don't have an account? Register",
                //     style: TextStyle(
                //       color: AppColors.primary,
                //     ),
                //   ),
                // ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      context.router.pushNamed('/signup');
                    },
                    style: ButtonStyle(
                      foregroundColor:
                          WidgetStatePropertyAll(AppColors.primary),
                      backgroundColor:
                          WidgetStatePropertyAll(AppColors.background),
                      side: WidgetStatePropertyAll(
                        BorderSide(
                          color: AppColors.primary,
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Register',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
