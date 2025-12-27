/// Controller untuk Isi Form Page
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../services/queue_service.dart';

class IsiFormController extends GetxController {
  /// Form key untuk validasi
  final formKey = GlobalKey<FormState>();

  /// Text controllers
  final namaController = TextEditingController();
  final usiaController = TextEditingController();

  /// Jenis kelamin yang dipilih
  final Rxn<String> selectedJenisKelamin = Rxn<String>();

  /// Data poli yang dipilih (dari arguments)
  Map<String, dynamic>? selectedPoli;

  /// Loading state
  final isLoading = false.obs;

  /// List jenis kelamin
  final List<String> jenisKelaminList = [
    AppStrings.lakiLaki,
    AppStrings.perempuan,
  ];

  @override
  void onInit() {
    super.onInit();
    selectedPoli = Get.arguments as Map<String, dynamic>?;
  }

  @override
  void onClose() {
    namaController.dispose();
    usiaController.dispose();
    super.onClose();
  }

  /// Set jenis kelamin
  void setJenisKelamin(String? value) {
    selectedJenisKelamin.value = value;
  }

  /// Submit form dan generate antrian
  Future<void> submitForm() async {
    if (formKey.currentState?.validate() ?? false) {
      if (selectedJenisKelamin.value == null) {
        Get.snackbar(
          'Peringatan',
          AppStrings.pilihJenisKelamin,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      isLoading.value = true;

      try {
        // Buat antrian di Firebase dengan prediksi
        final queue = await QueueService.createQueue(
          namaPasien: namaController.text.trim(),
          jenisKelamin: selectedJenisKelamin.value!,
          usia: int.parse(usiaController.text),
          poli: selectedPoli?['name'] ?? 'Poli Umum',
          kodePoli: selectedPoli?['code'] ?? 'PU',
        );

        isLoading.value = false;

        // Navigasi ke halaman nomor antrian dengan data queue
        Get.toNamed(AppRoutes.nomorAntrian, arguments: queue);
      } catch (e) {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Gagal membuat antrian: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  /// Validasi nama
  String? validateNama(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    return null;
  }

  /// Validasi usia
  String? validateUsia(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    final usia = int.tryParse(value);
    if (usia == null || usia <= 0 || usia > 150) {
      return 'Masukkan usia yang valid';
    }
    return null;
  }
}
