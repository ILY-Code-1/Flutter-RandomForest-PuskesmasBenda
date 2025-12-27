/// Header Widget untuk Display Antrian TV
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/display_antrian_controller.dart';

class HeaderDisplayWidget extends GetView<DisplayAntrianController> {
  const HeaderDisplayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      color: AppColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side - Logo and title
          Row(
            children: [
              // Logo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_hospital,
                  color: AppColors.white,
                  size: 36,
                ),
              ),
              const SizedBox(width: 16),
              
              // Title
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SISTEM ANTRIAN ONLINE',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  Text(
                    'PUSKESMAS BENDA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Right side - Date and time
          Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                controller.currentDate.value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${controller.currentTime.value} WIB',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }
}
