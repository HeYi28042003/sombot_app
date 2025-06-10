import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sombot_pc/controller/auth_controller.dart';

class ProfileDetailPage extends StatelessWidget {
  const ProfileDetailPage({Key? key}) : super(key: key);

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserProfile(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context, listen: false);
    final firebaseUser = authController.user;

    if (firebaseUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('No user logged in.')),
      );
    }

    final uid = firebaseUser.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Detail'),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _getUserProfile(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User profile not found.'));
          }

          final data = snapshot.data!.data()!;
          final email = data['email'] ?? '';
          final createdAt = data['createdAt']?.toDate(); // if using Timestamp
          final displayName = firebaseUser.displayName ?? 'No Name';

          return Padding(
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
                  displayName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                if (createdAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('Created: ${createdAt.toLocal()}'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
