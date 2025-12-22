/// Halaman Detail Prediksi Antrian
/// Menampilkan detail input dan hasil prediksi Random Forest
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../routes/admin_routes.dart';
import '../../../../widgets/admin/admin_layout.dart';
import '../controllers/detail_antrian_controller.dart';

class DetailAntrianPage extends GetView<DetailAntrianController> {
  const DetailAntrianPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: AdminRoutes.detailAntrian,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Get.back(),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryGreen),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: AppColors.primaryGreen,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Kembali',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Judul tengah
            Center(
              child: Column(
                children: [
                  const Text(
                    'Detail Prediksi Antrian',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Subjudul nomor antrian
                  Obx(() => Text(
                        'Nomor : ${controller.antrianData['nomor'] ?? '-'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Card Detail
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: _buildDetailCard(),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section DETAIL INPUT
              _buildSectionTitle('DETAIL INPUT'),
              const SizedBox(height: 20),
              _buildDetailRow('POLI', controller.antrianData['poli'] ?? '-'),
              _buildDetailRow(
                  'WAKTU DAFTAR', controller.antrianData['waktuDaftar'] ?? '-'),
              _buildDetailRow('RATA-RATA LAYANAN',
                  controller.antrianData['rataLayanan'] ?? '-'),
              _buildDetailRow(
                  'NOMOR ANTRIAN', controller.antrianData['nomorUrut'] ?? '-'),
              const SizedBox(height: 32),
              const Divider(color: AppColors.greyLight, thickness: 1),
              const SizedBox(height: 32),
              // Section HASIL PREDIKSI
              Center(
                child: _buildSectionTitle('HASIL PREDIKSI RANDOM FOREST'),
              ),
              const SizedBox(height: 24),
              _buildPredictionResult(
                'ESTIMASI TUNGGU',
                controller.antrianData['estimasiTunggu'] ?? '-',
              ),
              const SizedBox(height: 16),
              _buildPredictionResult(
                'PERKIRAAN DIPANGGIL',
                controller.antrianData['perkiraanDipanggil'] ?? '-',
              ),
              const SizedBox(height: 40),
              // Tombol Download
              Center(
                child: SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.downloadPrediksi,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 4,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'DOWNLOAD',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryGreen,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionResult(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundGreen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}
