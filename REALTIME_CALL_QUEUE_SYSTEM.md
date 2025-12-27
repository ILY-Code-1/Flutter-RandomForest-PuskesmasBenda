# Real-Time Call Queue System

## Overview
Sistem panggilan antrian real-time yang menghubungkan admin panel dengan display TV menggunakan Firebase Firestore.

## Arsitektur Sistem

### 1. Admin Side (Memanggil Antrian)
**Route:** `/admin/antrian` (AntrianPage)
**Controller:** `AntrianController`

#### Cara Kerja:
1. Admin memilih poli yang ingin dikelola
2. Daftar antrian tampil dalam tabel
3. Admin klik button **Call** (icon campaign) pada antrian dengan status "Menunggu"
4. Method `callAntrian(QueueModel queue)` dipanggil
5. Data antrian di-broadcast ke Firebase collection `call_queue` document `current`

```dart
// Di AntrianController
Future<void> callAntrian(QueueModel queue) async {
  await QueueService.broadcastCallQueue(queue);
  // Menampilkan snackbar sukses
}
```

### 2. Firebase Bridge (QueueService)
**File:** `lib/services/queue_service.dart`

#### Broadcast Function:
```dart
static Future<void> broadcastCallQueue(QueueModel queue) async {
  await _callRef.doc('current').set({
    'id': queue.id,
    'nomorAntrian': queue.nomorAntrian,
    'namaPasien': queue.namaPasien,
    'poli': queue.poli,
    'kodePoli': queue.kodePoli,
    'calledAt': FieldValue.serverTimestamp(),
    'isActive': true,  // Flag untuk menunjukkan ada panggilan aktif
  });
  
  // Auto-deactivate setelah 6 detik
  Future.delayed(const Duration(seconds: 6), () async {
    await _callRef.doc('current').update({'isActive': false});
  });
}
```

#### Stream Function (untuk Display):
```dart
static Stream<Map<String, dynamic>?> streamCalledQueue() {
  return _callRef.doc('current').snapshots().map((snapshot) {
    if (!snapshot.exists) return null;
    final data = snapshot.data();
    if (data == null || data['isActive'] != true) return null;
    return data;
  });
}
```

### 3. Display Side (TV/Browser Lain)
**Route:** `/call/nomor-antrian` (DisplayAntrianPage)
**Controller:** `DisplayAntrianController`

#### Cara Kerja:
1. Halaman ini dibuka di browser terpisah (TV atau monitor)
2. Controller mendengarkan stream dari Firebase secara real-time
3. Ketika ada panggilan baru (isActive = true), dialog muncul otomatis
4. Dialog menampilkan nomor antrian, nama pasien, dan poli
5. Sound notification dimainkan
6. Dialog hilang otomatis setelah 5 detik

```dart
// Di DisplayAntrianController
void _listenToCallQueue() {
  _callSubscription = QueueService.streamCalledQueue().listen(
    (data) {
      if (data != null && data['isActive'] == true) {
        // Set data untuk ditampilkan di dialog
        calledQueueData.value = data;
        showCallDialog.value = true;
        
        // Play sound
        _playNotificationSound();
        
        // Auto hide setelah 5 detik
        Future.delayed(const Duration(seconds: 5), () {
          showCallDialog.value = false;
          calledQueueData.value = null;
        });
      }
    },
  );
}
```

#### Dialog Display:
```dart
// Di DisplayAntrianPage
Obx(() {
  if (controller.showCallDialog.value && 
      controller.calledQueueData.value != null) {
    final data = controller.calledQueueData.value!;
    return CalledQueueDialogFromMap(data: data);
  }
  return const SizedBox.shrink();
}),
```

## Firebase Structure

### Collection: `call_queue`
Document ID: `current` (single document untuk current call)

```json
{
  "id": "doc_id_antrian",
  "nomorAntrian": "PU-01",
  "namaPasien": "John Doe",
  "poli": "Poli Umum",
  "kodePoli": "PU",
  "calledAt": Timestamp,
  "isActive": true
}
```

## Flow Diagram

```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────────┐
│   ADMIN SIDE    │         │     FIREBASE     │         │  DISPLAY SIDE   │
│  /admin/antrian │         │  call_queue/     │         │ /call/nomor-    │
│                 │         │    current       │         │    antrian      │
└────────┬────────┘         └────────┬─────────┘         └────────┬────────┘
         │                           │                            │
         │ 1. Click Call Button      │                            │
         ├──────────────────────────>│                            │
         │                           │                            │
         │ 2. Set isActive=true      │                            │
         │    + queue data           │                            │
         │                           │  3. Real-time stream       │
         │                           ├───────────────────────────>│
         │                           │     detects change         │
         │                           │                            │
         │                           │                      4. Show Dialog
         │                           │                      5. Play Sound
         │                           │                            │
         │                           │ 6. After 6s: isActive=false│
         │                           │<───────────────────────────┤
         │                           │                            │
         │                           │                      7. Hide Dialog
         │                           │                         (after 5s)
         └───────────────────────────┴────────────────────────────┘
```

## Key Features

### 1. Real-Time Synchronization
- Menggunakan Firestore snapshots() untuk real-time updates
- Tidak perlu polling atau refresh manual
- Instant notification ketika button Call diklik

