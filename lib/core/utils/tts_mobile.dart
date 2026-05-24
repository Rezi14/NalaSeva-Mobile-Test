// ignore_for_file: avoid_print
import 'package:flutter_tts/flutter_tts.dart';

final FlutterTts _flutterTts = FlutterTts();
bool _isTtsInitialized = false;

Future<void> _ensureTtsInitialized() async {
  if (_isTtsInitialized) return;
  try {
    await _flutterTts.setLanguage("id-ID");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.85);
    await _flutterTts.setVolume(1.0); // Set volume maksimal eksplisit agar pasti bersuara
    _isTtsInitialized = true;
  } catch (e) {
    print("Mobile TTS init error: $e");
  }
}

Future<void> speakText(String text) async {
  await _ensureTtsInitialized();
  try {
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  } catch (e) {
    print("Mobile TTS speak error: $e");
  }
}

Future<void> stopText() async {
  try {
    await _flutterTts.stop();
  } catch (e) {
    print("Mobile TTS stop error: $e");
  }
}
