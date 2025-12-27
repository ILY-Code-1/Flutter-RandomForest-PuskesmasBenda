/// Controller untuk Nomor Antrian Page
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../routes/app_routes.dart';
import '../../../models/queue_model.dart';
import '../../../services/pdf_service.dart';

class NomorAntrianController extends GetxController {
  /// Data antrian dari arguments
  late final QueueModel queueData;
  
  /// Loading state untuk download
  final isDownloading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is QueueModel) {
      queueData = args;
      // Auto download PDF setelah halaman load
      Future.delayed(const Duration(milliseconds: 500), () {
        downloadTicket();
      });
    } else {
      // Fallback untuk testing
      queueData = _createDefaultQueue();
    }
  }

  /// Create default queue untuk testing
  QueueModel _createDefaultQueue() {
    final now = DateTime.now();
    return QueueModel(
      nomorAntrian: 'PU-01',
      namaPasien: 'John Doe',
      jenisKelamin: 'Laki-laki',
      usia: 25,
      poli: 'Poli Umum',
      kodePoli: 'PU',
      waktuDaftar: now,
      hari: DateFormat('yyyy-MM-dd').format(now),
      jumlahAntrianSebelum: 0,
      jamBukaPuskesmas: '08:30',
      rataRataWaktuPelayanan: 10,
      jamEfektifPelayanan: now.add(const Duration(minutes: 15)),
      statusAntrian: 'Menunggu',
      estimasiWaktuTunggu: 15,
    );
  }

  /// Getter untuk data
  String get queueNumber => queueData.nomorAntrian;
  String get nama => queueData.namaPasien;
  String get jenisKelamin => queueData.jenisKelamin;
  String get usia => queueData.usia.toString();
  String get poli => queueData.poli;
  
  /// Format estimasi waktu tunggu
  String get estimasi {
    final minutes = queueData.estimasiWaktuTunggu;
    if (minutes < 60) {
      return '$minutes menit';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '$hours jam';
    }
    return '$hours jam $mins menit';
  }

  /// Format perkiraan jam dipanggil
  String get perkiraanDipanggil {
    return DateFormat('HH:mm').format(queueData.jamEfektifPelayanan);
  }

  /// Download tiket sebagai PDF
  Future<void> downloadTicket() async {
    if (isDownloading.value) return;
    
    isDownloading.value = true;
    try {
      await PdfService.generateAndDownloadTicket(queueData);
    } catch (e) {
      Get.snackbar(
        'Info',
        'PDF akan otomatis terdownload',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isDownloading.value = false;
    }
  }

  /// Kembali ke landing page
  void goToHome() {
    Get.offAllNamed(AppRoutes.landing);
  }
}
