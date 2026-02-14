// import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

// --- CONTROLLER (LOGIC) ---
class TtsTestController extends GetxController {
  final FlutterTts flutterTts = FlutterTts();
  final String textToSpeak =
      "Nomor antrian A, satu, dua, tiga. Silakan menuju ke poli umum.";
  var isEngineReady = false.obs;

  @override
  void onInit() {
    flutterTts.setLanguage("id-ID");
    _setIndonesianFemaleVoice();
    flutterTts.speak(" ");
    super.onInit();
    // Jangan set suara di sini, Web belum siap!
  }

  // Future<void> powerOnEngine() async {
  //   try {
  //     // 1. Set Bahasa dulu

  //     // 2. Berburu suara Cewek Indonesia (Wajib di Web)

  //     // 3. Pancingan browser

  //     isEngineReady.value = true;
  //     Get.snackbar(
  //       "Siap!",
  //       "Suara Cewek Indonesia Terdeteksi",
  //       backgroundColor: Colors.green,
  //       colorText: Colors.white,
  //     );
  //   } catch (e) {
  //     print("Error: $e");
  //   }
  // }

  Future<void> _setIndonesianFemaleVoice() async {
    // Ambil semua suara yang tersedia di browser kamu
    List<dynamic>? voices = await flutterTts.getVoices;

    if (voices != null) {
      try {
        // Cari suara yang ada unsur 'id' dan 'female' atau 'gadis/indonesia'
        var indoVoice = voices.firstWhere(
          (voice) =>
              voice['locale'].toString().contains('id') &&
              (voice['name'].toString().toLowerCase().contains('female') ||
                  voice['name'].toString().toLowerCase().contains('indonesia')),
          orElse: () => null,
        );

        if (indoVoice != null) {
          await flutterTts.setVoice({
            "name": indoVoice['name'],
            "locale": indoVoice['locale'],
          });
          print("✅ Suara ditemukan: ${indoVoice['name']}");
        } else {
          // Fallback: Set language saja kalau suara spesifik gak ketemu
          await flutterTts.setLanguage("id-ID");
          print("⚠️ Suara cewek spesifik gak ketemu, pakai default ID");
        }
      } catch (e) {
        await flutterTts.setLanguage("id-ID");
      }
    }
  }

  Future<void> playTestSound(String textSpech) async {
    // if (!isEngineReady.value) return;

    await flutterTts.setLanguage('id-ID');
    await flutterTts.setSpeechRate(0.9);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.1);

    // Ambil daftar suara
    final List<dynamic>? voices = await flutterTts.getVoices;

    if (voices != null) {
      for (var voice in voices) {
        // PERBAIKAN: Gunakan format Map [ 'key' ] bukan titik
        final String locale = voice['locale']?.toString() ?? '';
        final String name = voice['name']?.toString().toLowerCase() ?? '';

        if (locale.contains('id') && name.contains('female')) {
          // Set voice juga harus menggunakan Map yang sama
          await flutterTts.setVoice({
            "name": voice['name'],
            "locale": voice['locale'],
          });
          print("✅ Berhasil pakai suara: ${voice['name']}");
          break;
        }
      }
    }

    print("📣 Memulai Panggilan...");
    await flutterTts.speak(textSpech);
  }
}
