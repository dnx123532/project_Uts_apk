import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/firestore_service.dart';
import '../services/gemini_service.dart';

class ChatProvider extends ChangeNotifier {
  final GeminiService _gemini = GeminiService();
  final FirestoreService _firestore = FirestoreService();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _uid;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  static const _welcome =
      'Halo! Aku Tixi, asisten AI Tixio 🎬\n'
      'Mau rekomendasi film, info jadwal, atau bantuan booking? Tanya aja ya!';

  ChatProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        _uid = null;
        _resetLocal();
      } else if (user.uid != _uid) {
        _uid = user.uid;
        _loadHistory();
      }
    });
  }

  void _resetLocal() {
    _messages = [];
    _gemini.resetConversation();
    _addBotMessage(_welcome);
    notifyListeners();
  }

  void _addBotMessage(String content) {
    _messages.add(ChatMessage(
      content: content,
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> _loadHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      final history = await _firestore.getChatHistory(_uid!);
      _gemini.resetConversation();
      if (history.isEmpty) {
        _messages = [];
        _addBotMessage(_welcome);
      } else {
        _messages = List.of(history);
        _gemini.loadHistory(history); // restore konteks ke Groq
      }
    } catch (_) {
      _messages = [];
      _addBotMessage(_welcome);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isLoading) return;

    _messages.add(ChatMessage(
      content: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    _isLoading = true;
    notifyListeners();

    final reply = await _gemini.sendMessage(trimmed);

    _isLoading = false;
    _addBotMessage(reply);
    notifyListeners();

    // Simpan ke Firestore jika user sudah login
    if (_uid != null) {
      _firestore.saveChatHistory(_uid!, _messages).catchError((_) {});
    }
  }

  Future<void> resetChat() async {
    _gemini.resetConversation();
    _messages = [];
    _addBotMessage('Chat direset! Halo lagi 👋 Ada yang bisa aku bantu?');
    notifyListeners();

    // Hapus history di Firestore juga
    if (_uid != null) {
      _firestore.clearChatHistory(_uid!).catchError((_) {});
    }
  }
}
