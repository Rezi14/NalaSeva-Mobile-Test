// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use, avoid_print
import 'dart:html' as html;

Future<void> speakText(String text) async {
  try {
    final synth = html.window.speechSynthesis;
    if (synth != null) {
      synth.cancel(); // Batalkan audio sebelumnya agar suara terbaru langsung berbunyi
      final utterance = html.SpeechSynthesisUtterance(text);
      utterance.lang = 'id-ID';
      
      // Scan dan set voice khusus Bahasa Indonesia (id-ID) untuk ucapan yang natural
      final voices = synth.getVoices();
      if (voices.isNotEmpty) {
        try {
          final idVoice = voices.firstWhere(
            (v) => v.lang != null && v.lang!.toLowerCase().replaceAll('_', '-').contains('id'),
          );
          utterance.voice = idVoice;
        } catch (_) {
          // Fallback ke pencarian dengan locale 'id' jika pencarian spesifik gagal
          try {
            final idFallback = voices.firstWhere(
              (v) => v.lang != null && v.lang!.toLowerCase().startsWith('id'),
            );
            utterance.voice = idFallback;
          } catch (_) {
            // Biarkan browser menggunakan voice default jika tidak ditemukan
          }
        }
      }
      
      utterance.rate = 0.85; // Kecepatan ideal untuk ruang tunggu klinik
      utterance.pitch = 1.0;
      synth.speak(utterance);
    }
  } catch (e) {
    print("Web SpeechSynthesis error: $e");
  }
}

Future<void> stopText() async {
  try {
    html.window.speechSynthesis?.cancel();
  } catch (e) {
    print("Web SpeechSynthesis cancel error: $e");
  }
}
