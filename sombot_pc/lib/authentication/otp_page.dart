// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:sombot_pc/controller/auth_controller.dart';
import 'package:sombot_pc/utils/colors.dart';

@RoutePage()
class OtpPage extends StatefulWidget {
  final String email;
  final String password;
  final String name;

  const OtpPage({
    super.key,
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otp = TextEditingController();
  bool _isLoading = false;

  Future<void> _otpVerify() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    bool isValid = EmailOTP.verifyOTP(otp: _otp.text);

    if (isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP is correct")),
      );
      await _signUp();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid OTP")),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authController = Provider.of<AuthController>(context, listen: false);
    final error = await authController.signUp(
        widget.email.trim(), widget.password.trim());

    setState(() => _isLoading = false);

    if (error == null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _usreInfo(
          user.uid,
          user.email ?? widget.email.trim(),
          widget.name,
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sign up successful")),
      );
      context.router.replaceNamed('/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign up failed: $error")),
      );
      print("Sign up failed: $error");
    }
  }

  Future<void> _usreInfo(String uid, String email, String name) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
      'profileImage': '',
      'address': '',
      'phone': '',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Verify OTP"),
        backgroundColor: AppColors.second2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Enter OTP sent to ${widget.email}",
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              Pinput(
                length: 6,
                showCursor: true,
                controller: _otp,
                defaultPinTheme: PinTheme(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  textStyle: TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter OTP';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _otpVerify,
                  style: ButtonStyle(
                    foregroundColor:
                        WidgetStatePropertyAll(AppColors.background),
                    backgroundColor: WidgetStatePropertyAll(AppColors.primary),
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
                            'Verify',
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
    );
  }
}
