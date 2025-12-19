/// Binding untuk Pilih Poli Page
import 'package:get/get.dart';
import '../controllers/pilih_poli_controller.dart';

class PilihPoliBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PilihPoliController>(() => PilihPoliController());
  }
}
