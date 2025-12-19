/// Controller untuk Nomor Antrian Page
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class NomorAntrianController extends GetxController {
  /// Data antrian dari arguments
  late final Map<String, dynamic> queueData;

  @override
  void onInit() {
    super.onInit();
    // Ambil data antrian dari arguments
    queueData = Get.arguments as Map<String, dynamic>? ?? _defaultData;
  }

  /// Data default jika tidak ada arguments
  Map<String, dynamic> get _defaultData => {
        'queueNumber': 'PU-01',
        'nama': 'John Doe',
        'jenisKelamin': 'Laki-laki',
        'usia': '25',
        'poli': 'Poli Umum',
        'estimasi': '00:15:00',
      };

  /// Getter untuk data
  String get queueNumber => queueData['queueNumber'] ?? 'PU-01';
  String get nama => queueData['nama'] ?? '-';
  String get jenisKelamin => queueData['jenisKelamin'] ?? '-';
  String get usia => queueData['usia'] ?? '-';
  String get poli => queueData['poli'] ?? 'Poli Umum';
  String get estimasi => queueData['estimasi'] ?? '00:15:00';

  /// Kembali ke landing page
  void goToHome() {
    Get.offAllNamed(AppRoutes.landing);
  }
}
