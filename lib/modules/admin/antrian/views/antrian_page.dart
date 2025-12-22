/// Halaman Daftar Antrian Admin
/// Menampilkan tabel daftar antrian dengan aksi view detail dan update status
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routes/admin_routes.dart';
import '../../../../widgets/admin/admin_layout.dart';
import '../controllers/antrian_controller.dart';

class AntrianPage extends GetView<AntrianController> {
  const AntrianPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: AdminRoutes.antrian,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan judul dan tanggal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daftar Antrian',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                Obx(() => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primaryGreen),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: AppColors.primaryGreen,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            controller.currentDate.value,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 24),
            // Tabel Antrian
            _buildAntrianTable(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAntrianTable() {
    return Container(
      width: double.infinity,
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
      clipBehavior: Clip.antiAlias,
      child: Obx(() {
        return Column(
          children: [
            // Table header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
              ),
              child: const Row(
                children: [
                  Expanded(flex: 2, child: _HeaderCell(text: 'No. Antrian')),
                  Expanded(flex: 3, child: _HeaderCell(text: 'Nama Pasien')),
                  Expanded(flex: 2, child: _HeaderCell(text: 'Poli')),
                  Expanded(flex: 2, child: _HeaderCell(text: 'Estimasi')),
                  Expanded(flex: 2, child: _HeaderCell(text: 'Status')),
                  Expanded(flex: 2, child: _HeaderCell(text: 'Aksi')),
                ],
              ),
            ),
            // Table rows
            ...controller.antrianList.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildTableRow(item, index);
            }),
          ],
        );
      }),
    );
  }

  Widget _buildTableRow(Map<String, dynamic> item, int index) {
    final status = item['status'] as String;
    final isEven = index % 2 == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isEven ? AppColors.white : AppColors.greyBackground,
        border: Border(
          bottom: BorderSide(
            color: AppColors.greyLight.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          // No. Antrian
          Expanded(
            flex: 2,
            child: Text(
              item['nomor'] ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen,
                fontSize: 14,
              ),
            ),
          ),
          // Nama Pasien
          Expanded(
            flex: 3,
            child: Text(
              item['nama'] ?? '',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Poli
          Expanded(
            flex: 2,
            child: Text(
              item['poli'] ?? '',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          // Estimasi
          Expanded(
            flex: 2,
            child: Text(
              item['estimasi'] ?? '',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          // Status badge
          Expanded(
            flex: 2,
            child: _buildStatusBadge(status),
          ),
          // Aksi
          Expanded(
            flex: 2,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // View detail
                IconButton(
                  onPressed: () {
                    Get.toNamed(
                      AdminRoutes.detailAntrian,
                      arguments: Map<String, String>.from(
                        item.map((k, v) => MapEntry(k, v.toString())),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility, size: 18),
                  color: AppColors.primaryGreen,
                  tooltip: 'Lihat Detail',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                // Update status button
                if (status != 'Selesai')
                  IconButton(
                    onPressed: () => controller.updateStatus(index),
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    color: _getStatusColor(controller.getNextStatus(status) ?? ''),
                    tooltip: 'Ubah ke ${controller.getNextStatus(status)}',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(status).withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(status),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Menunggu':
        return Colors.orange;
      case 'Dilayani':
        return Colors.blue;
      case 'Selesai':
        return AppColors.primaryGreen;
      default:
        return AppColors.grey;
    }
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;

  const _HeaderCell({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.primaryGreen,
        fontSize: 14,
      ),
    );
  }
}
