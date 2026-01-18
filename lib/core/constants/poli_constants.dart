/// Konstanta untuk Poli dan Konfigurasi Waktu Pelayanan
class PoliConstants {
  PoliConstants._();

  // Jam buka puskesmas (default 08:30)
  static const String jamBukaPuskesmas = '08:30';
  static const int jamBukaHour = 8;
  static const int jamBukaMinute = 30;
  
  // Jam tutup puskesmas (default 16:00)
  static const String jamTutupPuskesmas = '16:00';
  static const int jamTutupHour = 16;
  static const int jamTutupMinute = 0;

  // Rata-rata waktu pelayanan per poli (dalam menit)
  // ANDA BISA MENGUBAH NILAI INI SESUAI KEBUTUHAN
  static const Map<String, int> rataRataWaktuPelayanan = {
    'PU': 10,  // Poli Umum: 10 menit per pasien
    'PL': 12,  // Poli Lansia: 12 menit per pasien
    'PA': 15,  // Poli Anak: 15 menit per pasien
    'PK': 12,  // Poli KIA (Ibu Hamil & Imunisasi): 12 menit per pasien
    'PG': 15,  // Poli Gigi: 15 menit per pasien
  };

  // Data poli
  static const List<Map<String, dynamic>> poliList = [
    {'name': 'Poli Umum', 'code': 'PU', 'icon': 'medical_services'},
    {'name': 'Poli Lansia', 'code': 'PL', 'icon': 'elderly'},
    {'name': 'Poli Anak', 'code': 'PA', 'icon': 'child_care'},
    {'name': 'Poli KIA', 'code': 'PK', 'icon': 'pregnant_woman'},
    {'name': 'Poli Gigi', 'code': 'PG', 'icon': 'dentistry'},
  ];

  // Status antrian
  static const String statusMenunggu = 'Menunggu';
  static const String statusDilayani = 'Dilayani';
  static const String statusSelesai = 'Selesai';

  // Mendapatkan rata-rata waktu pelayanan berdasarkan kode poli
  static int getRataRataWaktu(String kodePoli) {
    return rataRataWaktuPelayanan[kodePoli] ?? 10;
  }

  // Mendapatkan nama poli dari kode
  static String getNamaPoli(String kodePoli) {
    final poli = poliList.firstWhere(
      (p) => p['code'] == kodePoli,
      orElse: () => {'name': 'Poli Umum'},
    );
    return poli['name'];
  }

  // Mendapatkan kode poli dari nama
  static String getKodePoli(String namaPoli) {
    final poli = poliList.firstWhere(
      (p) => p['name'] == namaPoli,
      orElse: () => {'code': 'PU'},
    );
    return poli['code'];
  }
}
