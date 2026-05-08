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
      name: 'Pohon Logika 1 (antrian=0=0, antrian<=3=rata2, antrian<=6=rata2x1.1, antrian<=10=rata2x1.15, antrian>10=rata2x1.2)',
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
      name: 'Pohon Logika 2 (hari: Seninx1.3, Sel/Rabx1.1, Kamx1.0, Jumx0.95, Sabx1.2)',
      predict: (features) {
        final hari = features['hari'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;
        
        double faktorHari = 1.0;
        switch (hari.toLowerCase()) {
          case 'senin':
            faktorHari = 1.3; // Senin biasanya ramai
            break;
          case 'selasa' || 'rabu':
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
      name: 'Pohon Logika 3 (jam: 8-10x1.2, 10-12x1.0, 12-14x0.85, lainx0.9)',
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
      name: 'Pohon Logika 4 (poli: PUx1.0, PGx1.15, PKx1.1)',
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
      name: 'Pohon Logika 5 (rata-rata histori dgn kondisi poli & antrian serupa)',
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
      name: 'Pohon Logika 6 (Senin/Sabtu & antrian>5x1.25, Senin/Sabtux1.15, antrian>5x1.1)',
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
      name: 'Pohon Logika 7 (rata-rata terbobot 10 data historis terbaru)',
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

    // POHON 8: poli=2, antrian≤2, daftar<08:00
    DecisionTree(
      name: 'Pohon Logika 8 (PK + antrian<=2 + daftar<08:00 = 10 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final jamDaftar = features['jamDaftar'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (kodePoli == 'PK' && jumlahAntrian <= 2 && jamDaftar < 8) {
          return 10;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 9: poli=1, antrian≤3, daftar<08:00
    DecisionTree(
      name: 'Pohon Logika 9 (PU + antrian<=3 + daftar<08:00 = 15 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final jamDaftar = features['jamDaftar'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (kodePoli == 'PU' && jumlahAntrian <= 3 && jamDaftar < 8) {
          return 15;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 10: poli=3, antrian≤3, daftar<08:30
    DecisionTree(
      name: 'Pohon Logika 10 (PA + antrian<=3 + daftar<08:30 = 15 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final jamDaftar = features['jamDaftar'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (kodePoli == 'PA' && jumlahAntrian <= 3 && jamDaftar < 9) {
          return 15;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 11: poli=4, antrian≤2, daftar<08:30
    DecisionTree(
      name: 'Pohon Logika 11 (PL + antrian<=2 + daftar<08:30 = 20 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final jamDaftar = features['jamDaftar'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (kodePoli == 'PL' && jumlahAntrian <= 2 && jamDaftar < 9) {
          return 20;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 12: poli=5, antrian≤1, daftar<08:00
    DecisionTree(
      name: 'Pohon Logika 12 (PG + antrian<=1 + daftar<08:00 = 20 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final jamDaftar = features['jamDaftar'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (kodePoli == 'PG' && jumlahAntrian <= 1 && jamDaftar < 8) {
          return 20;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 13: poli=5, antrian=3, daftar<08:30
    DecisionTree(
      name: 'Pohon Logika 13 (PG + antrian=3 + daftar<08:30 = 45 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final jamDaftar = features['jamDaftar'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (kodePoli == 'PG' && jumlahAntrian == 3 && jamDaftar < 9) {
          return 45;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 14: poli=1, antrian=5, hari≠1
    DecisionTree(
      name: 'Pohon Logika 14 (PU + antrian=5 + bukan Senin = 25 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final hari = features['hari'] as String;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        final hariLower = hari.toLowerCase();
        if (kodePoli == 'PU' && jumlahAntrian == 5 && hariLower != 'senin') {
          return 25;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 15: poli=2, antrian=4, hari≠1
    DecisionTree(
      name: 'Pohon Logika 15 (PK + antrian=4 + bukan Senin = 15 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final hari = features['hari'] as String;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        final hariLower = hari.toLowerCase();
        if (kodePoli == 'PK' && jumlahAntrian == 4 && hariLower != 'senin') {
          return 15;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 16: poli=3, antrian=5, hari=1
    DecisionTree(
      name: 'Pohon Logika 16 (PA + antrian=5 + Senin = 30 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final hari = features['hari'] as String;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (kodePoli == 'PA' && jumlahAntrian == 5 && hari.toLowerCase() == 'senin') {
          return 30;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 17: poli=4, antrian=4, hari=1
    DecisionTree(
      name: 'Pohon Logika 17 (PL + antrian=4 + Senin = 35 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final hari = features['hari'] as String;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (kodePoli == 'PL' && jumlahAntrian == 4 && hari.toLowerCase() == 'senin') {
          return 35;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 18: poli=1, antrian=6
    DecisionTree(
      name: 'Pohon Logika 18 (PU + antrian=6 = 30 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (kodePoli == 'PU' && jumlahAntrian == 6) {
          return 30;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 19: poli=2, antrian=6
    DecisionTree(
      name: 'Pohon Logika 19 (PK + antrian=6 = 18 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (kodePoli == 'PK' && jumlahAntrian == 6) {
          return 18;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 20: poli=3, antrian=7
    DecisionTree(
      name: 'Pohon Logika 20 (PA + antrian=7 = 35 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (kodePoli == 'PA' && jumlahAntrian == 7) {
          return 35;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 21: poli=4, antrian=6
    DecisionTree(
      name: 'Pohon Logika 21 (PL + antrian=6 = 42 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (kodePoli == 'PL' && jumlahAntrian == 6) {
          return 42;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 22: poli=5, antrian=5
    DecisionTree(
      name: 'Pohon Logika 22 (PG + antrian=5 = 75 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (kodePoli == 'PG' && jumlahAntrian == 5) {
          return 75;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 23: poli=5, antrian=8
    DecisionTree(
      name: 'Pohon Logika 23 (PG + antrian=8 = 120 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (kodePoli == 'PG' && jumlahAntrian == 8) {
          return 120;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 24: poli=1, antrian=8, hari=1
    DecisionTree(
      name: 'Pohon Logika 24 (PU + antrian=8 + Senin = 50 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final hari = features['hari'] as String;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (kodePoli == 'PU' && jumlahAntrian == 8 && hari.toLowerCase() == 'senin') {
          return 50;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 25: poli=2, antrian=8, hari=1
    DecisionTree(
      name: 'Pohon Logika 25 (PK + antrian=8 + Senin = 30 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final hari = features['hari'] as String;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (kodePoli == 'PK' && jumlahAntrian == 8 && hari.toLowerCase() == 'senin') {
          return 30;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 26: poli=3, antrian=10
    DecisionTree(
      name: 'Pohon Logika 26 (PA + antrian=10 = 50 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (kodePoli == 'PA' && jumlahAntrian == 10) {
          return 50;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 27: poli=4, antrian=9
    DecisionTree(
      name: 'Pohon Logika 27 (PL + antrian=9 = 63 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (kodePoli == 'PL' && jumlahAntrian == 9) {
          return 63;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 28: poli=1, antrian=10
    DecisionTree(
      name: 'Pohon Logika 28 (PU + antrian=10 = 50 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (kodePoli == 'PU' && jumlahAntrian == 10) {
          return 50;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 29: poli=2, antrian=10
    DecisionTree(
      name: 'Pohon Logika 29 (PK + antrian=10 = 30 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (kodePoli == 'PK' && jumlahAntrian == 10) {
          return 30;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 30: poli=3, antrian=12
    DecisionTree(
      name: 'Pohon Logika 30 (PA + antrian=12 = 60 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (kodePoli == 'PA' && jumlahAntrian == 12) {
          return 60;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 31: poli=4, antrian=10
    DecisionTree(
      name: 'Pohon Logika 31 (PL + antrian=10 = 70 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (kodePoli == 'PL' && jumlahAntrian == 10) {
          return 70;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 32: poli=5, antrian=10
    DecisionTree(
      name: 'Pohon Logika 32 (PG + antrian=10 = 150 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (kodePoli == 'PG' && jumlahAntrian == 10) {
          return 150;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 33: poli=5, antrian=12
    DecisionTree(
      name: 'Pohon Logika 33 (PG + antrian=12 = 180 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (kodePoli == 'PG' && jumlahAntrian == 12) {
          return 180;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 34: poli=1, antrian=12, hari=1
    DecisionTree(
      name: 'Pohon Logika 34 (PU + antrian=12 + Senin = 70 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final hari = features['hari'] as String;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (kodePoli == 'PU' && jumlahAntrian == 12 && hari.toLowerCase() == 'senin') {
          return 70;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 35: poli=2, antrian=12, hari=1
    DecisionTree(
      name: 'Pohon Logika 35 (PK + antrian=12 + Senin = 40 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final hari = features['hari'] as String;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (kodePoli == 'PK' && jumlahAntrian == 12 && hari.toLowerCase() == 'senin') {
          return 40;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 36: poli=3, antrian=15
    DecisionTree(
      name: 'Pohon Logika 36 (PA + antrian=15 = 75 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (kodePoli == 'PA' && jumlahAntrian == 15) {
          return 75;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 37: poli=4, antrian=14
    DecisionTree(
      name: 'Pohon Logika 37 (PL + antrian=14 = 98 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (kodePoli == 'PL' && jumlahAntrian == 14) {
          return 98;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 38: hari=1, poli=1, antrian=5
    DecisionTree(
      name: 'Pohon Logika 38 (Senin + PU + antrian=5 = 35 menit)',
      predict: (features) {
        final hari = features['hari'] as String;
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (hari.toLowerCase() == 'senin' && kodePoli == 'PU' && jumlahAntrian == 5) {
          return 35;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 39: hari=1, poli=2, antrian=5
    DecisionTree(
      name: 'Pohon Logika 39 (Senin + PK + antrian=5 = 20 menit)',
      predict: (features) {
        final hari = features['hari'] as String;
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (hari.toLowerCase() == 'senin' && kodePoli == 'PK' && jumlahAntrian == 5) {
          return 20;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 40: hari=1, poli=3, antrian=7
    DecisionTree(
      name: 'Pohon Logika 40 (Senin + PA + antrian=7 = 40 menit)',
      predict: (features) {
        final hari = features['hari'] as String;
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (hari.toLowerCase() == 'senin' && kodePoli == 'PA' && jumlahAntrian == 7) {
          return 40;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 41: hari=1, poli=4, antrian=6
    DecisionTree(
      name: 'Pohon Logika 41 (Senin + PL + antrian=6 = 50 menit)',
      predict: (features) {
        final hari = features['hari'] as String;
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (hari.toLowerCase() == 'senin' && kodePoli == 'PL' && jumlahAntrian == 6) {
          return 50;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 42: hari=1, poli=5, antrian=6
    DecisionTree(
      name: 'Pohon Logika 42 (Senin + PG + antrian=6 = 90 menit)',
      predict: (features) {
        final hari = features['hari'] as String;
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (hari.toLowerCase() == 'senin' && kodePoli == 'PG' && jumlahAntrian == 6) {
          return 90;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 43: hari=2-4, poli=1, antrian=5
    DecisionTree(
      name: 'Pohon Logika 43 (Sel-Kam + PU + antrian=5 = 25 menit)',
      predict: (features) {
        final hari = features['hari'] as String;
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        final hariLower = hari.toLowerCase();
        bool hari234 = hariLower == 'selasa' || hariLower == 'rabu' || hariLower == 'kamis';
        if (hari234 && kodePoli == 'PU' && jumlahAntrian == 5) {
          return 25;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 44: hari=2-4, poli=2, antrian=5
    DecisionTree(
      name: 'Pohon Logika 44 (Sel-Kam + PK + antrian=5 = 15 menit)',
      predict: (features) {
        final hari = features['hari'] as String;
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        final hariLower = hari.toLowerCase();
        bool hari234 = hariLower == 'selasa' || hariLower == 'rabu' || hariLower == 'kamis';
        if (hari234 && kodePoli == 'PK' && jumlahAntrian == 5) {
          return 15;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 45: hari=2-4, poli=3, antrian=7
    DecisionTree(
      name: 'Pohon Logika 45 (Sel-Kam + PA + antrian=7 = 35 menit)',
      predict: (features) {
        final hari = features['hari'] as String;
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        final hariLower = hari.toLowerCase();
        bool hari234 = hariLower == 'selasa' || hariLower == 'rabu' || hariLower == 'kamis';
        if (hari234 && kodePoli == 'PA' && jumlahAntrian == 7) {
          return 35;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 46: hari=2-4, poli=4, antrian=6
    DecisionTree(
      name: 'Pohon Logika 46 (Sel-Kam + PL + antrian=6 = 42 menit)',
      predict: (features) {
        final hari = features['hari'] as String;
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        final hariLower = hari.toLowerCase();
        bool hari234 = hariLower == 'selasa' || hariLower == 'rabu' || hariLower == 'kamis';
        if (hari234 && kodePoli == 'PL' && jumlahAntrian == 6) {
          return 42;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 47: hari=2-4, poli=5, antrian=6
    DecisionTree(
      name: 'Pohon Logika 47 (Sel-Kam + PG + antrian=6 = 90 menit)',
      predict: (features) {
        final hari = features['hari'] as String;
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        final hariLower = hari.toLowerCase();
        bool hari234 = hariLower == 'selasa' || hariLower == 'rabu' || hariLower == 'kamis';
        if (hari234 && kodePoli == 'PG' && jumlahAntrian == 6) {
          return 90;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 48: hari=5, poli=1, antrian=8
    DecisionTree(
      name: 'Pohon Logika 48 (Jumat + PU + antrian=8 = 45 menit)',
      predict: (features) {
        final hari = features['hari'] as String;
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (hari.toLowerCase() == 'jumat' && kodePoli == 'PU' && jumlahAntrian == 8) {
          return 45;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 49: hari=5, poli=2, antrian=8
    DecisionTree(
      name: 'Pohon Logika 49 (Jumat + PK + antrian=8 = 25 menit)',
      predict: (features) {
        final hari = features['hari'] as String;
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (hari.toLowerCase() == 'jumat' && kodePoli == 'PK' && jumlahAntrian == 8) {
          return 25;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 50: hari=5, poli=5, antrian=8
    DecisionTree(
      name: 'Pohon Logika 50 (Jumat + PG + antrian=8 = 120 menit)',
      predict: (features) {
        final hari = features['hari'] as String;
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (hari.toLowerCase() == 'jumat' && kodePoli == 'PG' && jumlahAntrian == 8) {
          return 120;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 51: hari=6, poli=1, antrian=4
    DecisionTree(
      name: 'Pohon Logika 51 (Sabtu + PU + antrian=4 = 20 menit)',
      predict: (features) {
        final hari = features['hari'] as String;
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (hari.toLowerCase() == 'sabtu' && kodePoli == 'PU' && jumlahAntrian == 4) {
          return 20;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 52: hari=6, poli=2, antrian=4
    DecisionTree(
      name: 'Pohon Logika 52 (Sabtu + PK + antrian=4 = 12 menit)',
      predict: (features) {
        final hari = features['hari'] as String;
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (hari.toLowerCase() == 'sabtu' && kodePoli == 'PK' && jumlahAntrian == 4) {
          return 12;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 53: hari=6, poli=3, antrian=6
    DecisionTree(
      name: 'Pohon Logika 53 (Sabtu + PA + antrian=6 = 30 menit)',
      predict: (features) {
        final hari = features['hari'] as String;
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (hari.toLowerCase() == 'sabtu' && kodePoli == 'PA' && jumlahAntrian == 6) {
          return 30;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 54: hari=6, poli=4, antrian=6
    DecisionTree(
      name: 'Pohon Logika 54 (Sabtu + PL + antrian=6 = 42 menit)',
      predict: (features) {
        final hari = features['hari'] as String;
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (hari.toLowerCase() == 'sabtu' && kodePoli == 'PL' && jumlahAntrian == 6) {
          return 42;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 55: hari=6, poli=5, antrian=5
    DecisionTree(
      name: 'Pohon Logika 55 (Sabtu + PG + antrian=5 = 75 menit)',
      predict: (features) {
        final hari = features['hari'] as String;
        final kodePoli = features['kodePoli'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (hari.toLowerCase() == 'sabtu' && kodePoli == 'PG' && jumlahAntrian == 5) {
          return 75;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 56: poli=2, daftar<08:00, antrian≤3
    DecisionTree(
      name: 'Pohon Logika 56 (PK + daftar<08:00 + antrian<=3 = 12 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final jamDaftar = features['jamDaftar'] as int;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (kodePoli == 'PK' && jamDaftar < 8 && jumlahAntrian <= 3) {
          return 12;
        }
        return jumlahAntrian * rataRata;
      },
    ),

    // POHON 57: poli=5, hari=1, antrian≥8
    DecisionTree(
      name: 'Pohon Logika 57 (PG + Senin + antrian>=8 = 130 menit)',
      predict: (features) {
        final kodePoli = features['kodePoli'] as String;
        final hari = features['hari'] as String;
        final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
        final rataRata = features['rataRataWaktuPelayanan'] as int;

        if (kodePoli == 'PG' && hari.toLowerCase() == 'senin' && jumlahAntrian >= 8) {
          return 130;
        }
        return jumlahAntrian * rataRata;
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
