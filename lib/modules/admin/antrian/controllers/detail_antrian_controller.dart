/// Controller untuk halaman Detail Prediksi Antrian
/// Mengelola state detail antrian yang dipilih
import 'package:get/get.dart';

class DetailAntrianController extends GetxController {
  // Data antrian dari arguments
  final antrianData = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadAntrianData();
  }

  // Load data dari arguments
  void loadAntrianData() {
    final args = Get.arguments;
    if (args != null && args is Map<String, String>) {
      antrianData.value = args;
    } else {
      // Default dummy data jika tidak ada arguments
      antrianData.value = {
        'nomor': 'PU01',
        'nama': 'Ahmad Suryadi',
        'estimasi': '10:00 WIB',
        'status': 'Menunggu',
        'poli': 'UMUM',
        'waktuDaftar': 'Senin, 22 Desember 2025',
        'rataLayanan': '10 Menit',
        'nomorUrut': '01',
        'estimasiTunggu': '15 Menit',
        'perkiraanDipanggil': '10:00:00 WIB',
      };
    }
  }

  // Dummy download action
  void downloadPrediksi() {
    Get.snackbar(
      'Download',
      'Mengunduh data prediksi antrian...',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}
