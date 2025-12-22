/// Controller untuk halaman Antrian Admin
/// Mengelola state daftar antrian dengan status flow
import 'package:get/get.dart';

class AntrianController extends GetxController {
  // Status flow: Menunggu -> Dilayani -> Selesai
  static const List<String> statusFlow = ['Menunggu', 'Dilayani', 'Selesai'];

  // Tanggal hari ini
  final currentDate = '22-12-2025'.obs;

  // Dummy data antrian dengan status berbeda
  final antrianList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAntrianData();
  }

  // Load dummy data antrian
  void loadAntrianData() {
    antrianList.value = [
      {
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
      },
      {
        'nomor': 'PG02',
        'nama': 'Siti Rahayu',
        'estimasi': '10:15 WIB',
        'status': 'Dilayani',
        'poli': 'GIGI',
        'waktuDaftar': 'Senin, 22 Desember 2025',
        'rataLayanan': '15 Menit',
        'nomorUrut': '02',
        'estimasiTunggu': '20 Menit',
        'perkiraanDipanggil': '10:15:00 WIB',
      },
      {
        'nomor': 'PK03',
        'nama': 'Dewi Lestari',
        'estimasi': '10:30 WIB',
        'status': 'Selesai',
        'poli': 'KIA',
        'waktuDaftar': 'Senin, 22 Desember 2025',
        'rataLayanan': '12 Menit',
        'nomorUrut': '03',
        'estimasiTunggu': '25 Menit',
        'perkiraanDipanggil': '10:30:00 WIB',
      },
      {
        'nomor': 'PU04',
        'nama': 'Budi Santoso',
        'estimasi': '10:45 WIB',
        'status': 'Menunggu',
        'poli': 'UMUM',
        'waktuDaftar': 'Senin, 22 Desember 2025',
        'rataLayanan': '10 Menit',
        'nomorUrut': '04',
        'estimasiTunggu': '30 Menit',
        'perkiraanDipanggil': '10:45:00 WIB',
      },
      {
        'nomor': 'PG05',
        'nama': 'Rina Wati',
        'estimasi': '11:00 WIB',
        'status': 'Menunggu',
        'poli': 'GIGI',
        'waktuDaftar': 'Senin, 22 Desember 2025',
        'rataLayanan': '15 Menit',
        'nomorUrut': '05',
        'estimasiTunggu': '35 Menit',
        'perkiraanDipanggil': '11:00:00 WIB',
      },
    ];
  }

  // Update status ke tahap berikutnya
  void updateStatus(int index) {
    final currentStatus = antrianList[index]['status'] as String;
    final currentIndex = statusFlow.indexOf(currentStatus);
    
    if (currentIndex < statusFlow.length - 1) {
      antrianList[index]['status'] = statusFlow[currentIndex + 1];
      antrianList.refresh();
    }
  }

  // Get next status label
  String? getNextStatus(String currentStatus) {
    final currentIndex = statusFlow.indexOf(currentStatus);
    if (currentIndex < statusFlow.length - 1) {
      return statusFlow[currentIndex + 1];
    }
    return null;
  }
}
