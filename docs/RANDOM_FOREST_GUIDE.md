# Panduan Random Forest - Sistem Antrian Puskesmas Benda

## Ringkasan

Sistem ini menggunakan algoritma **Random Forest** untuk memprediksi waktu tunggu antrian pasien. Random Forest adalah metode ensemble learning yang menggabungkan hasil dari beberapa Decision Tree untuk menghasilkan prediksi yang lebih akurat.

## Kapan Random Forest Digunakan?

Random Forest **HANYA** digunakan ketika:
1. Terdapat **minimal 1 data historis** dengan status "Selesai" dan memiliki `waktuTungguAktual` (tidak null)
2. Data historis harus untuk **poli yang sama** dengan antrian yang sedang dibuat

### Mengapa Data Saya Masih Menggunakan Simple Rule?

Jika Anda melihat detail antrian menunjukkan "Simple Rule" bukan "Random Forest", berarti:

1. **Belum ada antrian yang status-nya "Selesai"** untuk poli tersebut
2. **Antrian yang selesai belum memiliki `waktuTungguAktual`** - field ini hanya terisi ketika admin mengubah status dari "Dilayani" ke "Selesai"

### Cara Mengaktifkan Random Forest:

1. Buat beberapa antrian di poli tertentu
2. Admin mengubah status antrian:
   - Dari "Menunggu" → "Dilayani" (mengisi `jamDipanggil`)
   - Dari "Dilayani" → "Selesai" (mengisi `waktuTungguAktual`)
3. Setelah ada minimal 1 data dengan status "Selesai", antrian baru akan menggunakan Random Forest

## Struktur 7 Pohon Logika

File: `lib/services/random_forest_service.dart`

### Pohon 1: Berdasarkan Jumlah Antrian
```dart
// Lokasi: baris ~20-30
// Logika: Semakin banyak antrian, semakin lama waktu tunggu
// Faktor scaling berdasarkan jumlah antrian
```

### Pohon 2: Faktor Hari
```dart
// Lokasi: baris ~32-55
// Logika: Hari Senin dan Sabtu biasanya lebih ramai
// Faktor: Senin=1.3, Sabtu=1.2, Jumat=0.95, dll
```

### Pohon 3: Jam Daftar
```dart
// Lokasi: baris ~57-78
// Logika: Jam 08:00-10:00 pagi biasanya lebih ramai
// Faktor: Pagi=1.2, Siang=0.85
```

### Pohon 4: Tipe Poli
```dart
// Lokasi: baris ~80-100
// Logika: Setiap poli memiliki karakteristik berbeda
// Faktor: Gigi=1.15, KIA=1.1, Umum=1.0
```

### Pohon 5: Data Historis Serupa
```dart
// Lokasi: baris ~102-135
// Logika: Mencari data historis dengan kondisi serupa
// Menghitung rata-rata waktu tunggu aktual dari data serupa
```

### Pohon 6: Kombinasi Antrian-Hari
```dart
// Lokasi: baris ~137-158
// Logika: Kombinasi hari ramai + banyak antrian = lebih lama
```

### Pohon 7: Weighted Average Historis Terbaru
```dart
// Lokasi: baris ~160-195
// Logika: Data terbaru diberi bobot lebih tinggi
// 10 data terbaru dengan weighted average
```

## Cara Menambah/Mengurangi Pohon

### Menambah Pohon Baru:

1. Buka file `lib/services/random_forest_service.dart`
2. Cari komentar `// AKHIR DEFINISI POHON`
3. Tambahkan pohon baru sebelum komentar tersebut:

```dart
// POHON 8: Nama Pohon Anda
DecisionTree(
  name: 'Pohon 8: Deskripsi',
  predict: (features) {
    final jumlahAntrian = features['jumlahAntrianSebelum'] as int;
    final rataRata = features['rataRataWaktuPelayanan'] as int;
    final kodePoli = features['kodePoli'] as String;
    final hari = features['hari'] as String;
    final jamDaftar = features['jamDaftar'] as int;
    
    // Logika prediksi Anda
    // Return estimasi waktu dalam menit
    return jumlahAntrian * rataRata;
  },
),
```

### Mengurangi Pohon:

Hapus atau comment out block `DecisionTree(...)` yang tidak diperlukan.

## Features yang Tersedia

Setiap pohon menerima `features` Map dengan data berikut:

| Key | Tipe | Deskripsi |
|-----|------|-----------|
| `jumlahAntrianSebelum` | int | Jumlah antrian yang menunggu sebelum pasien ini |
| `kodePoli` | String | Kode poli (PU, PG, PK) |
| `hari` | String | Nama hari (Senin, Selasa, dst) |
| `jamDaftar` | int | Jam pendaftaran (0-23) |
| `rataRataWaktuPelayanan` | int | Rata-rata waktu pelayanan poli (menit) |

## Data Historis

Data historis diambil dari Firebase collection `antrian` dengan kriteria:
- `statusAntrian` = "Selesai"
- `waktuTungguAktual` tidak null

Data historis yang tersedia di `RandomForestService.historicalData`:

| Key | Tipe | Deskripsi |
|-----|------|-----------|
| `kodePoli` | String | Kode poli |
| `jumlahAntrianSebelum` | int | Jumlah antrian saat itu |
| `hari` | String | Tanggal (yyyy-MM-dd) |
| `waktuTungguAktual` | int | Waktu tunggu aktual (menit) |
| `waktuDaftar` | DateTime | Waktu pendaftaran |

## Hasil Prediksi

Hasil prediksi disimpan di field `predictionDetails` pada model antrian:

```json
{
  "estimasi": 25,
  "method": "randomForest", // atau "simple"
  "treeCount": 7,
  "treePredictions": [
    {"name": "Pohon 1: Jumlah Antrian", "prediction": 20},
    {"name": "Pohon 2: Faktor Hari", "prediction": 26},
    // ... dst
  ],
  "features": {
    "jumlahAntrianSebelum": 2,
    "kodePoli": "PU",
    "hari": "Senin",
    "jamDaftar": 9,
    "rataRataWaktuPelayanan": 10
  }
}
```

## Konfigurasi Waktu Pelayanan

File: `lib/core/constants/poli_constants.dart`

```dart
static const Map<String, int> rataRataWaktuPelayanan = {
  'PU': 10,  // Poli Umum: 10 menit per pasien
  'PG': 15,  // Poli Gigi: 15 menit per pasien
  'PK': 12,  // Poli KIA: 12 menit per pasien
};
```

Ubah nilai ini sesuai dengan rata-rata waktu pelayanan aktual di puskesmas Anda.

## Troubleshooting

### Random Forest tidak aktif:
1. Pastikan ada antrian dengan status "Selesai"
2. Cek di Firebase apakah field `waktuTungguAktual` terisi

### Prediksi tidak akurat:
1. Tambah lebih banyak data historis
2. Sesuaikan faktor di masing-masing pohon
3. Sesuaikan rata-rata waktu pelayanan

### Debug Mode:
Untuk melihat detail prediksi, lihat halaman Detail Antrian di admin panel yang menampilkan hasil setiap pohon.
