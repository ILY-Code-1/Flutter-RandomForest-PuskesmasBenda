/// Random Forest Service untuk Prediksi Waktu Tunggu Antrian
/// Menggunakan 7 Decision Trees untuk prediksi
/// 
/// POHON LOGIKA DAPAT DITAMBAH ATAU DIKURANGI DI BAGIAN [_trees]
import '../core/constants/poli_constants.dart';

class RandomForestService {
  RandomForestService._();

  /// Data historis untuk training (akan diisi dari Firebase)
  static List<Map<String, dynamic>> historicalData = [];

  // ============================================================
  // DEFINISI 7 POHON LOGIKA - BISA DITAMBAH/DIKURANGI DI SINI
  // ============================================================
  static final List<DecisionTree> _trees = [
    // POHON 1: Berdasarkan Jumlah Antrian Sebelumnya
    DecisionTree(
      name: 'Pohon 1: Jumlah Antrian',
      predict: (features) {
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;
        
        if (jumlahAntrian == 0) return 0;
        if (jumlahAntrian <= 3) return jumlahAntrian * rataRata;
        if (jumlahAntrian <= 6) return (jumlahAntrian * rataRata * 1.1).round();
        if (jumlahAntrian <= 10) return (jumlahAntrian * rataRata * 1.15).round();
        return (jumlahAntrian * rataRata * 1.2).round();
      },
    ),

    // POHON 2: Berdasarkan Hari
    DecisionTree(
      name: 'Pohon 2: Faktor Hari',
      predict: (features) {
        final hari = features['hari'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;
        
        double faktorHari = 1.0;
        switch (hari.toLowerCase()) {
          case 'senin':
            faktorHari = 1.3; // Senin biasanya ramai
            break;
          case 'selasa':
          case 'rabu':
            faktorHari = 1.1;
            break;
          case 'kamis':
            faktorHari = 1.0;
            break;
          case 'jumat':
            faktorHari = 0.95; // Jumat lebih sepi
            break;
          case 'sabtu':
            faktorHari = 1.2; // Sabtu ramai karena libur kerja
            break;
          default:
            faktorHari = 1.0;
        }
        
        return (jumlahAntrian * rataRata * faktorHari).round();
      },
    ),

    // POHON 3: Berdasarkan Jam Daftar
    DecisionTree(
      name: 'Pohon 3: Jam Daftar',
      predict: (features) {
        final jamDaftar = features['jamDaftar'] as int;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;
        
        double faktorJam = 1.0;
        if (jamDaftar >= 8 && jamDaftar < 10) {
          faktorJam = 1.2; // Pagi-pagi ramai
        } else if (jamDaftar >= 10 && jamDaftar < 12) {
          faktorJam = 1.0;
        } else if (jamDaftar >= 12 && jamDaftar < 14) {
          faktorJam = 0.85; // Jam istirahat lebih sepi
        } else {
          faktorJam = 0.9;
        }
        
        return (jumlahAntrian * rataRata * faktorJam).round();
      },
    ),

    // POHON 4: Berdasarkan Tipe Poli
    DecisionTree(
      name: 'Pohon 4: Tipe Poli',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;
        
        double faktorPoli = 1.0;
        switch (kodePoli) {
          case 'PU':
            faktorPoli = 1.0; // Poli umum standar
            break;
          case 'PG':
            faktorPoli = 1.15; // Gigi butuh waktu lebih
            break;
          case 'PK':
            faktorPoli = 1.1; // KIA sedikit lebih lama
            break;
        }
        
        return (jumlahAntrian * rataRata * faktorPoli).round();
      },
    ),

    // POHON 5: Berdasarkan Rata-rata Historis
    DecisionTree(
      name: 'Pohon 5: Data Historis',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;
        
        // Cari data historis dengan kondisi serupa
        final similarData = historicalData.where((data) {
          final sameKodePoli = data['kodePoli'] == kodePoli;
          final hasWaktuAktual = data['waktuTungguAktual'] != null;
          final antrianSebelum = data['jumlahAntrianSebelum'] as int;
          final diff = (antrianSebelum - jumlahAntrian).abs();
          return sameKodePoli && hasWaktuAktual && diff <= 2;
        }).toList();
        
        if (similarData.isEmpty) {
          return jumlahAntrian * rataRata;
        }
        
        // Hitung rata-rata waktu tunggu aktual
        final totalWaktu = similarData.fold<int>(
          0,
          (sum, data) => sum + (data['waktuTungguAktual'] as int),
        );
        return (totalWaktu / similarData.length).round();
      },
    ),

