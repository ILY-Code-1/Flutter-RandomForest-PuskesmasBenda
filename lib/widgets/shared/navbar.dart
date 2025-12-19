/// Widget navbar konsisten untuk semua halaman
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_sizes.dart';
import 'responsive_layout.dart';

class AppNavbar extends StatelessWidget {
  const AppNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);

    return Padding(
      padding: EdgeInsets.all(isMobile ? AppSizes.paddingM : AppSizes.paddingL),
      child: Row(
        children: [
          // Logo placeholder
          Container(
            width: isMobile ? 40 : 50,
            height: isMobile ? 40 : 50,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: const Icon(
              Icons.local_hospital,
              color: AppColors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSizes.paddingM),
          // Title
          Flexible(
            child: Text(
              isMobile ? AppStrings.appNameShort : AppStrings.appName,
              style: isMobile
                  ? AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    )
                  : AppTextStyles.navbarTitle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
