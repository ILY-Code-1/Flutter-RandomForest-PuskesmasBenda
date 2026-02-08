/// Halaman Login Admin
/// Background hijau muda dengan wave, card login di tengah
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../controllers/login_controller.dart';

class AdminLoginPage extends GetView<LoginController> {
  const AdminLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGreen,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Wave decoration di bawah
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CustomPaint(
                  size: Size(constraints.maxWidth, 200),
                  painter: _WavePainter(),
                ),
              ),
              // Login card di tengah
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: _buildLoginCard(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo dari favicon
          Container(
            width: 100,
            height: 100,
            // decoration: BoxDecoration(
            //   color: AppColors.backgroundGreen,
            //   borderRadius: BorderRadius.circular(16),
            //   border: Border.all(color: AppColors.primaryGreen, width: 2),
            // ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'web/favicon.png',
                width: 80,
                height: 80,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.local_hospital,
                    color: AppColors.primaryGreen,
                    size: 60,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Title
          const Text(
            'SISTEM ANTRIAN ONLINE',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'PUSKESMAS BENDA',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentYellow.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Admin Login',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Error message
          Obx(
            () => controller.errorMessage.value.isNotEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            controller.errorMessage.value,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          // Username field
          _buildTextField(
            controller: controller.usernameController,
            label: 'Username',
            icon: Icons.person_outline,
            onChanged: (_) => controller.clearError(),
          ),
          const SizedBox(height: 24),
          // Password field
          Obx(
            () => _buildTextField(
              controller: controller.passwordController,
              label: 'Password',
              icon: Icons.lock_outline,
              isPassword: true,
              isPasswordVisible: controller.isPasswordVisible.value,
              onTogglePassword: controller.togglePasswordVisibility,
              onChanged: (_) => controller.clearError(),
              onSubmitted: (_) => controller.login(),
            ),
          ),
          const SizedBox(height: 40),
          // Login button
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 4,
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: isPassword ? TextInputAction.done : TextInputAction.next,
      style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.grey, fontSize: 16),
        prefixIcon: Icon(icon, color: AppColors.primaryGreen),
        suffixIcon: isPassword
            ? IconButton(
                onPressed: onTogglePassword,
                icon: Icon(
                  isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.grey,
                ),
              )
            : null,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.greyLight),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
      ),
    );
  }
}

/// Custom painter untuk wave decoration
class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintGreen = Paint()
      ..color = AppColors.primaryGreen.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final paintYellow = Paint()
      ..color = AppColors.accentYellow.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    // Wave hijau (belakang)
    final pathGreen = Path();
    pathGreen.moveTo(0, size.height * 0.6);
    pathGreen.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.3,
      size.width * 0.5,
      size.height * 0.5,
    );
    pathGreen.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.7,
      size.width,
      size.height * 0.4,
    );
    pathGreen.lineTo(size.width, size.height);
    pathGreen.lineTo(0, size.height);
    pathGreen.close();
    canvas.drawPath(pathGreen, paintGreen);

    // Wave kuning (depan)
    final pathYellow = Path();
    pathYellow.moveTo(0, size.height * 0.8);
    pathYellow.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.5,
      size.width * 0.6,
      size.height * 0.7,
    );
    pathYellow.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.85,
      size.width,
      size.height * 0.6,
    );
    pathYellow.lineTo(size.width, size.height);
    pathYellow.lineTo(0, size.height);
    pathYellow.close();
    canvas.drawPath(pathYellow, paintYellow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
