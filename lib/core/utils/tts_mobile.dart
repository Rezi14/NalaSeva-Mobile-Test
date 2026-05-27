// ignore_for_file: avoid_print
import 'package:flutter_tts/flutter_tts.dart';
import 'app_logger.dart';

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
  } catch (e, stackTrace) {
    AppLogger.error(
      'Mobile TTS init error',
      error: e,
      stackTrace: stackTrace,
      tag: 'TTS',
    );
  }
}

Future<void> speakText(String text) async {
  if (text.trim().isEmpty) {
    AppLogger.warning('Mobile TTS speak dibatalkan karena teks kosong', tag: 'TTS');
    return;
  }
  await _ensureTtsInitialized();
  try {
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  } catch (e, stackTrace) {
    AppLogger.error(
      'Mobile TTS speak error',
      error: e,
      stackTrace: stackTrace,
      tag: 'TTS',
    );
  }
}

Future<void> stopText() async {
  try {
    await _flutterTts.stop();
  } catch (e, stackTrace) {
    AppLogger.error(
      'Mobile TTS stop error',
      error: e,
      stackTrace: stackTrace,
      tag: 'TTS',
    );
  }
}
