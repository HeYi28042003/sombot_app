import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sombot_pc/controller/auth_controller.dart';
import 'package:sombot_pc/data/models/user_model.dart';
import 'package:sombot_pc/utils/text_style.dart';

class ProfileDetailPage extends StatelessWidget {
  const ProfileDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Detail'),
      ),
      body: FutureBuilder<Users?>(
        future: authController.getUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('User profile not found.'));
          }

          final data = snapshot.data;
          final byte = base64Decode(data!.photoURL!);

          return Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: data!.photoURL!.isNotEmpty ? MemoryImage(byte) : const AssetImage('assets/images/user.png') as ImageProvider,
                    ),
                  ],
                ),
                // Container(
                //   height: 100,
                //   decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(50),
                //       image: DecorationImage(
                //         image:
                //       )),
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data.displayName ?? '',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(data.email, style: medium),
                Divider(color: Colors.grey.shade300, thickness: 1, height: 1),
                Text(data.phone ?? '', style: medium),
                Divider(color: Colors.grey.shade300, thickness: 1, height: 1),
                Text(data.address ?? '', style: medium),
                Divider(color: Colors.grey.shade300, thickness: 1, height: 1),
                Text('Created: ${data.createdAt.toLocal().toString().split(' ')[0]}', style: medium),
                Divider(color: Colors.grey.shade300, thickness: 1, height: 1),
              ],
            ),
          );
        },
      ),
    );
  }
}
