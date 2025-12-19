/// Binding untuk Isi Form Page
import 'package:get/get.dart';
import '../controllers/isi_form_controller.dart';

class IsiFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IsiFormController>(() => IsiFormController());
  }
}
