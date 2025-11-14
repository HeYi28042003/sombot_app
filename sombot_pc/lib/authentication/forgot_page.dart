// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sombot_pc/utils/colors.dart';

class ForgotPage extends StatefulWidget {
  const ForgotPage({super.key});

  @override
  State<ForgotPage> createState() => _ForgotPageState();
}

class _ForgotPageState extends State<ForgotPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();

  final auth = FirebaseAuth.instance;
  Timer? timer;

  bool _loading = false;

  Future<void> _sendLinkResetEmail(BuildContext context, String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link send to email')),
      );

      timer = Timer(const Duration(seconds: 2), () {
        if (!mounted) return;
        context.router.replaceNamed('/login');
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Problem sending email')),
      );
    }
  }

  @override
  void dispose() {
    _email.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text("Please enter your email!!"),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _email,
                cursorColor: AppColors.primary,
                style: TextStyle(color: AppColors.text),
                decoration: InputDecoration(
                  hintText: "Email",
                  hintStyle: TextStyle(
                      color: AppColors.grey, fontFamily: "Battambang"),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      color: AppColors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(
                      color: AppColors.grey,
                      width: 1,
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
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _loading = true);

                            await _sendLinkResetEmail(
                                context, _email.text.trim());

                            setState(() => _loading = false);
                          }
                        },
                  style: ButtonStyle(
                    foregroundColor:
                        WidgetStatePropertyAll(AppColors.background),
                    backgroundColor: WidgetStatePropertyAll(AppColors.primary),
                    side: WidgetStatePropertyAll(
                      BorderSide(
                        color: AppColors.second2,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Center(
                    child: _loading
                        ? CircularProgressIndicator(
                            color: AppColors.background,
                          )
                        : Text(
                            'Send',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: "Battambang-Bold",
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
