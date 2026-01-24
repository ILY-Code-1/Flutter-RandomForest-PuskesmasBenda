/// Auth Middleware untuk proteksi route admin
/// Redirect ke login jika belum login
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../routes/admin_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    // Check login status secara synchronous dengan Future
    return _checkAuth();
  }

  RouteSettings? _checkAuth() {
    // Gunakan FutureBuilder pattern atau check langsung
    // Karena GetX middleware tidak support async, kita perlu cara lain
    // Kita akan check di onPageCalled
    return null;
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    // Check auth sebelum page dipanggil
    _checkAuthAndRedirect();
    return super.onPageCalled(page);
  }

  Future<void> _checkAuthAndRedirect() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    
    if (!isLoggedIn) {
      // Redirect ke login jika belum login
      Get.offAllNamed(AdminRoutes.login);
    }
  }
}
