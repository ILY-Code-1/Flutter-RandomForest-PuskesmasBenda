/// Controller untuk Display Antrian TV
/// Menampilkan daftar antrian realtime dengan panggilan
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../models/queue_model.dart';
import '../../../services/queue_service.dart';
import '../../../core/constants/poli_constants.dart';

class DisplayAntrianController extends GetxController {
  final antrianPoliUmum = <QueueModel>[].obs;
  final antrianPoliLansia = <QueueModel>[].obs;
  final antrianPoliAnak = <QueueModel>[].obs;
  final antrianPoliKia = <QueueModel>[].obs;
  final antrianPoliGigi = <QueueModel>[].obs;

  final currentTime = ''.obs;
  final currentDate = ''.obs;

  final calledQueueData = Rxn<Map<String, dynamic>>();
  final showCallDialog = false.obs;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();

  final _hasPlayedAnnouncement = <String, bool>{}.obs;

  Timer? _clockTimer;
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

  void _listenToAntrian() {
    _antrianSubscription =
        QueueService.streamAntrianMenungguHariIni().listen((antrianList) {
      antrianPoliUmum.value =
          antrianList.where((q) => q.kodePoli == 'PU').toList();
      antrianPoliLansia.value =
          antrianList.where((q) => q.kodePoli == 'PL').toList();
      antrianPoliAnak.value =
          antrianList.where((q) => q.kodePoli == 'PA').toList();
      antrianPoliKia.value =
          antrianList.where((q) => q.kodePoli == 'PK').toList();
      antrianPoliGigi.value =
          antrianList.where((q) => q.kodePoli == 'PG').toList();
    });
  }

  void _listenToCallQueue() {
    _callSubscription =
        QueueService.streamCalledQueue().listen((data) async {
      if (data != null && data['isActive'] == true) {
        final nomorAntrian = data['nomorAntrian'] as String;
        final kodePoli = data['kodePoli'] as String;

        if (_hasPlayedAnnouncement[nomorAntrian] == true) return;

        calledQueueData.value = data;
        showCallDialog.value = true;

        await _playBellSound();
        await Future.delayed(const Duration(seconds: 5));
        await _playQueueAnnouncement(nomorAntrian, kodePoli);
        await Future.delayed(const Duration(seconds: 1));

        _hasPlayedAnnouncement[nomorAntrian] = false;

        showCallDialog.value = false;
        calledQueueData.value = null;
      }
    });
  }

  Future<void> _playBellSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.setSource(AssetSource('audio/bell.mp3'));
      await _audioPlayer.resume();
    } catch (_) {
      await SystemSound.play(SystemSoundType.alert);
    }
  }

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
}
