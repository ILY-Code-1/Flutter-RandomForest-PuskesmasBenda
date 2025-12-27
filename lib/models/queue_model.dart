/// Model data untuk Antrian Pasien
/// Menyimpan semua data yang diperlukan untuk prediksi dan tracking antrian
import 'package:cloud_firestore/cloud_firestore.dart';

class QueueModel {
  final String? id;
  final String nomorAntrian;
  final String namaPasien;
  final String jenisKelamin;
  final int usia;
  final String poli;
  final String kodePoli;
  final DateTime waktuDaftar;
  final DateTime? jamDipanggil;
  final String hari;
  final int jumlahAntrianSebelum;
  final String jamBukaPuskesmas;
  final int rataRataWaktuPelayanan; // dalam menit
  final DateTime jamEfektifPelayanan;
  final int? waktuTungguAktual; // dalam menit, null sampai dilayani
  final String statusAntrian; // Menunggu, Dilayani, Selesai
  final int estimasiWaktuTunggu; // hasil prediksi dalam menit
  final Map<String, dynamic>? predictionDetails; // detail pohon RF

  QueueModel({
    this.id,
    required this.nomorAntrian,
    required this.namaPasien,
    required this.jenisKelamin,
    required this.usia,
    required this.poli,
    required this.kodePoli,
    required this.waktuDaftar,
    this.jamDipanggil,
    required this.hari,
    required this.jumlahAntrianSebelum,
    required this.jamBukaPuskesmas,
    required this.rataRataWaktuPelayanan,
    required this.jamEfektifPelayanan,
    this.waktuTungguAktual,
    required this.statusAntrian,
    required this.estimasiWaktuTunggu,
    this.predictionDetails,
  });

  Map<String, dynamic> toMap() {
    return {
      'nomorAntrian': nomorAntrian,
      'namaPasien': namaPasien,
      'jenisKelamin': jenisKelamin,
      'usia': usia,
      'poli': poli,
      'kodePoli': kodePoli,
      'waktuDaftar': Timestamp.fromDate(waktuDaftar),
      'jamDipanggil': jamDipanggil != null ? Timestamp.fromDate(jamDipanggil!) : null,
      'hari': hari,
      'jumlahAntrianSebelum': jumlahAntrianSebelum,
      'jamBukaPuskesmas': jamBukaPuskesmas,
      'rataRataWaktuPelayanan': rataRataWaktuPelayanan,
      'jamEfektifPelayanan': Timestamp.fromDate(jamEfektifPelayanan),
      'waktuTungguAktual': waktuTungguAktual,
      'statusAntrian': statusAntrian,
      'estimasiWaktuTunggu': estimasiWaktuTunggu,
      'predictionDetails': predictionDetails,
    };
  }

  factory QueueModel.fromMap(Map<String, dynamic> map, String docId) {
    return QueueModel(
      id: docId,
      nomorAntrian: map['nomorAntrian'] ?? '',
      namaPasien: map['namaPasien'] ?? '',
      jenisKelamin: map['jenisKelamin'] ?? '',
      usia: map['usia'] ?? 0,
      poli: map['poli'] ?? '',
      kodePoli: map['kodePoli'] ?? '',
      waktuDaftar: (map['waktuDaftar'] as Timestamp).toDate(),
      jamDipanggil: map['jamDipanggil'] != null 
          ? (map['jamDipanggil'] as Timestamp).toDate() 
          : null,
      hari: map['hari'] ?? '',
      jumlahAntrianSebelum: map['jumlahAntrianSebelum'] ?? 0,
      jamBukaPuskesmas: map['jamBukaPuskesmas'] ?? '08:30',
      rataRataWaktuPelayanan: map['rataRataWaktuPelayanan'] ?? 10,
      jamEfektifPelayanan: (map['jamEfektifPelayanan'] as Timestamp).toDate(),
      waktuTungguAktual: map['waktuTungguAktual'],
      statusAntrian: map['statusAntrian'] ?? 'Menunggu',
      estimasiWaktuTunggu: map['estimasiWaktuTunggu'] ?? 0,
      predictionDetails: map['predictionDetails'],
    );
  }

  QueueModel copyWith({
    String? id,
    String? nomorAntrian,
    String? namaPasien,
    String? jenisKelamin,
    int? usia,
    String? poli,
    String? kodePoli,
    DateTime? waktuDaftar,
    DateTime? jamDipanggil,
    String? hari,
    int? jumlahAntrianSebelum,
    String? jamBukaPuskesmas,
    int? rataRataWaktuPelayanan,
    DateTime? jamEfektifPelayanan,
    int? waktuTungguAktual,
    String? statusAntrian,
    int? estimasiWaktuTunggu,
    Map<String, dynamic>? predictionDetails,
  }) {
    return QueueModel(
      id: id ?? this.id,
      nomorAntrian: nomorAntrian ?? this.nomorAntrian,
      namaPasien: namaPasien ?? this.namaPasien,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      usia: usia ?? this.usia,
      poli: poli ?? this.poli,
      kodePoli: kodePoli ?? this.kodePoli,
      waktuDaftar: waktuDaftar ?? this.waktuDaftar,
      jamDipanggil: jamDipanggil ?? this.jamDipanggil,
      hari: hari ?? this.hari,
      jumlahAntrianSebelum: jumlahAntrianSebelum ?? this.jumlahAntrianSebelum,
      jamBukaPuskesmas: jamBukaPuskesmas ?? this.jamBukaPuskesmas,
      rataRataWaktuPelayanan: rataRataWaktuPelayanan ?? this.rataRataWaktuPelayanan,
      jamEfektifPelayanan: jamEfektifPelayanan ?? this.jamEfektifPelayanan,
      waktuTungguAktual: waktuTungguAktual ?? this.waktuTungguAktual,
      statusAntrian: statusAntrian ?? this.statusAntrian,
      estimasiWaktuTunggu: estimasiWaktuTunggu ?? this.estimasiWaktuTunggu,
      predictionDetails: predictionDetails ?? this.predictionDetails,
    );
  }
}
