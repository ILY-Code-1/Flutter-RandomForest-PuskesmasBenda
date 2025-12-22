/// Controller untuk halaman Dashboard Admin
/// Mengelola state ringkasan antrian dan statistik
import 'package:get/get.dart';

class DashboardController extends GetxController {
  // Dummy data jumlah antrian selesai per poli
  final poliUmumCount = 10.obs;
  final poliGigiCount = 5.obs;
  final poliKiaCount = 15.obs;

  // Dummy statistik antrian
  final totalAntrianHariIni = 45.obs;
  final totalMenunggu = 12.obs;
  final totalDilayani = 3.obs;

  // Tanggal hari ini
  final currentDate = '22-12-2025'.obs;

  // Get total antrian selesai
  int get totalAntrianSelesai => poliUmumCount.value + poliGigiCount.value + poliKiaCount.value;
}
