/// Widget Tabel Antrian untuk Dashboard Admin
/// Menampilkan daftar antrian dengan aksi view detail
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/admin_routes.dart';

class AntrianTable extends StatelessWidget {
  final List<Map<String, String>> data;
  final String tanggal;

  const AntrianTable({
    super.key,
    required this.data,
    required this.tanggal,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header tabel dengan tanggal
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Antrian',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tanggal,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                AppColors.primaryGreen.withValues(alpha: 0.1),
              ),
              dataRowMinHeight: 56,
              dataRowMaxHeight: 56,
              columnSpacing: 40,
              horizontalMargin: 20,
              columns: const [
                DataColumn(
                  label: Text(
                    'Nomor Antrian',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Nama Pasien',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Estimasi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Status',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Aksi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
              rows: data.map((item) => _buildDataRow(item)).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  DataRow _buildDataRow(Map<String, String> item) {
    final status = item['status'] ?? '';
    final isWaiting = status == 'Menunggu';

    return DataRow(
      cells: [
        DataCell(
          Text(
            item['nomor'] ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        DataCell(
          Text(
            item['nama'] ?? '',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        DataCell(
          Text(
            item['estimasi'] ?? '',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isWaiting
                  ? AppColors.accentYellow.withValues(alpha: 0.3)
                  : AppColors.primaryGreenLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isWaiting
                    ? AppColors.textSecondary
                    : AppColors.primaryGreen,
              ),
            ),
          ),
        ),
        DataCell(
          IconButton(
            onPressed: () {
              Get.toNamed(
                AdminRoutes.detailAntrian,
                arguments: item,
              );
            },
            icon: const Icon(
              Icons.visibility,
              color: AppColors.primaryGreen,
            ),
            tooltip: 'Lihat Detail',
          ),
        ),
      ],
    );
  }
}
