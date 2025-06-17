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
        
          return Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  image: DecorationImage(image: data!.photoURL!.isNotEmpty
                      ? NetworkImage(data.photoURL ?? '')
                      : const AssetImage('assets/images/user.png') as ImageProvider,)
                ),
                  
               ),
                
                const SizedBox(height: 24),
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
                Text(data.phone ?? '', style:medium),
                Divider(color: Colors.grey.shade300, thickness: 1, height: 1),
                Text('Created: ${data.createdAt.toLocal().toString().split(' ')[0]}',
                    style: medium),
                Divider(color: Colors.grey.shade300, thickness: 1, height: 1),
              ],
            ),
          );
        },
      ),
    );
  }
}
