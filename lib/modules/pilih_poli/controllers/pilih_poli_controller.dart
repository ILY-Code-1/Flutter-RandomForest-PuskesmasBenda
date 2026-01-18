/// Controller untuk Pilih Poli Page
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class PilihPoliController extends GetxController {
  /// Index poli yang dipilih (0: Umum, 1: Lansia, 2: Anak, 3: KIA, 4: Gigi)
  final RxInt selectedPoliIndex = (-1).obs;

  /// Data poli tersedia
  final List<Map<String, dynamic>> poliList = [
    {'name': 'Poli Umum', 'code': 'PU', 'icon': 'medical_services'},
    {'name': 'Poli Lansia', 'code': 'PL', 'icon': 'elderly'},
    {'name': 'Poli Anak', 'code': 'PA', 'icon': 'child_care'},
    {'name': 'Poli KIA', 'code': 'PK', 'icon': 'pregnant_woman'},
    {'name': 'Poli Gigi', 'code': 'PG', 'icon': 'dentistry'},
  ];

  /// Pilih poli berdasarkan index
  void selectPoli(int index) {
    selectedPoliIndex.value = index;
  }

  /// Cek apakah sudah ada poli yang dipilih
  bool get isPoliSelected => selectedPoliIndex.value >= 0;

  /// Mendapatkan poli yang dipilih
  Map<String, dynamic>? get selectedPoli {
    if (!isPoliSelected) return null;
    return poliList[selectedPoliIndex.value];
  }

  /// Navigasi ke halaman isi form
  void goToIsiForm() {
    if (!isPoliSelected) {
      Get.snackbar(
        'Peringatan',
        'Silakan pilih poli terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.toNamed(AppRoutes.isiForm, arguments: selectedPoli);
  }
}
