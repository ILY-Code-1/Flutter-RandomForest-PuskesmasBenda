/// Controller untuk halaman Statistik Admin
/// Mengelola data statistik antrian untuk chart dan summary
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../services/queue_service.dart';

class StatistikController extends GetxController {
  // Selected month filter
  final selectedMonth = DateTime.now().obs;

  // Loading state
  final isLoading = false.obs;

  // Data statistik
  final dailyQueueData = <int>[].obs; // Data untuk chart
  final dailyLabels = <String>[].obs; // Labels untuk chart (tanggal)
  final totalQueuesThisMonth = 0.obs;
  final averageWaitTime = 0.0.obs;
  final poliStats = <String, int>{}.obs;

  // Summary statistics
  final totalMenunggu = 0.obs;
  final totalDilayani = 0.obs;
  final totalSelesai = 0.obs;

  // Format bulan untuk display
  String get currentMonth => DateFormat('MMMM yyyy', 'id_ID').format(selectedMonth.value);

  @override
  void onInit() {
    super.onInit();
    selectedMonth.value = normalizeMonth(DateTime.now());
    loadStatistics();
  }

  /// Load statistik berdasarkan bulan yang dipilih
  Future<void> loadStatistics() async {
    isLoading.value = true;
    try {
      await _loadMonthlyData();
    } catch (e) {
      debugPrint('Error loading statistics: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat statistik',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load data bulanan untuk chart
  Future<void> _loadMonthlyData() async {
    final year = selectedMonth.value.year;
    final month = selectedMonth.value.month;

    // Hitung jumlah hari dalam bulan
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // Reset data
    dailyQueueData.value = List.filled(daysInMonth, 0);
    dailyLabels.value = [];
    totalQueuesThisMonth.value = 0;
    poliStats.value = {
      'Poli Umum': 0,
      'Poli Lansia': 0,
      'Poli Anak': 0,
      'Poli KIA': 0,
      'Poli Gigi': 0,
    };

    int totalWaitTime = 0;
    int waitTimeCount = 0;
    totalMenunggu.value = 0;
    totalDilayani.value = 0;
    totalSelesai.value = 0;

    // Loop setiap hari dalam bulan
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final dateString = DateFormat('yyyy-MM-dd').format(date);

      // Generate label (hanya tanggal)
      dailyLabels.add(day.toString());

      try {
        // Query antrian untuk tanggal ini
        final antrian = await QueueService.getAntrianByDate(date);

        // Update data harian
        dailyQueueData[day - 1] = antrian.length;
        totalQueuesThisMonth.value += antrian.length;

        // Update status
        for (final q in antrian) {
          switch (q.statusAntrian) {
            case 'Menunggu':
              totalMenunggu.value++;
              break;
            case 'Dilayani':
              totalDilayani.value++;
              break;
            case 'Selesai':
              totalSelesai.value++;
              break;
          }

          // Update poli stats
          switch (q.kodePoli) {
            case 'PU':
              poliStats['Poli Umum'] = (poliStats['Poli Umum'] ?? 0) + 1;
              break;
            case 'PL':
              poliStats['Poli Lansia'] = (poliStats['Poli Lansia'] ?? 0) + 1;
              break;
            case 'PA':
              poliStats['Poli Anak'] = (poliStats['Poli Anak'] ?? 0) + 1;
              break;
            case 'PK':
              poliStats['Poli KIA'] = (poliStats['Poli KIA'] ?? 0) + 1;
              break;
            case 'PG':
              poliStats['Poli Gigi'] = (poliStats['Poli Gigi'] ?? 0) + 1;
              break;
          }

          // Hitung rata-rata waktu tunggu
          if (q.waktuTungguAktual != null) {
            totalWaitTime += q.waktuTungguAktual!;
            waitTimeCount++;
          }
        }
      } catch (e) {
        debugPrint('Error loading data for $dateString: $e');
      }
    }

    // Hitung rata-rata waktu tunggu
    if (waitTimeCount > 0) {
      averageWaitTime.value = totalWaitTime / waitTimeCount;
    }
  }

  DateTime normalizeMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  String get selectedMonthLabel {
    final month = selectedMonth.value.month;
    final year = selectedMonth.value.year;
    return '${getMonthName(month)} $year';
  }

  List<DateTime> get availableMonths {
    final now = DateTime.now();
    final startYear = 2024;

    final List<DateTime> months = [];

    for (int year = now.year; year >= startYear; year--) {
      final endMonth = year == now.year ? now.month : 12;
      for (int month = endMonth; month >= 1; month--) {
        months.add(DateTime(year, month, 1));
      }
    }

    return months;
  }

  String getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return months[month - 1];
  }

  /// Get max value untuk chart scaling
  double get maxChartValue {
    if (dailyQueueData.isEmpty) return 10;
    final maxVal = dailyQueueData.reduce((a, b) => a > b ? a : b);
    return maxVal > 0 ? maxVal.toDouble() : 10;
  }

  /// Get total antrian hari ini (untuk quick stats)
  /// Hanya relevan jika bulan yang dipilih adalah bulan sekarang
  int get totalAntrianHariIni {
    final now = DateTime.now();
    final selectedYear = selectedMonth.value.year;
    final selectedMonthValue = selectedMonth.value.month;

    // Cek apakah bulan yang dipilih adalah bulan sekarang
    if (now.year == selectedYear && now.month == selectedMonthValue) {
      final todayIndex = now.day - 1;
      if (todayIndex >= 0 && todayIndex < dailyQueueData.length) {
        return dailyQueueData[todayIndex];
      }
    }
    return 0;
  }

  /// Get tanggal terakhir yang punya data (untuk label)
  String get lastDateWithData {
    final now = DateTime.now();
    final selectedYear = selectedMonth.value.year;
    final selectedMonthValue = selectedMonth.value.month;

    // Jika bulan yang dipilih adalah bulan sekarang
    if (now.year == selectedYear && now.month == selectedMonthValue) {
      return DateFormat('dd MMM yyyy', 'id_ID').format(now);
    }

    // Jika bulan yang dipilih adalah bulan lalu atau sebelumnya
    // Cari hari terakhir yang punya data
    for (int i = dailyQueueData.length - 1; i >= 0; i--) {
      if (dailyQueueData[i] > 0) {
        final date = DateTime(selectedYear, selectedMonthValue, i + 1);
        return DateFormat('dd MMM yyyy', 'id_ID').format(date);
      }
    }

    // Default ke akhir bulan
    final lastDay = DateTime(selectedYear, selectedMonthValue + 1, 0);
    return DateFormat('dd MMM yyyy', 'id_ID').format(lastDay);
  }

  /// Get total hari aktif (hari dengan antrian > 0)
  int get totalActiveDays {
    return dailyQueueData.where((count) => count > 0).length;
  }

  /// Get rata-rata antrian per hari aktif
  double get averagePerActiveDay {
    final activeDays = totalActiveDays;
    if (activeDays == 0) return 0;
    return totalQueuesThisMonth.value / activeDays;
  }
}
