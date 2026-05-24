import 'tts_stub.dart'
    if (dart.library.html) 'tts_web.dart'
    if (dart.library.io) 'tts_mobile.dart';

abstract class TtsHelper {
  static Future<void> speak(String text) async {
    await speakText(text);
  }

  static Future<void> stop() async {
    await stopText();
  }
}
