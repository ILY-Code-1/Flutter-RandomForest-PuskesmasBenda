/// Widget Sidebar global untuk Admin Area
/// Sidebar kiri warna hijau tua dengan menu navigasi
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/admin_constants.dart';
import '../../routes/admin_routes.dart';
import 'confirm_dialog.dart';

class AdminSidebar extends StatelessWidget {
  final String currentRoute;
  final bool isMobile;

  const AdminSidebar({
    super.key,
    required this.currentRoute,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isMobile ? double.infinity : AdminConstants.sidebarWidth,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        boxShadow: isMobile
            ? null
            : const [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 8,
                  offset: Offset(2, 0),
                ),
              ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Header untuk mobile drawer
            if (isMobile)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'MENU',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: AppColors.white),
                    ),
                  ],
                ),
              ),
            if (isMobile) const Divider(color: AppColors.white, height: 32),
            if (!isMobile) const SizedBox(height: 16),
            // Logo section
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    'web/favicon.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.local_hospital,
                        color: AppColors.primaryGreen,
                        size: 50,
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'ADMIN PANEL',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 40),
            // Menu items
            _buildMenuItem(
              context: context,
              icon: Icons.home,
              title: 'Beranda',
              route: AdminRoutes.dashboard,
              isActive: currentRoute == AdminRoutes.dashboard,
            ),
            _buildMenuItem(
              context: context,
              icon: Icons.format_list_numbered,
              title: 'Antrian',
              route: AdminRoutes.antrian,
              isActive: currentRoute == AdminRoutes.antrian ||
                  currentRoute == AdminRoutes.detailAntrian,
            ),
            const Spacer(),
            _buildMenuItem(
              context: context,
              icon: Icons.logout,
              title: 'Logout',
              route: AdminRoutes.login,
              isActive: false,
              isLogout: true,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
    required bool isActive,
    bool isLogout = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          // Tutup drawer jika mobile
          if (isMobile) {
            Navigator.of(context).pop();
          }
          
          if (isLogout) {
            final confirmed = await ConfirmDialog.showLogout();
            if (confirmed == true) {
              Get.offAllNamed(route);
            }
          } else {
            Get.toNamed(route);
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.white.withValues(alpha: 0.15)
                : Colors.transparent,
            border: isActive
                ? const Border(
                    left: BorderSide(
                      color: AppColors.accentYellow,
                      width: 4,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? AppColors.accentYellow : AppColors.white,
                size: 28,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? AppColors.accentYellow : AppColors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
