import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthController extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userToken;

  bool get isAuthenticated => _isAuthenticated;
  String? get userToken => _userToken;
  User? get user => FirebaseAuth.instance.currentUser;

  Future<String?> login(String email, String password) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _isAuthenticated = true;
      _userToken = await userCredential.user?.getIdToken();
      notifyListeners();
      return null; // success
    } catch (e) {
      return e.toString(); // error message
    }
  }

  Future<String?> signUp(String email, String password) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _isAuthenticated = true;
      _userToken = await userCredential.user?.getIdToken();
      notifyListeners();
      return null; // success
    } catch (e) {
      return e.toString(); // error message
    }
  }

  void logout(BuildContext context) {
    _isAuthenticated = false;
    _userToken = null;
    FirebaseAuth.instance.signOut();
    context.router.replaceNamed('/login');
    notifyListeners();
  }
  Future<void> checkAuthentication(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _isAuthenticated = true;
      _userToken = await user.getIdToken();
      notifyListeners();
      context.router.replaceNamed('/root');
    } else {
      _isAuthenticated = false;
      _userToken = null;
      notifyListeners();
      context.router.replaceNamed('/login');
    }
  }
}
