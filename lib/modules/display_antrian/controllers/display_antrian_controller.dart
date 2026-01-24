/// Controller untuk Display Antrian TV
/// Menampilkan daftar antrian realtime dengan panggilan
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Timer untuk clock
  Timer? _clockTimer;

  // Stream subscriptions
  StreamSubscription? _antrianSubscription;
  StreamSubscription? _callSubscription;

  @override
  void onInit() {
    super.onInit();
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
    _callSubscription = QueueService.streamCalledQueue().listen(
      (data) {
        if (data != null && data['isActive'] == true) {
          // Ada panggilan baru
          calledQueueData.value = data;
          showCallDialog.value = true;
          
          // Play bell sound
          _playBellSound();
          
          // Auto hide after 5 seconds
          Future.delayed(const Duration(seconds: 5), () {
            showCallDialog.value = false;
            calledQueueData.value = null;
          });
        }
      },
      onError: (e) {
        debugPrint('Error listening to call queue: $e');
      },
    );
  }

  /// Play bell sound untuk panggilan antrian
  Future<void> _playBellSound() async {
    try {
      await _audioPlayer.play(
        AssetSource('audio/bell.mp3'),
        volume: 1.0,
      );
    } catch (e) {
      debugPrint('Error playing bell sound: $e');
      // Fallback ke system sound jika error
      await SystemSound.play(SystemSoundType.alert);
    }
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
