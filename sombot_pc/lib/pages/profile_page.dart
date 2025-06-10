import 'dart:convert';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sombot_pc/controller/auth_controller.dart';
import 'package:sombot_pc/controller/locale_provider.dart';
import 'package:sombot_pc/l10n/app_localizations.dart';
import 'package:sombot_pc/pages/profile_detail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final autProvider = Provider.of<AuthController>(context, listen: false);
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.profile),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pinkAccent, Colors.orangeAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/user.png'),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.pink,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit, size: 20, color: Colors.white),
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
            _buildMenuItem(
                Icons.history,
                loc.orderHistory,
                onTap: () {}),
            _buildMenuItem(
                Icons.language,
                loc.changeLanguage,
                onTap: () => showLanguageBottomSheet(context)),
            _buildMenuItem(
                Icons.info_outline,
                loc.aboutUs,
                onTap: () {}),
            _buildMenuItem(
                Icons.group_add,
                loc.inviteFriend,
                onTap: () {}),
            _buildMenuItem(
              Icons.payment,
              loc.makePayment,
              onTap: () {},
            ),
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
