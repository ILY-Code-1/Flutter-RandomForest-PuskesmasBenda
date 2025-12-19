/// Binding untuk Nomor Antrian Page
import 'package:get/get.dart';
import '../controllers/nomor_antrian_controller.dart';

class NomorAntrianBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NomorAntrianController>(() => NomorAntrianController());
  }
}
