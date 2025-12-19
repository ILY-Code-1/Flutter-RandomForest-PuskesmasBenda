/// Controller untuk Landing Page
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class LandingController extends GetxController {
  /// Navigasi ke halaman pilih poli
  void goToPilihPoli() {
    Get.toNamed(AppRoutes.pilihPoli);
  }
}
