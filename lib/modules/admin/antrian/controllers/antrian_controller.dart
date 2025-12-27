/// Controller untuk halaman Antrian Admin
/// Mengelola state daftar antrian dengan status flow
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../models/queue_model.dart';
import '../../../../services/queue_service.dart';
import '../../../../core/constants/poli_constants.dart';

class AntrianController extends GetxController {
  // Status flow: Menunggu -> Dilayani -> Selesai
  static const List<String> statusFlow = ['Menunggu', 'Dilayani', 'Selesai'];

  // Tanggal yang dipilih
  final selectedDate = DateTime.now().obs;

  // Poli yang dipilih
  final selectedPoli = Rxn<String>();

  // Data antrian
  final antrianList = <QueueModel>[].obs;

  // Loading state
  final isLoading = false.obs;

  // Format tanggal untuk display
  String get currentDate => DateFormat('dd-MM-yyyy').format(selectedDate.value);

  // List poli
  List<Map<String, dynamic>> get poliList => PoliConstants.poliList;

  /// Pilih poli dan load antrian
  Future<void> selectPoli(String kodePoli) async {
    selectedPoli.value = kodePoli;
    await loadAntrianData();
  }

  /// Load data antrian berdasarkan tanggal dan poli
  Future<void> loadAntrianData() async {
    if (selectedPoli.value == null) return;
    
    isLoading.value = true;
    try {
      antrianList.value = await QueueService.getAntrianByDateAndPoli(
        selectedDate.value,
        selectedPoli.value!,
      );
    } catch (e) {
      debugPrint('Error loading antrian: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Pilih tanggal filter
  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      selectedDate.value = picked;
      await loadAntrianData();
    }
  }

  /// Update status ke Dilayani
  Future<void> updateToDilayani(QueueModel queue) async {
    if (queue.id == null) return;
    
    try {
      await QueueService.updateStatusDilayani(queue.id!);
      await loadAntrianData();
      Get.snackbar(
        'Sukses',
        'Status antrian ${queue.nomorAntrian} diubah ke Dilayani',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengubah status: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Update status ke Selesai
  Future<void> updateToSelesai(QueueModel queue) async {
    if (queue.id == null) return;
    
    try {
      await QueueService.updateStatusSelesai(queue.id!);
      await loadAntrianData();
      Get.snackbar(
        'Sukses',
        'Status antrian ${queue.nomorAntrian} diubah ke Selesai',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengubah status: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Update status berdasarkan index
  Future<void> updateStatus(int index) async {
    final queue = antrianList[index];
    
    if (queue.statusAntrian == 'Menunggu') {
      await updateToDilayani(queue);
    } else if (queue.statusAntrian == 'Dilayani') {
      await updateToSelesai(queue);
    }
  }

  /// Panggil antrian (untuk display TV via Firebase realtime)
  Future<void> callAntrian(QueueModel queue) async {
    try {
      // Broadcast ke Firebase untuk display TV di browser lain
      await QueueService.broadcastCallQueue(queue);
      
      Get.snackbar(
        'Sukses',
        'Memanggil antrian ${queue.nomorAntrian}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memanggil antrian: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Get next status label
  String? getNextStatus(String currentStatus) {
    final currentIndex = statusFlow.indexOf(currentStatus);
    if (currentIndex < statusFlow.length - 1) {
      return statusFlow[currentIndex + 1];
    }
    return null;
  }
}


