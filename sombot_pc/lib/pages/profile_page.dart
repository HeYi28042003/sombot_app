import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sombot_pc/controller/auth_controller.dart';
import 'package:sombot_pc/controller/locale_provider.dart';
import 'package:sombot_pc/pages/language.dart';
import 'package:sombot_pc/pages/profile_detail.dart';

@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);
    final autProvider = Provider.of<AuthController>(context);
    return Scaffold(
      appBar: AppBar(
        title: provider.locale.languageCode == 'kh'
            ? const Text('ប្រវត្តិរូប')
            : const Text('Profili'),
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
      body: Column(
        children: [
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(
                    'assets/images/user.png'), // replace with actual asset or NetworkImage
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
            provider.locale.languageCode == 'en'
                ? 'View Profile'
                : 'មើលប្រវត្តិរូប',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileDetailPage()),
              );
            },
          ),
          _buildMenuItem(
              Icons.history,
              provider.locale.languageCode == 'en'
                  ? 'Order History'
                  : 'ប្រវត្តិនៃការបញ្ជាទិញ',
              onTap: () {}),
          _buildMenuItem(
              Icons.language,
              provider.locale.languageCode == 'en'
                  ? 'Change Language'
                  : 'ផ្លាស់ប្តូរភាសា',
              onTap: () => showLanguageBottomSheet(context)),
          _buildMenuItem(Icons.info_outline,
              provider.locale.languageCode == 'en' ? 'About Us' : 'អំពីពួកយើង',
              onTap: () {}),
          _buildMenuItem(
              Icons.group_add,
              provider.locale.languageCode == 'en'
                  ? 'Invite your friend'
                  : 'អញ្ជើញមិត្តរបស់អ្នក',
              onTap: () {}),
          _buildMenuItem(
            Icons.logout,
            provider.locale.languageCode == 'en' ? 'Logout' : 'ចាកចេញ',
            onTap: () => _showLogoutDialog(context, autProvider),
          ),
        ],
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              autProvider.logout(context);
            },
            child: const Text('Logout'),
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
