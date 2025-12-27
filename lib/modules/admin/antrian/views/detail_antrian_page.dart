/// Halaman Detail Prediksi Antrian
/// Menampilkan detail input dan hasil prediksi Random Forest dengan pohon logika
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
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.queueData.value == null) {
          return const Center(
            child: Text('Data tidak ditemukan'),
          );
        }

        return SingleChildScrollView(
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
                    Text(
                      'Nomor : ${controller.nomorAntrian}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Card Detail
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: _buildDetailCard(),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section DETAIL INPUT
          _buildSectionTitle('DETAIL INPUT'),
          const SizedBox(height: 20),
          _buildDetailRow('POLI', controller.poli),
          _buildDetailRow('NAMA PASIEN', controller.namaPasien),
          _buildDetailRow('JENIS KELAMIN', controller.jenisKelamin),
          _buildDetailRow('USIA', controller.usia),
          _buildDetailRow('WAKTU DAFTAR', controller.waktuDaftar),
          _buildDetailRow('JUMLAH ANTRIAN SEBELUM', controller.jumlahAntrianSebelum),
          _buildDetailRow('RATA-RATA LAYANAN', controller.rataLayanan),
          _buildDetailRow('STATUS', controller.status),
          if (controller.waktuTungguAktual != null)
            _buildDetailRow('WAKTU TUNGGU AKTUAL', controller.waktuTungguAktual!),
          const SizedBox(height: 32),
          const Divider(color: AppColors.greyLight, thickness: 1),
          const SizedBox(height: 32),
          
          // Section METODE PREDIKSI
          Center(
            child: _buildSectionTitle('METODE PREDIKSI: ${controller.predictionMethod}'),
          ),
          const SizedBox(height: 24),

          // Pohon-pohon logika (jika menggunakan Random Forest)
          if (controller.treePredictions.isNotEmpty) ...[
            _buildSectionTitle('HASIL SETIAP POHON LOGIKA'),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.greyBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: controller.treePredictions.map((tree) {
                  return _buildTreeRow(
                    tree['name'] as String,
                    '${tree['prediction']} menit',
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Hasil Final Prediksi
          _buildSectionTitle('HASIL PREDIKSI FINAL'),
          const SizedBox(height: 16),
          _buildPredictionResult(
            'ESTIMASI WAKTU TUNGGU',
            controller.estimasiTunggu,
          ),
          const SizedBox(height: 16),
          _buildPredictionResult(
            'PERKIRAAN DIPANGGIL',
            controller.perkiraanDipanggil,
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
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryGreen,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeRow(String treeName, String prediction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              treeName,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              prediction,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen,
              ),
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
              fontSize: 14,
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
