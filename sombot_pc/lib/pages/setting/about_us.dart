import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sombot_pc/l10n/app_localizations.dart';
import 'package:sombot_pc/utils/colors.dart';

@RoutePage()
class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(loc.aboutUs),
        // flexibleSpace: Container(
        //   decoration: const BoxDecoration(
        //     gradient: LinearGradient(
        //       colors: [Colors.pinkAccent, Colors.orangeAccent],
        //       begin: Alignment.topLeft,
        //       end: Alignment.bottomRight,
        //     ),
        //   ),
        // ),
        backgroundColor: AppColors.second2,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sombot PC',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Sombot PC is a powerful and versatile chatbot platform designed to enhance your productivity and streamline your workflow. Whether you need assistance with tasks, information retrieval, or just a friendly chat, Sombot PC is here to help.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Features:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 10),
            Text('- Intelligent conversation handling'),
            Text('- Task automation capabilities'),
            Text('- User-friendly interface'),
            Text('- Multi-language support'),
            SizedBox(height: 20),
            Text(
              'Help Center:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 20),
            Text(
                'If you have any questions or feedback, feel free to reach out to us at SOMBOT TECHNOLOGY CO.,LTD Or email us at: heyidevkpt@gmail.com'),
            Text('Thank you for choosing Sombot PC!'),
          ],
        ),
      ),
    );
  }
}