    // POHON 6: Kombinasi Jumlah & Hari
    DecisionTree(
      name: 'Pohon 6: Kombinasi Antrian-Hari',
      predict: (features) {
        final hari = features['hari'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;
        
        bool hariRamai = ['senin', 'sabtu'].contains(hari.toLowerCase());
        
        if (hariRamai && jumlahAntrian > 5) {
          return (jumlahAntrian * rataRata * 1.25).round();
        } else if (hariRamai) {
          return (jumlahAntrian * rataRata * 1.15).round();
        } else if (jumlahAntrian > 5) {
          return (jumlahAntrian * rataRata * 1.1).round();
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 7: Weighted Average dari Historis Terbaru
    DecisionTree(
      name: 'Pohon 7: Weighted Historis Terbaru',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;
        
        // Ambil 10 data terbaru untuk poli yang sama
        final recentData = historicalData
            .where((data) =>
                data['kodePoli'] == kodePoli &&
                data['waktuTungguAktual'] != null)
            .toList();
        
        if (recentData.isEmpty) {
          return jumlahAntrian * rataRata;
        }
        
        // Sort by waktuDaftar descending dan ambil 10 terbaru
        recentData.sort((a, b) => (b['waktuDaftar'] as DateTime)
            .compareTo(a['waktuDaftar'] as DateTime));
        final last10 = recentData.take(10).toList();
        
        // Weighted average: data lebih baru punya bobot lebih tinggi
        double totalWeight = 0;
        double weightedSum = 0;
        for (int i = 0; i < last10.length; i++) {
          double weight = (10 - i) / 10; // Bobot menurun
          weightedSum += (last10[i]['waktuTungguAktual'] as int) * weight;
          totalWeight += weight;
        }
        
        if (totalWeight == 0) return jumlahAntrian * rataRata;
        return (weightedSum / totalWeight).round();
      },
    ),
  ];
  // ============================================================
  // AKHIR DEFINISI POHON - TAMBAH POHON BARU DI ATAS BARIS INI
  // ============================================================

  /// Prediksi waktu tunggu menggunakan Random Forest
  /// Mengembalikan estimasi dalam menit dan detail setiap pohon
  static Map<String, dynamic> predictWaitTime({
    required int jumlahAntrianSebelum,
    required String kodePoli,
    required String hari,
    required int jamDaftar,
  }) {
    final rataRata = PoliConstants.getRataRataWaktu(kodePoli);
    
    final features = {
      'jumlahAntrianSebelum': jumlahAntrianSebelum,
      'kodePoli': kodePoli,
      'hari': hari,
      'jamDaftar': jamDaftar,
      'rataRataWaktuPelayanan': rataRata,
    };

    // Kumpulkan prediksi dari semua pohon
    final treePredictions = <Map<String, dynamic>>[];
    int totalPrediction = 0;

    for (final tree in _trees) {
      final prediction = tree.predict(features);
      treePredictions.add({
        'name': tree.name,
        'prediction': prediction,
      });
      totalPrediction += prediction;
    }

    // Rata-rata dari semua pohon (majority voting)
    final finalPrediction = (totalPrediction / _trees.length).round();

    return {
      'estimasi': finalPrediction,
      'treePredictions': treePredictions,
      'treeCount': _trees.length,
      'features': features,
    };
  }

  /// Prediksi simple untuk data pertama (tanpa historis)
  static int predictSimple({
    required int nomorAntrian,
    required String kodePoli,
  }) {
    final rataRata = PoliConstants.getRataRataWaktu(kodePoli);
    return (nomorAntrian - 1) * rataRata;
  }

  /// Update data historis dari Firebase
  static void updateHistoricalData(List<Map<String, dynamic>> data) {
    historicalData = data;
  }

  /// Cek apakah ada data historis yang cukup untuk Random Forest
  static bool hasEnoughHistoricalData(String kodePoli) {
    final poliData = historicalData.where(
      (data) => data['kodePoli'] == kodePoli && data['waktuTungguAktual'] != null,
    );
    return poliData.length >= 1; // Minimal 1 data historis
  }
}

/// Class untuk Decision Tree individual
class DecisionTree {
  final String name;
  final int Function(Map<String, dynamic> features) predict;

  DecisionTree({
    required this.name,
    required this.predict,
  });
}
