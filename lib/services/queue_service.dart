/// Firebase Service untuk Operasi CRUD Antrian
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/queue_model.dart';
import '../core/constants/poli_constants.dart';
import 'random_forest_service.dart';

class QueueService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'antrian';

  /// Mendapatkan referensi collection
  static CollectionReference<Map<String, dynamic>> get _antrianRef =>
      _firestore.collection(_collection);

  /// Generate nomor antrian berdasarkan poli untuk hari ini
  static Future<String> generateNomorAntrian(String kodePoli) async {
    final today = _getTodayDateString();
    
    // Cari semua antrian untuk poli ini hari ini (tanpa orderBy untuk hindari composite index)
    final querySnapshot = await _antrianRef
        .where('kodePoli', isEqualTo: kodePoli)
        .where('hari', isEqualTo: today)
        .get();

    int maxNumber = 0;
    for (final doc in querySnapshot.docs) {
      final nomorAntrian = doc.data()['nomorAntrian'] as String;
      final parts = nomorAntrian.split('-');
      if (parts.length == 2) {
        final num = int.tryParse(parts[1]) ?? 0;
        if (num > maxNumber) maxNumber = num;
      }
    }

    return '$kodePoli-${(maxNumber + 1).toString().padLeft(2, '0')}';
  }

  /// Hitung jumlah antrian sebelumnya hari ini untuk poli tertentu
  static Future<int> getJumlahAntrianSebelum(String kodePoli) async {
    final today = _getTodayDateString();
    
    final querySnapshot = await _antrianRef
        .where('kodePoli', isEqualTo: kodePoli)
        .where('hari', isEqualTo: today)
        .where('statusAntrian', isEqualTo: PoliConstants.statusMenunggu)
        .get();

    return querySnapshot.docs.length;
  }

  /// Buat antrian baru dengan prediksi waktu tunggu
  static Future<QueueModel> createQueue({
    required String namaPasien,
    required String jenisKelamin,
    required int usia,
    required String poli,
    required String kodePoli,
  }) async {
    final now = DateTime.now();
    
    // Cek jam operasional puskesmas (08:00 - 16:00)
    final jamBukaHari = DateTime(now.year, now.month, now.day, 
        PoliConstants.jamBukaHour, PoliConstants.jamBukaMinute);
    final jamTutup = DateTime(now.year, now.month, now.day, 
        PoliConstants.jamTutupHour, PoliConstants.jamTutupMinute);
    
    // Tentukan tanggal antrian (hari ini atau besok)
    DateTime tanggalAntrian;
    String hariAntrian;
    bool isForTomorrow = false;
    
    if (now.isBefore(jamBukaHari) || now.isAfter(jamTutup)) {
      // Di luar jam operasional, antrian untuk besok
      tanggalAntrian = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
      isForTomorrow = true;
    } else {
      // Dalam jam operasional, antrian untuk hari ini
      tanggalAntrian = now;
    }
    
    final hariString = DateFormat('yyyy-MM-dd').format(tanggalAntrian);
    hariAntrian = _getHariNama(tanggalAntrian.weekday);

    // Generate nomor antrian untuk tanggal tersebut
    final nomorAntrian = await _generateNomorAntrianForDate(kodePoli, hariString);
    
    // Hitung jumlah antrian sebelum untuk tanggal tersebut
    final jumlahAntrianSebelum = await _getJumlahAntrianSebelumForDate(kodePoli, hariString);
    
    // Load data historis untuk prediksi
    await loadHistoricalData();
    
    // Prediksi waktu tunggu
    final rataRata = PoliConstants.getRataRataWaktu(kodePoli);
    Map<String, dynamic> predictionResult;
    int estimasiWaktuTunggu;

    // Cek apakah ada data historis untuk Random Forest
    final hasHistorical = RandomForestService.hasEnoughHistoricalData(kodePoli);
    
    if (hasHistorical) {
      // Gunakan Random Forest
      predictionResult = RandomForestService.predictWaitTime(
        jumlahAntrianSebelum: jumlahAntrianSebelum,
        kodePoli: kodePoli,
        hari: hariAntrian,
        jamDaftar: isForTomorrow ? PoliConstants.jamBukaHour : now.hour,
      );
      estimasiWaktuTunggu = predictionResult['estimasi'] as int;
    } else {
      // Gunakan rumus simple untuk data pertama
      estimasiWaktuTunggu = RandomForestService.predictSimple(
        nomorAntrian: jumlahAntrianSebelum + 1,
        kodePoli: kodePoli,
      );
      predictionResult = {
        'estimasi': estimasiWaktuTunggu,
        'method': 'simple',
        'formula': '(nomor_antrian - 1) * rata_rata_layanan',
        'treePredictions': [],
        'treeCount': 0,
      };
    }

    // Hitung jam efektif pelayanan (perkiraan dipanggil)
    // Berdasarkan waktu aktual atau jam buka jika antrian untuk besok/belum ada antrian
    DateTime baseTime;
    if (isForTomorrow) {
      // Antrian untuk besok, mulai dari jam buka
      baseTime = DateTime(tanggalAntrian.year, tanggalAntrian.month, tanggalAntrian.day,
          PoliConstants.jamBukaHour, PoliConstants.jamBukaMinute);
    } else if (jumlahAntrianSebelum == 0) {
      // Antrian pertama hari ini
      if (now.isBefore(jamBukaHari)) {
        // Sebelum jam buka, perkiraan dari jam buka
        baseTime = jamBukaHari;
      } else {
        // Sudah lewat jam buka, perkiraan dari sekarang
        baseTime = now;
      }
    } else {
      // Ada antrian sebelumnya, hitung dari waktu sekarang + estimasi
      baseTime = now;
    }
    
    final jamEfektif = baseTime.add(Duration(minutes: estimasiWaktuTunggu));

    // Buat model antrian
    final queue = QueueModel(
      nomorAntrian: nomorAntrian,
      namaPasien: namaPasien,
      jenisKelamin: jenisKelamin,
      usia: usia,
      poli: poli,
      kodePoli: kodePoli,
      waktuDaftar: now,
      hari: hariString,
      jumlahAntrianSebelum: jumlahAntrianSebelum,
      jamBukaPuskesmas: PoliConstants.jamBukaPuskesmas,
      rataRataWaktuPelayanan: rataRata,
      jamEfektifPelayanan: jamEfektif,
      statusAntrian: PoliConstants.statusMenunggu,
      estimasiWaktuTunggu: estimasiWaktuTunggu,
      predictionDetails: predictionResult,
    );

    // Simpan ke Firebase
    final docRef = await _antrianRef.add(queue.toMap());
    
    return queue.copyWith(id: docRef.id);
  }
  
  /// Generate nomor antrian untuk tanggal tertentu
  static Future<String> _generateNomorAntrianForDate(String kodePoli, String tanggal) async {
    final querySnapshot = await _antrianRef
        .where('kodePoli', isEqualTo: kodePoli)
        .where('hari', isEqualTo: tanggal)
        .get();

    int maxNumber = 0;
    for (final doc in querySnapshot.docs) {
      final nomorAntrian = doc.data()['nomorAntrian'] as String;
      final parts = nomorAntrian.split('-');
      if (parts.length == 2) {
        final num = int.tryParse(parts[1]) ?? 0;
        if (num > maxNumber) maxNumber = num;
      }
    }

    return '$kodePoli-${(maxNumber + 1).toString().padLeft(2, '0')}';
  }
  
  /// Hitung jumlah antrian sebelumnya untuk tanggal tertentu
  static Future<int> _getJumlahAntrianSebelumForDate(String kodePoli, String tanggal) async {
    final querySnapshot = await _antrianRef
        .where('kodePoli', isEqualTo: kodePoli)
        .where('hari', isEqualTo: tanggal)
        .where('statusAntrian', isEqualTo: PoliConstants.statusMenunggu)
        .get();

    return querySnapshot.docs.length;
  }

  /// Load data historis untuk Random Forest
  static Future<void> loadHistoricalData() async {
    // Query sederhana tanpa composite index kompleks
    final querySnapshot = await _antrianRef
        .where('statusAntrian', isEqualTo: PoliConstants.statusSelesai)
        .limit(100)
        .get();

    final historicalData = <Map<String, dynamic>>[];
    for (final doc in querySnapshot.docs) {
      final data = doc.data();
      // Filter yang punya waktuTungguAktual
      if (data['waktuTungguAktual'] != null) {
        historicalData.add({
          'kodePoli': data['kodePoli'],
          'jumlahAntrianSebelum': data['jumlahAntrianSebelum'],
          'hari': data['hari'],
          'waktuTungguAktual': data['waktuTungguAktual'],
          'waktuDaftar': (data['waktuDaftar'] as Timestamp).toDate(),
        });
      }
    }

    // Sort by waktuDaftar descending di client side
    historicalData.sort((a, b) => 
        (b['waktuDaftar'] as DateTime).compareTo(a['waktuDaftar'] as DateTime));

    RandomForestService.updateHistoricalData(historicalData);
  }

  /// Update status antrian menjadi Dilayani
  static Future<void> updateStatusDilayani(String docId) async {
    final now = DateTime.now();
    
    await _antrianRef.doc(docId).update({
      'statusAntrian': PoliConstants.statusDilayani,
      'jamDipanggil': Timestamp.fromDate(now),
    });
  }

  /// Update status antrian menjadi Selesai dan hitung waktu tunggu aktual
  static Future<void> updateStatusSelesai(String docId) async {
    // Ambil data antrian
    final doc = await _antrianRef.doc(docId).get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final waktuDaftar = (data['waktuDaftar'] as Timestamp).toDate();
    final jamDipanggil = data['jamDipanggil'] != null
        ? (data['jamDipanggil'] as Timestamp).toDate()
        : DateTime.now();

    // Hitung waktu tunggu aktual dalam menit
    final waktuTungguAktual = jamDipanggil.difference(waktuDaftar).inMinutes;

    await _antrianRef.doc(docId).update({
      'statusAntrian': PoliConstants.statusSelesai,
      'waktuTungguAktual': waktuTungguAktual,
    });
  }

  /// Stream antrian hari ini untuk poli tertentu (realtime)
  static Stream<List<QueueModel>> streamAntrianHariIni(String kodePoli) {
    final today = _getTodayDateString();
    
    return _antrianRef
        .where('kodePoli', isEqualTo: kodePoli)
        .where('hari', isEqualTo: today)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => QueueModel.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => a.waktuDaftar.compareTo(b.waktuDaftar));
          return list;
        });
  }

  /// Stream semua antrian hari ini (realtime)
  static Stream<List<QueueModel>> streamSemuaAntrianHariIni() {
    final today = _getTodayDateString();
    
    return _antrianRef
        .where('hari', isEqualTo: today)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => QueueModel.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => a.waktuDaftar.compareTo(b.waktuDaftar));
          return list;
        });
  }

  /// Stream antrian menunggu hari ini untuk display TV (realtime)
  static Stream<List<QueueModel>> streamAntrianMenungguHariIni() {
    final today = _getTodayDateString();
    
    return _antrianRef
        .where('hari', isEqualTo: today)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => QueueModel.fromMap(doc.data(), doc.id))
              .where((q) => q.statusAntrian == PoliConstants.statusMenunggu)
              .toList();
          list.sort((a, b) => a.waktuDaftar.compareTo(b.waktuDaftar));
          return list;
        });
  }

  /// Get antrian berdasarkan tanggal
  static Future<List<QueueModel>> getAntrianByDate(DateTime date) async {
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    
    final querySnapshot = await _antrianRef
        .where('hari', isEqualTo: dateString)
        .get();

    final list = querySnapshot.docs
        .map((doc) => QueueModel.fromMap(doc.data(), doc.id))
        .toList();
    list.sort((a, b) => a.waktuDaftar.compareTo(b.waktuDaftar));
    return list;
  }

  /// Get antrian berdasarkan tanggal dan poli
  static Future<List<QueueModel>> getAntrianByDateAndPoli(
    DateTime date,
    String kodePoli,
  ) async {
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    
    final querySnapshot = await _antrianRef
        .where('hari', isEqualTo: dateString)
        .where('kodePoli', isEqualTo: kodePoli)
        .get();

    final list = querySnapshot.docs
        .map((doc) => QueueModel.fromMap(doc.data(), doc.id))
        .toList();
    list.sort((a, b) => a.waktuDaftar.compareTo(b.waktuDaftar));
    return list;
  }

  /// Get ringkasan antrian hari ini
  static Future<Map<String, int>> getRingkasanHariIni() async {
    final today = _getTodayDateString();
    
    final querySnapshot = await _antrianRef
        .where('hari', isEqualTo: today)
        .get();

    int total = 0;
    int menunggu = 0;
    int dilayani = 0;
    int selesai = 0;
    int poliUmum = 0;
    int poliLansia = 0;
    int poliAnak = 0;
    int poliKia = 0;
    int poliGigi = 0;

    for (final doc in querySnapshot.docs) {
      final data = doc.data();
      total++;
      
      switch (data['statusAntrian']) {
        case 'Menunggu':
          menunggu++;
          break;
        case 'Dilayani':
          dilayani++;
          break;
        case 'Selesai':
          selesai++;
          break;
      }

      switch (data['kodePoli']) {
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

    return {
      'total': total,
      'menunggu': menunggu,
      'dilayani': dilayani,
      'selesai': selesai,
      'poliUmum': poliUmum,
      'poliLansia': poliLansia,
      'poliAnak': poliAnak,
      'poliKia': poliKia,
      'poliGigi': poliGigi,
    };
  }

  /// Get detail antrian by ID
  static Future<QueueModel?> getAntrianById(String docId) async {
    final doc = await _antrianRef.doc(docId).get();
    if (!doc.exists) return null;
    return QueueModel.fromMap(doc.data()!, doc.id);
  }

  /// Helper: Get today's date string
  static String _getTodayDateString() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  /// Helper: Get nama hari
  static String _getHariNama(int weekday) {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return days[weekday - 1];
  }

  // ============ CALL QUEUE BROADCAST ============
  
  static const String _callCollection = 'call_queue';
  
  /// Referensi collection call_queue
  static CollectionReference<Map<String, dynamic>> get _callRef =>
      _firestore.collection(_callCollection);

  /// Broadcast panggilan antrian ke display TV
  static Future<void> broadcastCallQueue(QueueModel queue) async {
    await _callRef.doc('current').set({
      'id': queue.id,
      'nomorAntrian': queue.nomorAntrian,
      'namaPasien': queue.namaPasien,
      'poli': queue.poli,
      'kodePoli': queue.kodePoli,
      'calledAt': FieldValue.serverTimestamp(),
      'isActive': true,
    });
    
    // Auto deactivate setelah 6 detik (beri buffer)
    Future.delayed(const Duration(seconds: 6), () async {
      try {
        await _callRef.doc('current').update({'isActive': false});
      } catch (e) {
        // Ignore jika sudah di-update
      }
    });
  }

  /// Stream untuk listen panggilan antrian (untuk display TV)
  static Stream<Map<String, dynamic>?> streamCalledQueue() {
    return _callRef.doc('current').snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data();
      if (data == null || data['isActive'] != true) return null;
      return data;
    });
  }
}
