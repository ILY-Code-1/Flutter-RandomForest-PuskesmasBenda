// Konfigurasi GetPage untuk routing dengan animasi transisi
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_routes.dart';
import '../modules/landing/views/landing_page.dart';
import '../modules/landing/bindings/landing_binding.dart';
import '../modules/pilih_poli/views/pilih_poli_page.dart';
import '../modules/pilih_poli/bindings/pilih_poli_binding.dart';
import '../modules/isi_form/views/isi_form_page.dart';
import '../modules/isi_form/bindings/isi_form_binding.dart';
import '../modules/nomor_antrian/views/nomor_antrian_page.dart';
import '../modules/nomor_antrian/bindings/nomor_antrian_binding.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.landing;

  // Durasi transisi
  static const Duration _transitionDuration = Duration(milliseconds: 400);

  // Custom transition dengan fade + slide
  static CustomTransition get _fadeSlideTransition => _FadeSlideTransition();

  static final routes = [
    GetPage(
      name: AppRoutes.landing,
      page: () => const LandingPage(),
      binding: LandingBinding(),
      transition: Transition.fadeIn,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: AppRoutes.pilihPoli,
      page: () => const PilihPoliPage(),
      binding: PilihPoliBinding(),
      customTransition: _fadeSlideTransition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: AppRoutes.isiForm,
      page: () => const IsiFormPage(),
      binding: IsiFormBinding(),
      customTransition: _fadeSlideTransition,
      transitionDuration: _transitionDuration,
    ),
    GetPage(
      name: AppRoutes.nomorAntrian,
      page: () => const NomorAntrianPage(),
      binding: NomorAntrianBinding(),
      transition: Transition.zoom,
      transitionDuration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
    ),
  ];
}

// Custom transition: Fade + Slide dari kanan
class _FadeSlideTransition extends CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: curve ?? Curves.easeInOutCubic,
    );

    return FadeTransition(
      opacity: curvedAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.1, 0),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: child,
      ),
    );
  }
}
