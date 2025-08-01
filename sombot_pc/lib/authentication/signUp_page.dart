// ignore_for_file: file_names, use_build_context_synchronously

import 'package:auto_route/auto_route.dart';
import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:sombot_pc/authentication/otp_page.dart';
import 'package:sombot_pc/utils/colors.dart';

@RoutePage()
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final TextEditingController _name = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _otp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    EmailOTP.config(
      appName: 'SOMBOT PC Account',
      otpType: OTPType.numeric,
      emailTheme: EmailTheme.v6,
      appEmail: 'Bropichak5@gmail.com',
      otpLength: 6,
    );

    bool otpSent = await EmailOTP.sendOTP(
      email: _email.text.trim(),
    );

    setState(() => _isLoading = false);

    if (otpSent) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP Sent")),
        );
        // Navigate to OTP page with the form data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpPage(
              email: _email.text.trim(),
              password: _password.text,
              name: _name.text.trim(),
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to send OTP")),
        );
      }
    }
  }

  // Future<void> _signUp() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   setState(() => _isLoading = true);

  //   final authController = Provider.of<AuthController>(context, listen: false);
  //   final error = await authController.signUp(_email.text, _password.text);

  //   setState(() => _isLoading = false);

  //   if (error == null) {
  //     final user = FirebaseAuth.instance.currentUser;
  //     if (user != null) {
  //       await _usreInfo(
  //         user.uid,
  //         user.email ?? _email.text,
  //         _name.text,
  //       );
  //     }
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Sign up successful")),
  //     );
  //     context.router.replaceNamed('/root');
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Sign up failed: $error")),
  //     );
  //     print("Sign up failed: $error");
  //   }
  // }

  // Future<void> _usreInfo(String uid, String email, String name) async {
  //   await FirebaseFirestore.instance.collection('users').doc(uid).set({
  //     'uid': uid,
  //     'email': email,
  //     'name': name,
  //     'createdAt': FieldValue.serverTimestamp(),
  //     'profileImage': '',
  //     'address': '',
  //     'phone': '',
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: AppColors.second2,
      ),
      body: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  keyboardType: TextInputType.name,
                  style: TextStyle(color: AppColors.text),
                  cursorColor: AppColors.primary,
                  decoration: InputDecoration(
                    hintText: "Name",
                    hintStyle: TextStyle(color: AppColors.grey),
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
                      Icons.person,
                      color: AppColors.text,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: AppColors.text),
                  cursorColor: AppColors.primary,
                  decoration: InputDecoration(
                    hintText: "Email",
                    hintStyle: TextStyle(color: AppColors.grey),
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
                  style: TextStyle(color: AppColors.text),
                  cursorColor: AppColors.primary,
                  decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: TextStyle(color: AppColors.grey),
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
                          () => _isPasswordVisible = !_isPasswordVisible,
                        );
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Minimum 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPassword,
                  obscureText: !_isConfirmPasswordVisible,
                  style: TextStyle(color: AppColors.text),
                  cursorColor: AppColors.primary,
                  decoration: InputDecoration(
                    hintText: "Confirm Password",
                    hintStyle: TextStyle(color: AppColors.grey),
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
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.text,
                      ),
                      onPressed: () {
                        setState(
                          () => _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible,
                        );
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Minimum 6 characters';
                    }
                    if (value != _password.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _otp,
                    // onPressed: () {
                    //   // context.router.push(
                    //   //   OtpRoute(
                    //   //     email: _email.text.trim(),
                    //   //     password: _password.text,
                    //   //     name: _name.text.trim(),
                    //   //   ),
                    //   // );

                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => OtpPage(
                    //         email: _email.text,
                    //         password: _password.text,
                    //         name: _name.text,
                    //       ),
                    //     ),
                    //   );
                    // },
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
                          : const Text(
                              'Sign Up',
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
