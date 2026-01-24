/// Halaman Dashboard Admin (Beranda)
/// Menampilkan ringkasan antrian dengan desain modern
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routes/admin_routes.dart';
import '../../../../widgets/admin/admin_layout.dart';
import '../../../../widgets/admin/summary_card.dart';
import '../controllers/dashboard_controller.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: AdminRoutes.dashboard,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                _buildWelcomeSection(),
                const SizedBox(height: 32),
                // Summary Cards Section
                const Text(
                  'Jumlah Antrian Selesai',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSummarySection(constraints),
                const SizedBox(height: 40),
                // Quick Stats Section
                _buildQuickStatsSection(constraints),
                const SizedBox(height: 40),
                // Quick Actions Section
                _buildQuickActionsSection(constraints),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen,
            AppColors.primaryGreen.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selamat Datang, Admin!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => Text(
                      'Tanggal: ${controller.currentDate}',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                    )),
                const SizedBox(height: 4),
                Text(
                  'Kelola antrian pasien Puskesmas Benda dengan mudah',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.dashboard_rounded,
              size: 48,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BoxConstraints constraints) {
    final isWide = constraints.maxWidth > 700;

    return Obx(() {
      final cards = [
        SummaryCard(
          title: 'Poli Umum',
          count: controller.poliUmumCount.value,
        ),
        SummaryCard(
          title: 'Poli Lansia',
          count: controller.poliLansiaCount.value,
        ),
        SummaryCard(
          title: 'Poli Anak',
          count: controller.poliAnakCount.value,
        ),
        SummaryCard(
          title: 'Poli KIA',
          count: controller.poliKiaCount.value,
        ),
        SummaryCard(
          title: 'Poli Gigi',
          count: controller.poliGigiCount.value,
        ),
      ];

      if (isWide) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: cards
                .map((card) => Padding(
                      padding: const EdgeInsets.only(right: 24),
                      child: card,
                    ))
                .toList(),
          ),
        );
      } else {
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: cards,
        );
      }
    });
  }

  Widget _buildQuickStatsSection(BoxConstraints constraints) {
    final isWide = constraints.maxWidth > 600;

    return Obx(() {
      final stats = [
        _StatItem(
          icon: Icons.people_outline,
          label: 'Total Antrian Hari Ini',
          value: controller.totalAntrianHariIni.toString(),
          color: AppColors.primaryGreenLight,
        ),
        _StatItem(
          icon: Icons.check_circle_outline,
          label: 'Selesai Dilayani',
          value: controller.totalAntrianSelesai.toString(),
          color: AppColors.primaryGreen,
        ),
        _StatItem(
          icon: Icons.hourglass_empty,
          label: 'Sedang Menunggu',
          value: controller.totalMenunggu.toString(),
          color: AppColors.accentYellow,
        ),
        _StatItem(
          icon: Icons.medical_services_outlined,
          label: 'Sedang Dilayani',
          value: controller.totalDilayani.toString(),
          color: Colors.blue,
        ),
      ];

      if (isWide) {
        return Row(
          children: stats
              .map((stat) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: _buildStatCard(stat),
                    ),
                  ))
              .toList(),
        );
      } else {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: stats.map((stat) => SizedBox(
            width: (constraints.maxWidth - 12) / 2,
            child: _buildStatCard(stat),
          )).toList(),
        );
      }
    });
  }

  Widget _buildStatCard(_StatItem stat) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(stat.icon, color: stat.color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            stat.value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat.label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aksi Cepat',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.format_list_numbered,
                title: 'Kelola Antrian',
                subtitle: 'Lihat dan kelola daftar antrian pasien',
                onTap: () => Get.toNamed(AdminRoutes.antrian),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                icon: Icons.analytics_outlined,
                title: 'Lihat Statistik',
                subtitle: 'Pantau performa layanan harian',
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.greyLight.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primaryGreen, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}
