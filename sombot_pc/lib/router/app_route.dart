import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:sombot_pc/authentication/login_page.dart';
import 'package:sombot_pc/authentication/otp_page.dart';
import 'package:sombot_pc/authentication/signUp_page.dart';
import 'package:sombot_pc/authentication/splash.dart';
import 'package:sombot_pc/data/models/product_model.dart';
import 'package:sombot_pc/pages/about_us.dart';
import 'package:sombot_pc/pages/chat.dart';
import 'package:sombot_pc/pages/detail_page.dart';
import 'package:sombot_pc/pages/favorite.dart';
import 'package:sombot_pc/pages/home_page.dart';
import 'package:sombot_pc/pages/map.dart';
import 'package:sombot_pc/pages/order_history.dart';
import 'package:sombot_pc/pages/order_product.dart';
import 'package:sombot_pc/pages/profile_page.dart';

import '../pages/root.dart';

part 'app_route.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          path: '/root',
          page: RootRoute.page,
        ),
        AutoRoute(path: '/home', page: HomeRoute.page),
        AutoRoute(path: '/detail', page: DetailRoute.page),
        AutoRoute(path: '/login', page: LoginRoute.page),
        AutoRoute(path: '/signup', page: SignUpRoute.page),
        AutoRoute(path: '/splash', page: SplashRoute.page, initial: true),
        AutoRoute(path: '/profile', page: ProfileRoute.page),
        AutoRoute(path: '/favorite', page: FavoriteRoute.page),
        AutoRoute(path: '/about', page: AboutUsRoute.page),
        AutoRoute(path: '/chat', page: ChatRoute.page),
        AutoRoute(path: '/map', page: ChooseLocationRoute.page),
        AutoRoute(path: '/order', page: OrderProductRoute.page),
        AutoRoute(path: '/order-history', page: OrderHistoryRoute.page),
        AutoRoute(path: '/otp', page: OtpRoute.page),
      ];
}
