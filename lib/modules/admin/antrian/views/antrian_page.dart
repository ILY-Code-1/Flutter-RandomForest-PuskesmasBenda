/// Halaman Daftar Antrian Admin
/// Menampilkan pilihan poli dan tabel daftar antrian dengan aksi
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routes/admin_routes.dart';
import '../../../../widgets/admin/admin_layout.dart';
import '../../../../models/queue_model.dart';
import '../controllers/antrian_controller.dart';

class AntrianPage extends GetView<AntrianController> {
  const AntrianPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: AdminRoutes.antrian,
      child: SingleChildScrollView(
        child: Obx(() {
          // Jika belum pilih poli, tampilkan pilihan poli
          if (controller.selectedPoli.value == null) {
            return _buildPoliSelection();
          }
          // Jika sudah pilih poli, tampilkan tabel antrian
          return _buildAntrianList(context);
        }),
      ),
    );
  }

  /// Build pilihan poli
  Widget _buildPoliSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Poli',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pilih poli untuk melihat daftar antrian',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.grey,
          ),
        ),
        const SizedBox(height: 32),
        
        // Poli cards
        Row(
          children: controller.poliList.map((poli) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _buildPoliCard(poli),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPoliCard(Map<String, dynamic> poli) {
    return InkWell(
      onTap: () => controller.selectPoli(poli['code']),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _getPoliIcon(poli['code']),
                size: 40,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              poli['name'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build daftar antrian
  Widget _buildAntrianList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header dengan back, judul, dan filter tanggal
        Row(
          children: [
            // Back button
            IconButton(
              onPressed: () {
                controller.selectedPoli.value = null;
                controller.antrianList.clear();
              },
              icon: const Icon(Icons.arrow_back),
              color: AppColors.primaryGreen,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Antrian ${_getPoliName(controller.selectedPoli.value!)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
            // Date picker
            InkWell(
              onTap: () => controller.selectDate(context),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      controller.currentDate,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Table
        _buildAntrianTable(),
        const SizedBox(height: 32),
      ],
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
        if (controller.isLoading.value) {
          return const Padding(
            padding: EdgeInsets.all(48),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (controller.antrianList.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(48),
            child: Center(
              child: Text(
                'Tidak ada antrian',
                style: TextStyle(color: AppColors.grey, fontSize: 16),
              ),
            ),
          );
        }

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
                  Expanded(flex: 2, child: _HeaderCell(text: 'Estimasi')),
                  Expanded(flex: 2, child: _HeaderCell(text: 'Status')),
                  Expanded(flex: 1, child: _HeaderCell(text: 'Call')),
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

  Widget _buildTableRow(QueueModel item, int index) {
    final status = item.statusAntrian;
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
              item.nomorAntrian,
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
              item.namaPasien,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Estimasi
          Expanded(
            flex: 2,
            child: Text(
              '${DateFormat('HH:mm').format(item.jamEfektifPelayanan)} WIB',
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
          // Call button
          Expanded(
            flex: 1,
            child: status == 'Menunggu'
                ? IconButton(
                    onPressed: () => controller.callAntrian(item),
                    icon: const Icon(Icons.campaign, size: 20),
                    color: Colors.orange,
                    tooltip: 'Panggil Antrian',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  )
                : const SizedBox.shrink(),
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
                      arguments: item,
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

  IconData _getPoliIcon(String code) {
    switch (code) {
      case 'PU':
        return Icons.medical_services_rounded;
      case 'PG':
        return Icons.sentiment_satisfied_alt_rounded;
      case 'PK':
        return Icons.pregnant_woman_rounded;
      default:
        return Icons.local_hospital_rounded;
    }
  }

  String _getPoliName(String code) {
    switch (code) {
      case 'PU':
        return 'Poli Umum';
      case 'PG':
        return 'Poli Gigi';
      case 'PK':
        return 'Poli KIA';
      default:
        return 'Poli';
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
