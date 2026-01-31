/// Controller untuk Display Antrian TV
/// Menampilkan daftar antrian realtime dengan panggilan
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../models/queue_model.dart';
import '../../../services/queue_service.dart';
import '../../../core/constants/poli_constants.dart';

class DisplayAntrianController extends GetxController {
  // Data antrian per poli
  final antrianPoliUmum = <QueueModel>[].obs;
  final antrianPoliLansia = <QueueModel>[].obs;
  final antrianPoliAnak = <QueueModel>[].obs;
  final antrianPoliKia = <QueueModel>[].obs;
  final antrianPoliGigi = <QueueModel>[].obs;

  // Realtime clock
  final currentTime = ''.obs;
  final currentDate = ''.obs;

  // Called queue untuk dialog (dari Firebase realtime)
  final calledQueueData = Rxn<Map<String, dynamic>>();
  final showCallDialog = false.obs;

  // Audio player untuk notification sound
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Text-to-Speech untuk pengumuman antrian
  final FlutterTts _flutterTts = FlutterTts();

  // Flag untuk tracking apakah suara sudah diputar
  final _hasPlayedAnnouncement = <String, bool>{}.obs;

  // Timer untuk clock
  Timer? _clockTimer;

  // Stream subscriptions
  StreamSubscription? _antrianSubscription;
  StreamSubscription? _callSubscription;

  bool _ttsReady = false;

  @override
  void onInit() {
    super.onInit();
    _initTts();
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

  /// Start realtime clock
  void _startClock() {
    _updateTime();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    currentTime.value = DateFormat('HH:mm:ss').format(now);
    currentDate.value = DateFormat('EEEE, dd MMM yyyy', 'id').format(now);
  }

  Future<void> _ensureTtsReady() async {
    if (_ttsReady) return;
    await _initTts();
    _ttsReady = true;
  }

  /// Initialize Text-to-Speech
  Future<void> _initTts() async {
    await _flutterTts.setLanguage('id-ID');
    await _flutterTts.setSpeechRate(0.65);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.1);
    await _flutterTts.awaitSpeakCompletion(true);

    final voices = await _flutterTts.getVoices;
    for (final voice in voices) {
      if (voice.locale.contains('id') &&
          voice.name.toLowerCase().contains('female')) {
        await _flutterTts.setVoice(voice);
        break;
      }
    }
  }

  /// Mapping kode poli ke nama poli
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

  /// Listen to antrian stream
  void _listenToAntrian() {
    _antrianSubscription = QueueService.streamAntrianMenungguHariIni().listen(
      (antrianList) {
        // Filter per poli
        antrianPoliUmum.value = antrianList
            .where((q) => q.kodePoli == 'PU')
            .toList();
        antrianPoliLansia.value = antrianList
            .where((q) => q.kodePoli == 'PL')
            .toList();
        antrianPoliAnak.value = antrianList
            .where((q) => q.kodePoli == 'PA')
            .toList();
        antrianPoliKia.value = antrianList
            .where((q) => q.kodePoli == 'PK')
            .toList();
        antrianPoliGigi.value = antrianList
            .where((q) => q.kodePoli == 'PG')
            .toList();
      },
      onError: (e) {
        debugPrint('Error listening to antrian: $e');
      },
    );
  }

  /// Listen to call queue dari Firebase (realtime dari admin)
  void _listenToCallQueue() {
    _callSubscription =
        QueueService.streamCalledQueue().listen((data) async {
      if (data != null && data['isActive'] == true) {
        final nomorAntrian = data['nomorAntrian'] as String;
        final kodePoli = data['kodePoli'] as String;

        // Cegah double trigger
        if (_hasPlayedAnnouncement[nomorAntrian] == true) return;

        calledQueueData.value = data;
        showCallDialog.value = true;

        // 🔔 Bell dulu
        await _playBellSound();

        // ⏳ Tunggu bell ±5 detik
        await Future.delayed(const Duration(seconds: 5));

        // 🗣️ TTS
        await _playQueueAnnouncement(nomorAntrian, kodePoli);

        // ⏳ Tunggu TTS selesai (sudah di-handle awaitSpeakCompletion)
        await Future.delayed(const Duration(seconds: 1));

        // 🔁 Reset flag untuk panggilan berikutnya
        _hasPlayedAnnouncement[nomorAntrian] = false;

        // 👻 Auto hide
        showCallDialog.value = false;
        calledQueueData.value = null;
      }
    });
  }

  /// Play bell sound untuk panggilan antrian
  Future<void> _playBellSound() async {
    try {
      await _audioPlayer.play(
        AssetSource('audio/bell.mp3'),
        volume: 1.0,
      );
    } catch (_) {
      await SystemSound.play(SystemSoundType.alert);
    }
  }

  /// Play pengumuman antrian menggunakan TTS
  Future<void> _playQueueAnnouncement(
      String nomorAntrian, String kodePoli) async {
    if (_hasPlayedAnnouncement[nomorAntrian] == true) return;

    _hasPlayedAnnouncement[nomorAntrian] = true;

    final poliName = _getPoliName(kodePoli);
    final announcement =
        'Nomor antrian $nomorAntrian menuju ke $poliName';

    await _ensureTtsReady();
    await _flutterTts.speak(announcement);
  }

  /// Get list poli untuk display
  List<Map<String, dynamic>> get poliList => PoliConstants.poliList;

  /// Get antrian by poli code
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
}
