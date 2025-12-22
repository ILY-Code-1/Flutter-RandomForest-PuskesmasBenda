/// Widget Header global untuk Admin Area
/// Bar horizontal warna kuning dengan judul hijau tua dan logo
/// Responsive: burger menu untuk mobile
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/admin_constants.dart';

class AdminHeader extends StatelessWidget {
  final bool showMenuButton;
  final VoidCallback? onMenuPressed;

  const AdminHeader({
    super.key,
    this.showMenuButton = false,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AdminConstants.headerHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.accentYellow,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            // Burger menu untuk mobile (di kiri)
            if (showMenuButton)
              IconButton(
                onPressed: onMenuPressed,
                icon: const Icon(
                  Icons.menu,
                  color: AppColors.primaryGreen,
                  size: 28,
                ),
                tooltip: 'Menu',
              ),
            // Spacer untuk push konten ke kanan
            const Spacer(),
            // Judul sistem - responsive text
            Text(
              showMenuButton ? 'ANTRIAN PUSKESMAS' : 'SISTEM ANTRIAN ONLINE PUSKESMAS BENDA',
              style: TextStyle(
                fontSize: showMenuButton ? 16 : 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 16),
            // Logo dari favicon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primaryGreen,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Image.asset(
                    'web/favicon.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.local_hospital,
                        color: AppColors.primaryGreen,
                        size: 30,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
