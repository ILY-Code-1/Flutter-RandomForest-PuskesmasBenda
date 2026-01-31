/// Widget Card Summary untuk Dashboard Admin
/// Menampilkan jumlah antrian per poli dengan desain modern
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData? icon;
  final Color? accentColor;

  const SummaryCard({
    super.key,
    required this.title,
    required this.count,
    this.icon,
    this.accentColor,
  });

  // Warna berdasarkan nama poli
  Color get _accentColor {
    if (accentColor != null) return accentColor!;
    if (title.toLowerCase().contains('umum')) return Colors.blue;
    if (title.toLowerCase().contains('gigi')) return Colors.orange;
    if (title.toLowerCase().contains('kia')) return Colors.pink;
    return AppColors.primaryGreenLight;
  }

  // Icon berdasarkan nama poli
  IconData get _icon {
    if (icon != null) return icon!;
    if (title.toLowerCase().contains('umum')) return Icons.medical_services;
    if (title.toLowerCase().contains('gigi')) return Icons.mood;
    if (title.toLowerCase().contains('kia')) return Icons.child_care;
    return Icons.local_hospital;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _accentColor.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: _accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _icon,
                  color: _accentColor,
                  size: 26,
                ),
              ),
              // Trend indicator (dummy)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: AppColors.primaryGreen,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Hari ini',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Angka besar
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: _accentColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          // Label "Pasien"
          const Text(
            'Pasien',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 12),
          // Divider
          Container(
            height: 3,
            width: 40,
            decoration: BoxDecoration(
              color: _accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          // Nama poli
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
