/// Konfigurasi GetPage untuk routing Admin Area
/// Dengan animasi transisi dan binding terpisah per halaman
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'admin_routes.dart';
import '../middlewares/auth_middleware.dart';
import '../modules/admin/auth/views/login_page.dart';
import '../modules/admin/auth/bindings/login_binding.dart';
import '../modules/admin/dashboard/views/dashboard_page.dart';
import '../modules/admin/dashboard/bindings/dashboard_binding.dart';
import '../modules/admin/antrian/views/antrian_page.dart';
import '../modules/admin/antrian/bindings/antrian_binding.dart';
import '../modules/admin/antrian/views/detail_antrian_page.dart';
import '../modules/admin/antrian/bindings/detail_antrian_binding.dart';

class AdminPages {
  AdminPages._();

  // Durasi transisi
  static const Duration _transitionDuration = Duration(milliseconds: 300);

  static final routes = [
    GetPage(
      name: AdminRoutes.login,
      page: () => const AdminLoginPage(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: AdminRoutes.dashboard,
      page: () => const DashboardPage(),
      binding: DashboardBinding(),
      transition: Transition.fadeIn,
      transitionDuration: _transitionDuration,
      middlewares: [AuthMiddleware()], // Proteksi auth
    ),
    GetPage(
      name: AdminRoutes.antrian,
      page: () => const AntrianPage(),
      binding: AntrianBinding(),
      transition: Transition.fadeIn,
      transitionDuration: _transitionDuration,
      middlewares: [AuthMiddleware()], // Proteksi auth
    ),
    GetPage(
      name: AdminRoutes.detailAntrian,
      page: () => const DetailAntrianPage(),
      binding: DetailAntrianBinding(),
      customTransition: _SlideTransition(),
      transitionDuration: _transitionDuration,
      middlewares: [AuthMiddleware()], // Proteksi auth
    ),
  ];
}

// Custom slide transition for detail page
class _SlideTransition extends CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: curve ?? Curves.easeInOut,
      )),
      child: child,
    );
  }
}
