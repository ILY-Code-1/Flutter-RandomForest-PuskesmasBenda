/// Controller untuk halaman Login Admin
/// Mengelola state form login dengan validasi kredensial
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/admin_routes.dart';

class LoginController extends GetxController {
  // Daftar kredensial admin yang valid
  static const List<Map<String, String>> validCredentials = [
    {'username': 'admin', 'password': 'admin123'},
    {'username': 'operator', 'password': 'operator123'},
  ];

  // Form controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // Observable state
  final isPasswordVisible = false.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Clear error message
  void clearError() {
    errorMessage.value = '';
  }

  // Validasi kredensial
  bool _validateCredentials(String username, String password) {
    return validCredentials.any(
      (cred) => cred['username'] == username && cred['password'] == password,
    );
  }

  // Login dengan validasi
  Future<void> login() async {
    clearError();

    final username = usernameController.text.trim();
    final password = passwordController.text;

    // Validasi input kosong
    if (username.isEmpty || password.isEmpty) {
      errorMessage.value = 'Username dan Password harus diisi';
      return;
    }

    isLoading.value = true;

    // Simulasi delay login
    await Future.delayed(const Duration(milliseconds: 800));

    // Validasi kredensial
    if (_validateCredentials(username, password)) {
      isLoading.value = false;
      Get.offAllNamed(AdminRoutes.dashboard);
    } else {
      isLoading.value = false;
      errorMessage.value = 'Username atau Password salah';
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
