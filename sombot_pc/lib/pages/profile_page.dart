import 'dart:convert';
import 'dart:typed_data'; // Import for Uint8List

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sombot_pc/controller/auth_controller.dart';
import 'package:sombot_pc/controller/locale_provider.dart';
import 'package:sombot_pc/data/models/user_model.dart';
import 'package:sombot_pc/l10n/app_localizations.dart';
import 'package:sombot_pc/pages/edit_profile.dart';
import 'package:sombot_pc/pages/profile_detail.dart';
import 'package:sombot_pc/router/app_route.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Users? user;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final autProvider = Provider.of<AuthController>(context, listen: false);
    final fetchedUser = await autProvider.getUserProfile();
    setState(() {
      user = fetchedUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    final autProvider = Provider.of<AuthController>(context, listen: false);
    final firebaseUser = autProvider.user;
    final loc = AppLocalizations.of(context)!;

    // Determine the image provider based on user data
    ImageProvider userImageProvider;
    if (user != null && user!.photoURL != null && user!.photoURL!.isNotEmpty) {
      try {
        // Decode the base64 string to Uint8List
        final Uint8List bytes = base64Decode(user!.photoURL!);
        userImageProvider = MemoryImage(bytes);
      } catch (e) {
        // Fallback to default image if base64 decoding fails
        userImageProvider = const AssetImage('assets/images/user.png');
        print('Error decoding base64 image: $e');
      }
    } else {
      userImageProvider = const AssetImage('assets/images/user.png');
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: userImageProvider, // Use the determined image provider
                ),
                InkWell(
                  onTap: () {
                    // Ensure firebaseUser is not null before navigating
                    if (firebaseUser != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditProfilePage(uid: firebaseUser.uid)),
                      );
                    } else {
                      // Optionally, show a message or handle the case where firebaseUser is null
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Exit User")), // Example of localized message
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.edit, size: 20, color: Colors.white),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            _buildMenuItem(
              Icons.person,
              loc.viewProfile,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileDetailPage()),
                );
              },
            ),
            _buildMenuItem(Icons.history, loc.orderHistory, onTap: () => context.router.push(const OrderHistoryRoute())),
            _buildMenuItem(Icons.language, loc.changeLanguage, onTap: () => showLanguageBottomSheet(context)),
            _buildMenuItem(Icons.info_outline, loc.aboutUs, onTap: () {
              context.router.push(const AboutUsRoute());
            }),
            // _buildMenuItem(Icons.group_add, loc.inviteFriend, onTap: () {}),
            // _buildMenuItem(
            //   Icons.payment,
            //   loc.makePayment,
            //   onTap: () {},
            // ),
            _buildMenuItem(
              Icons.logout,
              loc.logout,
              onTap: () => _showLogoutDialog(context, autProvider),
            ),
          ],
        ),
      ),
    );
  }

  void showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final provider = Provider.of<LocaleProvider>(context);
        final currentLocale = provider.locale;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: L10n.all.map((locale) {
            return ListTile(
              leading: Text(
                L10n.getFlag(locale),
                style: const TextStyle(fontSize: 28),
              ),
              title: Text(L10n.getLanguageName(locale)),
              trailing: Radio<Locale>(
                value: locale,
                groupValue: currentLocale,
                onChanged: (Locale? selected) {
                  provider.setLocale(selected!);
                  Navigator.pop(context);
                },
              ),
              onTap: () {
                provider.setLocale(locale);
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController autProvider) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.logout),
        content: Text(loc.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () {
              autProvider.logout(context);
            },
            child: Text(loc.logout),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String text, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: Icon(icon, color: Colors.pink),
            title: Text(text),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ),
      ),
    );
  }
}
