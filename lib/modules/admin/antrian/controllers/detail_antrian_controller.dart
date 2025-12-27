/// Controller untuk halaman Detail Prediksi Antrian
/// Mengelola state detail antrian yang dipilih
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../models/queue_model.dart';
import '../../../../services/pdf_service.dart';
import '../../../../services/queue_service.dart';

class DetailAntrianController extends GetxController {
  // Data antrian
  final queueData = Rxn<QueueModel>();
  
  // Loading state
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAntrianData();
  }

  // Load data dari arguments
  Future<void> loadAntrianData() async {
    final args = Get.arguments;
    
    if (args is QueueModel) {
      queueData.value = args;
    } else if (args is String) {
      // Jika hanya ID, fetch dari Firebase
      isLoading.value = true;
      try {
        queueData.value = await QueueService.getAntrianById(args);
      } catch (e) {
        debugPrint('Error loading queue: $e');
      } finally {
        isLoading.value = false;
      }
    }
  }

  // Getter untuk data display
  String get nomorAntrian => queueData.value?.nomorAntrian ?? '-';
  String get namaPasien => queueData.value?.namaPasien ?? '-';
  String get jenisKelamin => queueData.value?.jenisKelamin ?? '-';
  String get usia => '${queueData.value?.usia ?? 0} tahun';
  String get poli => queueData.value?.poli ?? '-';
  String get status => queueData.value?.statusAntrian ?? '-';
  
  String get waktuDaftar {
    if (queueData.value == null) return '-';
    return DateFormat('EEEE, dd MMMM yyyy HH:mm', 'id')
        .format(queueData.value!.waktuDaftar);
  }
  
  String get rataLayanan => '${queueData.value?.rataRataWaktuPelayanan ?? 0} Menit';
  
  String get jumlahAntrianSebelum => '${queueData.value?.jumlahAntrianSebelum ?? 0}';
  
  String get estimasiTunggu {
    final minutes = queueData.value?.estimasiWaktuTunggu ?? 0;
    if (minutes < 60) return '$minutes Menit';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) return '$hours Jam';
    return '$hours Jam $mins Menit';
  }
  
  String get perkiraanDipanggil {
    if (queueData.value == null) return '-';
    return '${DateFormat('HH:mm:ss').format(queueData.value!.jamEfektifPelayanan)} WIB';
  }
  
  String? get waktuTungguAktual {
    final actual = queueData.value?.waktuTungguAktual;
    if (actual == null) return null;
    if (actual < 60) return '$actual Menit';
    final hours = actual ~/ 60;
    final mins = actual % 60;
    if (mins == 0) return '$hours Jam';
    return '$hours Jam $mins Menit';
  }

  // Getter untuk detail prediksi pohon
  List<Map<String, dynamic>> get treePredictions {
    final details = queueData.value?.predictionDetails;
    if (details == null) return [];
    final trees = details['treePredictions'];
    if (trees == null) return [];
    return List<Map<String, dynamic>>.from(trees);
  }

  // Method prediksi digunakan
  String get predictionMethod {
    final details = queueData.value?.predictionDetails;
    if (details == null) return 'Simple Rule';
    if (details['method'] == 'simple') return 'Simple Rule';
    return 'Random Forest (${details['treeCount'] ?? 0} pohon)';
  }

  // Download sebagai PDF
  Future<void> downloadPrediksi() async {
    if (queueData.value == null) return;
    
    isLoading.value = true;
    try {
      await PdfService.generatePredictionDetailPdf(queueData.value!);
      Get.snackbar(
        'Sukses',
        'PDF berhasil didownload',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal download PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
