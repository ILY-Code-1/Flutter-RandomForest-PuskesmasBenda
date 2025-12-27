/// Binding untuk Display Antrian Page
import 'package:get/get.dart';
import '../controllers/display_antrian_controller.dart';

class DisplayAntrianBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DisplayAntrianController>(() => DisplayAntrianController());
  }
}
