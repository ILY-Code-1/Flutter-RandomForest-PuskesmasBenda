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
  
  String get estimasi {
    final minutes = queueData.estimasiWaktuTunggu;
    final jamDipanggil = queueData.jamEfektifPelayanan;
    final jumlahAntrianSebelum = queueData.jumlahAntrianSebelum;
    final jamBukaPuskesmas = queueData.jamBukaPuskesmas;

    final hariText = _formatHari(jamDipanggil);
    final jamText = DateFormat('HH:mm').format(jamDipanggil);
    final durasiText = _formatDurasi(minutes);

    // Hitung jam buka dari string "08:30"
    final jamBukaParts = jamBukaPuskesmas.split(':');
    final jamBukaHour = int.parse(jamBukaParts[0]);
    final jamBukaMinute = int.parse(jamBukaParts[1]);
    final jamBukaDateTime = DateTime(
      jamDipanggil.year,
      jamDipanggil.month,
      jamDipanggil.day,
      jamBukaHour,
      jamBukaMinute,
    );

    // Format waktu sekarang
    final waktuSekarang = DateTime.now();
    final waktuSekarangText = DateFormat('HH:mm').format(waktuSekarang);
    final jamBukaText = DateFormat('HH:mm').format(jamBukaDateTime);

    // Cek apakah jamDipanggil hari yang sama dengan hari ini
    final today = DateTime(waktuSekarang.year, waktuSekarang.month, waktuSekarang.day);
    final targetDate = DateTime(jamDipanggil.year, jamDipanggil.month, jamDipanggil.day);
    final isSameDay = today.isAtSameMomentAs(targetDate);

    // Buat penjelasan detail
    String penjelasan;

    if (!isSameDay) {
      // Antrian untuk hari berbeda (besok/lusa/dst)
      // Gunakan jam buka sebagai referensi
      penjelasan = '$durasiText dari jam buka ($jamBukaText)';
    } else {
      // Antrian hari ini
      if (jumlahAntrianSebelum == 0) {
        // Antrian pertama
        if (waktuSekarang.isBefore(jamBukaDateTime)) {
          // Belum jam buka
          penjelasan = '$durasiText dari jam buka ($jamBukaText)';
        } else {
          // Sudah lewat jam buka
          penjelasan = '$durasiText dari sekarang ($waktuSekarangText)';
        }
      } else {
        // Ada antrian sebelumnya
        penjelasan = '$durasiText dari sekarang ($waktuSekarangText)';
      }
    }

    // Tambahkan info tambahan jika ada antrian sebelumnya
    String infoTambahan = '';
    if (jumlahAntrianSebelum > 0) {
      infoTambahan = '\nsetelah $jumlahAntrianSebelum antrian';
    }

    return '$hariText • $jamText\n$penjelasan$infoTambahan';
  }

  String _formatHari(DateTime tanggal) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(tanggal.year, tanggal.month, tanggal.day);

    final difference = targetDate.difference(today).inDays;

    if (difference == 0) {
      return 'Hari ini';
    } else if (difference == 1) {
      return 'Besok';
    } else if (difference == 2) {
      return 'Lusa';
    } else {
      return DateFormat('dd MMM yyyy').format(tanggal);
    }
  }

  String get perkiraanDipanggil {
    return DateFormat('HH:mm').format(queueData.jamEfektifPelayanan);
  }

  String _formatDurasi(int minutes) {
    if (minutes < 60) return '$minutes menit';

    final jam = minutes ~/ 60;
    final menit = minutes % 60;

    return menit == 0
        ? '$jam jam'
        : '$jam jam $menit menit';
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
