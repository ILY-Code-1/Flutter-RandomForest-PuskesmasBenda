/// Controller untuk Display Antrian TV
/// Menampilkan daftar antrian realtime dengan panggilan
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_randomforest_puskesmas_benda/modules/display_antrian/controllers/ttsTestController.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../models/queue_model.dart';
import '../../../services/queue_service.dart';
import '../../../core/constants/poli_constants.dart';

class DisplayAntrianController extends GetxController {
  // ===================== DATA =====================
  final antrianPoliUmum = <QueueModel>[].obs;
  final antrianPoliLansia = <QueueModel>[].obs;
  final antrianPoliAnak = <QueueModel>[].obs;
  final antrianPoliKia = <QueueModel>[].obs;
  final antrianPoliGigi = <QueueModel>[].obs;

  final currentTime = ''.obs;
  final currentDate = ''.obs;

  final calledQueueData = Rxn<Map<String, dynamic>>();
  final showCallDialog = false.obs;

  // ===================== AUDIO =====================
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();

  final _hasPlayedAnnouncement = <String, bool>{}.obs;

  Timer? _clockTimer;
  StreamSubscription? _antrianSubscription;
  StreamSubscription? _callSubscription;

  bool _ttsReady = false;

  // ===================== INIT =====================
  @override
  void onInit() {
    super.onInit();
    _initTtsLikeTestController(); // 🔥 PENTING
    _startClock();
    _listenToAntrian();
    _listenToCallQueue();
  }

  @override
  void onClose() {
    _clockTimer?.cancel();
    _antrianSubscription?.cancel();
    _callSubscription?.cancel();
    _audioPlayer.dispose();
    _flutterTts.stop();
    super.onClose();
  }

  // ===================== CLOCK =====================
  void _startClock() {
    _updateTime();
    _clockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateTime(),
    );
  }

  void _updateTime() {
    final now = DateTime.now();
    currentTime.value = DateFormat('HH:mm:ss').format(now);
    currentDate.value = DateFormat('EEEE, dd MMM yyyy', 'id').format(now);
  }

  // ===================== TTS (COPY DARI TEST CONTROLLER) =====================
  Future<void> _initTtsLikeTestController() async {
    if (_ttsReady) return;

    await _flutterTts.setLanguage("id-ID");
    await _setIndonesianFemaleVoice(); // 🔥 SAMA PERSIS
    await _flutterTts.speak(" "); // 🔥 pancingan browser

    _ttsReady = true;
  }

  Future<void> _setIndonesianFemaleVoice() async {
    List<dynamic>? voices = await _flutterTts.getVoices;

    if (voices == null) return;

    try {
      var indoVoice = voices.firstWhere(
        (voice) {
          final locale = voice['locale'].toString().toLowerCase();
          final name = voice['name'].toString().toLowerCase();

          return locale.contains('id') &&
              (
                name.contains('network') || // biasanya voice cewek natural
                name.contains('standard') ||
                name.contains('id-')
              );
        },
        orElse: () => null,
      );

      if (indoVoice != null) {
        await _flutterTts.setVoice({
          "name": indoVoice['name'],
          "locale": indoVoice['locale'],
        });
        print("✅ Suara wanita Indonesia: ${indoVoice['name']}");
      } else {
        await _flutterTts.setLanguage("id-ID");
        print("⚠️ Voice cewek ID tidak ditemukan, fallback");
      }
    } catch (_) {
      await _flutterTts.setLanguage("id-ID");
    }
  }

  // ===================== STREAM =====================
  void _listenToAntrian() {
    _antrianSubscription = QueueService.streamAntrianMenungguHariIni().listen((
      list,
    ) {
      antrianPoliUmum.value = list.where((q) => q.kodePoli == 'PU').toList();
      antrianPoliLansia.value = list.where((q) => q.kodePoli == 'PL').toList();
      antrianPoliAnak.value = list.where((q) => q.kodePoli == 'PA').toList();
      antrianPoliKia.value = list.where((q) => q.kodePoli == 'PK').toList();
      antrianPoliGigi.value = list.where((q) => q.kodePoli == 'PG').toList();
    });
  }

  void _listenToCallQueue() {
    _callSubscription = QueueService.streamCalledQueue().listen((data) async {
      if (data == null || data['isActive'] != true) return;

      final nomor = data['nomorAntrian'] as String;
      final poli = data['kodePoli'] as String;

      if (_hasPlayedAnnouncement[nomor] == true) return;

      calledQueueData.value = data;
      showCallDialog.value = true;

      // 🔔 BELL 5 DETIK
      await _playBellSound();
      await Future.delayed(const Duration(milliseconds: 5300));

      // 🔊 WANITA INDONESIA
      await _playQueueAnnouncement(nomor, poli);
      await Future.delayed(const Duration(milliseconds: 7000));

      // await Future.delayed(const Duration(milliseconds: 5500));
      _hasPlayedAnnouncement[nomor] = false;
      showCallDialog.value = false;
      calledQueueData.value = null;
    });
  }

  // ===================== AUDIO =====================
  Future<void> _playBellSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.setSource(AssetSource('audio/bell.mp3'));
      await _audioPlayer.resume();
    } catch (_) {
      await SystemSound.play(SystemSoundType.alert);
    }
  }

  Future<void> _playQueueAnnouncement(
    String nomorAntrian,
    String kodePoli,
  ) async {
    if (_hasPlayedAnnouncement[nomorAntrian] == true) return;
    _hasPlayedAnnouncement[nomorAntrian] = true;

    final poliName = _getPoliName(kodePoli);

    // 🔥 SPLIT BIAR BACA BENAR
    final formatted = formatNomorAntrian(nomorAntrian);

    final announcement =
        'Nomor antrian $formatted, silakan menuju ke $poliName';
    
    final controller = Get.put(TtsTestController());
    await controller.playTestSound(announcement);

    // await _flutterTts.speak(announcement);
  }

  // ===================== UTIL =====================
  String _getPoliName(String kodePoli) {
    switch (kodePoli) {
      case 'PK':
        return 'Poli KIA';
      case 'PU':
        return 'Poli Umum';
      case 'PL':
        return 'Poli Lansia';
      case 'PA':
        return 'Poli Anak';
      case 'PG':
        return 'Poli Gigi';
      default:
        return 'Poli';
    }
  }

  List<Map<String, dynamic>> get poliList => PoliConstants.poliList;

  List<QueueModel> getAntrianByPoli(String kodePoli) {
    switch (kodePoli) {
      case 'PU':
        return antrianPoliUmum;
      case 'PL':
        return antrianPoliLansia;
      case 'PA':
        return antrianPoliAnak;
      case 'PK':
        return antrianPoliKia;
      case 'PG':
        return antrianPoliGigi;
      default:
        return [];
    }
  }

  String formatNomorAntrian(String nomorAntrian) {
    final parts = nomorAntrian.split('-');
    if (parts.length != 2) {
      return nomorAntrian.split('').join(' ');
    }
    final prefix = parts[0];
    final numberPart = parts[1];
    final spelledPrefix = prefix.split('').join(' ');
    String spelledNumber;
    if (numberPart.startsWith('0')) {
      // Kalau ada 0 depan → eja semua digit
      spelledNumber = numberPart.split('').join(' ');
    } else {
      // Berapa pun digitnya → baca sebagai angka utuh
      spelledNumber = int.tryParse(numberPart)?.toString() ?? numberPart;
    }
    return '$spelledPrefix - $spelledNumber';
  }
}
