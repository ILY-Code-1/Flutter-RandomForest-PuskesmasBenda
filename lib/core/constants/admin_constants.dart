/// Konstanta untuk Admin Area Sistem Antrian Puskesmas
class AdminConstants {
  AdminConstants._();

  // Sidebar width
  static const double sidebarWidth = 250;
  static const double headerHeight = 70;

  // Max content width for responsive
  static const double maxContentWidth = 1400;
  static const double minContentWidth = 800;

  // Card sizes
  static const double summaryCardSize = 180;
  static const double summaryCircleSize = 100;

  // Table
  static const double tableRowHeight = 56;

  // Menu items
  static const List<Map<String, dynamic>> menuItems = [
    {'title': 'Beranda', 'icon': 'home', 'route': '/admin/dashboard'},
    {'title': 'Antrian', 'icon': 'queue', 'route': '/admin/antrian'},
    {'title': 'Logout', 'icon': 'logout', 'route': '/admin/login'},
  ];

  // Dummy data untuk antrian
  static const List<Map<String, String>> dummyAntrianData = [
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
      'status': 'Menunggu',
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
      'status': 'Dipanggil',
      'poli': 'KIA',
      'waktuDaftar': 'Senin, 22 Desember 2025',
      'rataLayanan': '12 Menit',
      'nomorUrut': '03',
      'estimasiTunggu': '25 Menit',
      'perkiraanDipanggil': '10:30:00 WIB',
    },
  ];
}
