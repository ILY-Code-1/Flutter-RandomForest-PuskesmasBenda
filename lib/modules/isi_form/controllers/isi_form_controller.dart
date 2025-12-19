/// Controller untuk Isi Form Page
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../core/constants/app_strings.dart';

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

  /// Counter untuk nomor antrian
  static int _queueCounter = 0;

  /// List jenis kelamin
  final List<String> jenisKelaminList = [
    AppStrings.lakiLaki,
    AppStrings.perempuan,
  ];

  @override
  void onInit() {
    super.onInit();
    // Ambil arguments dari halaman sebelumnya
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

  /// Generate nomor antrian
  String _generateQueueNumber() {
    _queueCounter++;
    final code = selectedPoli?['code'] ?? 'PU';
    return '$code-${_queueCounter.toString().padLeft(2, '0')}';
  }

  /// Submit form
  void submitForm() {
    if (formKey.currentState?.validate() ?? false) {
      if (selectedJenisKelamin.value == null) {
        Get.snackbar(
          'Peringatan',
          AppStrings.pilihJenisKelamin,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Generate data antrian
      final queueData = {
        'queueNumber': _generateQueueNumber(),
        'nama': namaController.text,
        'jenisKelamin': selectedJenisKelamin.value,
        'usia': usiaController.text,
        'poli': selectedPoli?['name'] ?? 'Poli Umum',
        'estimasi': '00:15:00',
      };

      // Navigasi ke halaman nomor antrian
      Get.toNamed(AppRoutes.nomorAntrian, arguments: queueData);
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
