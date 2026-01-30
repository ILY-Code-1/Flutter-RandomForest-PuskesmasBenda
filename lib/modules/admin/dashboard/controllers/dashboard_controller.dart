/// Controller untuk halaman Dashboard Admin
/// Mengelola state ringkasan antrian dan statistik
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../services/queue_service.dart';

class DashboardController extends GetxController {
  // Data jumlah antrian per poli
  final poliUmumCount = 0.obs;
  final poliLansiaCount = 0.obs;
  final poliAnakCount = 0.obs;
  final poliKiaCount = 0.obs;
  final poliGigiCount = 0.obs;

  // Statistik antrian
  final totalAntrianHariIni = 0.obs;
  final totalMenunggu = 0.obs;
  final totalDilayani = 0.obs;
  final totalSelesai = 0.obs;

  // Tanggal yang dipilih
  final selectedDate = DateTime.now().obs;
  
  // Loading state
  final isLoading = false.obs;

  // Format tanggal untuk display
  String get currentDate => DateFormat('dd-MM-yyyy').format(selectedDate.value);

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  /// Load data ringkasan
  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final ringkasan = await QueueService.getRingkasanHariIni();
      
      totalAntrianHariIni.value = ringkasan['total'] ?? 0;
      totalMenunggu.value = ringkasan['menunggu'] ?? 0;
      totalDilayani.value = ringkasan['dilayani'] ?? 0;
      totalSelesai.value = ringkasan['selesai'] ?? 0;
      poliUmumCount.value = ringkasan['poliUmum'] ?? 0;
      poliLansiaCount.value = ringkasan['poliLansia'] ?? 0;
      poliAnakCount.value = ringkasan['poliAnak'] ?? 0;
      poliKiaCount.value = ringkasan['poliKia'] ?? 0;
      poliGigiCount.value = ringkasan['poliGigi'] ?? 0;
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
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
      await loadDataByDate(picked);
    }
  }

  /// Load data berdasarkan tanggal
  Future<void> loadDataByDate(DateTime date) async {
    isLoading.value = true;
    try {
      final antrian = await QueueService.getAntrianByDate(date);
      
      int total = antrian.length;
      int menunggu = 0;
      int dilayani = 0;
      int selesai = 0;
      int poliUmum = 0;
      int poliLansia = 0;
      int poliAnak = 0;
      int poliKia = 0;
      int poliGigi = 0;

      for (final q in antrian) {
        switch (q.statusAntrian) {
          case 'Menunggu':
            menunggu++;
            break;
          case 'Dilayani':
            dilayani++;
          case 'Selesai':
            selesai++;
            break;
        }

        switch (q.kodePoli) {
          case 'PU':
            poliUmum++;
            break;
          case 'PL':
            poliLansia++;
            break;
          case 'PA':
            poliAnak++;
            break;
          case 'PK':
            poliKia++;
            break;
          case 'PG':
            poliGigi++;
            break;
        }
      }

      totalAntrianHariIni.value = total;
      totalMenunggu.value = menunggu;
      totalDilayani.value = dilayani;
      totalSelesai.value = selesai;
      poliUmumCount.value = poliUmum;
      poliLansiaCount.value = poliLansia;
      poliAnakCount.value = poliAnak;
      poliKiaCount.value = poliKia;
      poliGigiCount.value = poliGigi;
    } catch (e) {
      debugPrint('Error loading data by date: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
