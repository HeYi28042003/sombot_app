// ignore_for_file: unnecessary_import, unused_local_variable, library_private_types_in_public_api

import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:sombot_pc/controller/theme_notifier.dart';
import 'package:sombot_pc/l10n/app_localizations.dart';
import 'package:sombot_pc/pages/chat.dart';
import 'package:sombot_pc/pages/favorite.dart';
import 'package:sombot_pc/pages/home_page.dart';
import 'package:sombot_pc/pages/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sombot_pc/pages/search/search_product.dart';
import 'package:sombot_pc/pages/shopping_card.dart';
import 'package:sombot_pc/utils/app_images.dart';
import 'package:sombot_pc/utils/colors.dart';

@RoutePage()
class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  _ExampleState createState() => _ExampleState();
}

class _ExampleState extends State<RootPage> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    SearchProductPage(),
    FavoritePage(),
    ChatScreen(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final loc = AppLocalizations.of(context)!;

    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final theme = themeNotifier.themeData;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        // title: Text(
        //   loc.sombotPC,
        //   style: TextStyle(color: AppColors.white),
        // ),
        shape: Border(
          bottom: BorderSide(
            // color: AppColors.primary,
            color: theme.primaryColor,
            width: 0.5,
          ),
        ),
        automaticallyImplyLeading: false,
        iconTheme: null,
        title: Image.asset(
          AppImages.logApp,
          width: 120,
        ),
        toolbarHeight: 65,
        elevation: 0,
        // backgroundColor: AppColors.background,
        backgroundColor: theme.scaffoldBackgroundColor,
        actions: [
          // Shopping cart with badge
          if (user != null)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('cart')
                  .where('userId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                int cartCount = 0;
                if (snapshot.hasData) {
                  cartCount = snapshot.data!.docs.length;
                }
                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ShoppingCartPage(),
                        ));
                  },
                  child: Stack(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.shopping_cart,
                          // color: AppColors.primary,
                          color: theme.primaryColor,
                        ),
                        onPressed: () {},
                        tooltip: 'Shopping Cart',
                      ),
                      if (cartCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              '$cartCount',
                              style: TextStyle(
                                color: theme.unselectedWidgetColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            )
          else
            IconButton(
              icon: Icon(
                Icons.shopping_cart,
                color: theme.primaryColor,
              ),
              onPressed: () {
                // TODO: Navigate to cart page
              },
              tooltip: 'Shopping Cart',
            ),
          IconButton(
            icon: Icon(
              Icons.notifications,
              color: theme.primaryColor,
            ),
            onPressed: () {
              // TODO: Navigate to notifications page
            },
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              width: 0.5,
              color: theme.primaryColor,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              // rippleColor: Colors.grey[300]!,
              // hoverColor: Colors.grey[100]!,
              gap: 4,
              // activeColor: Colors.black,
              // activeColor: AppColors.text,
              activeColor: theme.unselectedWidgetColor,
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: Duration(milliseconds: 400),
              // tabBackgroundColor: Colors.pink[100]!,
              tabBackgroundColor: AppColors.primary,
              color: theme.unselectedWidgetColor,
              tabs: const [
                GButton(
                  icon: LineIcons.home,
                  // text: 'Home',
                ),
                GButton(
                  icon: LineIcons.search,
                  // text: 'Search',
                ),
                GButton(
                  icon: LineIcons.heart,
                  // text: 'Likes',
                ),
                GButton(
                  icon: LineIcons.facebookMessenger,
                  // text: 'chat',
                ),
                GButton(
                  icon: Icons.settings,
                  // text: 'Setting',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
