import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sombot_pc/controller/auth_controller.dart';
import 'package:sombot_pc/controller/theme_notifier.dart';
import 'package:sombot_pc/data/models/user_model.dart';
import 'package:sombot_pc/l10n/app_localizations.dart';
import 'package:sombot_pc/utils/app_images.dart';
import 'package:sombot_pc/utils/text_style.dart';

class ProfileDetailPage extends StatelessWidget {
  const ProfileDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context, listen: false);

    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final theme = themeNotifier.themeData;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          loc.profiledetail,
          style: TextStyle(
            color: theme.unselectedWidgetColor,
          ),
        ),
        // backgroundColor: AppColors.second2,
        backgroundColor: theme.colorScheme.surface,
        iconTheme: IconThemeData(color: theme.unselectedWidgetColor),
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
                    // CircleAvatar(
                    //   radius: 50,
                    //   backgroundImage: data.photoURL!.isNotEmpty
                    //       ? MemoryImage(byte)
                    //       : const AssetImage('assets/images/user.png')
                    //           as ImageProvider,
                    // ),

                    Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          width: 1.5,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadiusGeometry.circular(20),
                        child: Image(
                          image: data.photoURL!.isNotEmpty
                              ? MemoryImage(byte)
                              : const AssetImage(AppImages.userIcon)
                                  as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
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
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.unselectedWidgetColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(data.email, style: ThemeStyles.medium(context)),
                Divider(color: Colors.grey.shade300, thickness: 1, height: 1),
                Text(data.phone ?? '', style: ThemeStyles.medium(context)),
                Divider(color: Colors.grey.shade300, thickness: 1, height: 1),
                Text(data.address ?? '', style: ThemeStyles.medium(context)),
                Divider(color: Colors.grey.shade300, thickness: 1, height: 1),
                Text(
                    '${loc.created}  ${data.createdAt.toLocal().toString().split(' ')[0]}',
                    style: ThemeStyles.medium(context)),
                Divider(color: Colors.grey.shade300, thickness: 1, height: 1),
              ],
            ),
          );
        },
      ),
    );
  }
}