### 2. Multi-Browser Support
- Admin panel bisa dibuka di satu browser
- Display page bisa dibuka di browser/device berbeda
- Keduanya terkoneksi melalui Firebase

### 3. Auto-Cleanup
- Dialog hilang otomatis setelah 5 detik (display side)
- Flag isActive di-reset setelah 6 detik (Firebase side)
- Mencegah dialog muncul berulang kali

### 4. Audio Notification
- Sound notification saat antrian dipanggil
- Fallback ke system sound jika URL sound gagal

## Setup Requirements

### 1. Firebase Configuration
Pastikan Firebase sudah dikonfigurasi di `main.dart`:
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### 2. Firebase Rules
Tambahkan rule untuk collection `call_queue`:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /call_queue/{document=**} {
      allow read, write: if true;
      // Atau sesuaikan dengan kebutuhan security
    }
  }
}
```

### 3. Dependencies
Pastikan sudah ada di `pubspec.yaml`:
```yaml
dependencies:
  get: ^4.6.6
  firebase_core: ^3.15.2
  cloud_firestore: ^5.6.12
  audioplayers: ^6.1.0
```

## Testing

### Test Scenario 1: Basic Call
1. Buka admin panel di browser 1: `http://localhost/#/admin/antrian`
2. Buka display page di browser 2: `http://localhost/#/call/nomor-antrian`
3. Di admin panel, pilih poli
4. Klik button Call pada antrian
5. **Expected:** Dialog muncul di browser 2 dengan nomor antrian dan nama pasien

### Test Scenario 2: Multiple Calls
1. Setup sama seperti scenario 1
2. Klik Call pada antrian pertama
3. Tunggu 5 detik hingga dialog hilang
4. Klik Call pada antrian kedua
5. **Expected:** Dialog baru muncul dengan data antrian kedua

### Test Scenario 3: Sound Notification
1. Setup sama seperti scenario 1
2. Pastikan volume device display tidak mute
3. Klik Call pada antrian
4. **Expected:** Sound notification terdengar saat dialog muncul

## Troubleshooting

### Dialog tidak muncul di display
- Cek koneksi internet
- Cek Firebase console apakah document `call_queue/current` ter-update
- Cek console browser untuk error
- Pastikan `isActive` bernilai `true`

### Sound tidak keluar
- Cek permission browser untuk audio
- Cek volume device
- Cek console untuk error audio playback
- System fallback sound akan dipanggil jika URL sound gagal

### Dialog tidak hilang otomatis
- Cek timer di DisplayAntrianController
- Refresh halaman display

## File Structure

```
lib/
├── modules/
│   ├── admin/
│   │   └── antrian/
│   │       ├── controllers/
│   │       │   └── antrian_controller.dart  # Admin call logic
│   │       └── views/
│   │           └── antrian_page.dart         # Admin UI dengan button Call
│   └── display_antrian/
│       ├── controllers/
│       │   └── display_antrian_controller.dart  # Stream listener
│       ├── views/
│       │   └── display_antrian_page.dart        # Display TV UI
│       ├── widgets/
│       │   ├── called_queue_dialog.dart         # Dialog popup
│       │   ├── antrian_card_widget.dart         # Queue card display
│       │   └── header_display_widget.dart       # Header dengan clock
│       └── bindings/
│           └── display_antrian_binding.dart     # Dependency injection
├── services/
│   └── queue_service.dart                       # Firebase operations
└── models/
    └── queue_model.dart                         # Data model
```

## Dialog Features

### Responsive Design ✅
Dialog sekarang sudah **fully responsive** dan tidak akan overflow:

1. **LayoutBuilder** - Mengkalkulasi ukuran berdasarkan layar
2. **Proportional Sizing** - Semua elemen (font, padding, spacing) proporsional dengan ukuran layar
3. **FittedBox** - Text otomatis scale down jika terlalu panjang
4. **SingleChildScrollView** - Fallback untuk layar sangat kecil
5. **Constraints** - Container nomor antrian dibatasi maksimal 80% lebar layar

### Animations ✅
1. **Fade In + Scale** - Dialog muncul dengan animasi smooth (500ms)
2. **Pulsing Icon** - Icon campaign beranimasi pulse untuk menarik perhatian
3. **Ease Out Curve** - Animasi menggunakan curve yang natural

### Responsive Formula
```dart
iconSize = (screenHeight * 0.08).clamp(60.0, 100.0)
headerFont = (screenHeight * 0.028).clamp(18.0, 28.0)
poliFont = (screenHeight * 0.038).clamp(24.0, 36.0)
queueNumberFont = (screenHeight * 0.12).clamp(60.0, 120.0)
nameFont = (screenHeight * 0.032).clamp(20.0, 32.0)
```

Ini memastikan dialog tetap proporsional di berbagai ukuran layar (mobile, tablet, desktop, TV).

## Future Enhancements

1. **Queue History:** Simpan history panggilan untuk analytics
2. **Multiple Calls:** Support multiple calls aktif bersamaan
3. **Priority Queue:** Support untuk antrian prioritas
4. **Custom Sounds:** Different sound untuk different poli
5. **Voice Announcement:** TTS untuk membacakan nomor antrian
6. **Dark Mode Support:** Tema gelap untuk display malam
