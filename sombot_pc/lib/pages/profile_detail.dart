import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sombot_pc/controller/auth_controller.dart'; // Import your AuthController

class ProfileDetailPage extends StatelessWidget {
  const ProfileDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context, listen: false);
    final user = authController.isAuthenticated
        ? authController
            .userToken // You may want to expose the Firebase User object in AuthController
        : null;

    // If you want to show FirebaseAuth.instance.currentUser info:
    final firebaseUser =
        authController.isAuthenticated ? authController.firebaseUser : null;

    if (firebaseUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('No user logged in.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: firebaseUser.photoURL != null
                  ? NetworkImage(firebaseUser.photoURL!)
                  : const AssetImage('assets/images/user.png') as ImageProvider,
            ),
            const SizedBox(height: 24),
            Text(
              firebaseUser.displayName ?? 'No Name',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              firebaseUser.email ?? '',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            // Add more profile details here
          ],
        ),
      ),
    );
  }
}
