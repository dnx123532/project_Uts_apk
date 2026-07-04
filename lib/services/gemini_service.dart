import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/chat_message.dart';

class GeminiService {
  static const _model = 'llama-3.3-70b-versatile';
  static const _systemPrompt = '''
Kamu adalah Tixi, asisten AI ramah untuk aplikasi bioskop Tixio.
Tugasmu membantu pengguna dengan:
- Rekomendasi film sesuai selera (genre, mood, durasi)
- Info film yang tersedia di Tixio:
    1. Avengers: Endgame (Action, Sci-Fi, 2019, ⭐8.4)
    2. Avengers: Infinity War (Action, Sci-Fi, 2018, ⭐8.4)
    3. Chainsaw Man (Action, Anime, 2022, ⭐8.5)
    4. Jujutsu Kaisen (Action, Anime, 2021, ⭐8.6)
    5. Look Back (Drama, Anime, 2024, ⭐8.7)
    6. Now You See Me (Crime, Thriller, 2013, ⭐7.3)
    7. One For All (Action, Anime, 2024, ⭐8.1)
    8. The Conjuring (Horror, Thriller, 2013, ⭐7.5)
    9. The Dark Knight (Action, Crime, 2008, ⭐9.0)
    10. Toy Story 4 (Animation, Comedy, 2019, ⭐7.7)
- Cara booking tiket: pilih film → pilih bioskop → pilih kursi → bayar
- Info food & beverage: Popcorn (S/M/L), Combo, HotDog, Nachos, berbagai minuman
- FAQ: pembayaran, refund, kursi, studio reguler vs premium
- Tips memilih kursi terbaik di bioskop

Gaya bahasa: santai, ramah, pakai emoji secukupnya.
Jawab dalam bahasa Indonesia. Jika ditanya di luar konteks bioskop/film, tetap jawab sopan lalu arahkan ke topik Tixio.
''';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.groq.com/openai/v1',
    headers: {
      'Authorization': 'Bearer ${ApiConfig.groqApiKey}',
      'Content-Type': 'application/json',
    },
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
  ));

  final List<Map<String, String>> _history = [];

  GeminiService() {
    _history.add({'role': 'system', 'content': _systemPrompt});
  }

  Future<String> sendMessage(String userMessage) async {
    _history.add({'role': 'user', 'content': userMessage});
    try {
      final response = await _dio.post('/chat/completions', data: {
        'model': _model,
        'messages': _history,
        'temperature': 0.8,
        'max_tokens': 512,
      });
      final content =
          response.data['choices'][0]['message']['content'] as String;
      _history.add({'role': 'assistant', 'content': content});
      return content.trim();
    } on DioException catch (e) {
      _history.removeLast();
      final status = e.response?.statusCode;
      if (status == 401) return '⚠️ API key tidak valid. Hubungi admin Tixio.';
      if (status == 429) return '⏳ Terlalu banyak permintaan, tunggu sebentar ya!';
      return 'Waduh, ada gangguan nih. Coba tanya lagi ya! 😅';
    } catch (_) {
      _history.removeLast();
      return 'Koneksi bermasalah, coba beberapa saat lagi. 🙏';
    }
  }

  // Restore percakapan sebelumnya ke konteks Groq (max 20 pesan terakhir)
  void loadHistory(List<ChatMessage> messages) {
    final recent = messages.length > 20
        ? messages.sublist(messages.length - 20)
        : messages;
    for (final msg in recent) {
      _history.add({
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.content,
      });
    }
  }

  void resetConversation() {
    _history
      ..clear()
      ..add({'role': 'system', 'content': _systemPrompt});
  }
}
