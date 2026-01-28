import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:prozync/models/chat_model.dart';
import 'api_service.dart';

class ChatService extends ChangeNotifier {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final ApiService _apiService = ApiService();
  List<ChatPreview> _chats = [];
  List<Message> _currentMessages = [];
  bool _isLoading = false;

  List<ChatPreview> get chats => _chats;
  List<Message> get currentMessages => _currentMessages;
  bool get isLoading => _isLoading;

  Future<void> fetchChats() async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      final response = await _apiService.get('/chats/');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _chats = data.map((json) => ChatPreview.fromJson(json)).toList();
      } else {
        // Fallback to mock data if backend isn't ready
        _generateMockChats();
      }
    } catch (e) {
      debugPrint('Error fetching chats: $e');
      _generateMockChats();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMessages(int chatId) async {
    if (chatId <= 0) {
      _generateMockMessages();
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/chats/$chatId/messages/');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _currentMessages = data.map((json) => Message.fromJson(json, 0)).toList();
      } else {
        _generateMockMessages();
      }
    } catch (e) {
      debugPrint('Error fetching messages: $e');
      _generateMockMessages();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(int chatId, String text) async {
    if (chatId > 0) {
      try {
        final response = await _apiService.post('/chats/$chatId/messages/', {'text': text});
        if (response.statusCode == 201) {
          final newMessage = Message.fromJson(jsonDecode(response.body), 0);
          _currentMessages.add(newMessage);
          notifyListeners();
          return true;
        }
      } catch (e) {
        debugPrint('Error sending message: $e');
      }
    }
    
    // Mock success for UI demo
    _currentMessages.add(Message(
      id: DateTime.now().millisecondsSinceEpoch,
      senderId: 0,
      senderName: 'Me',
      text: text,
      createdAt: DateTime.now(),
      isMe: true,
    ));
    notifyListeners();
    return true;
  }

  void _generateMockChats() {
    _chats = List.generate(5, (index) => ChatPreview(
      id: index,
      otherUserName: 'Developer ${index + 1}',
      otherUserImage: 'https://i.pravatar.cc/150?u=dev$index',
      lastMessage: 'Hey, checked out your repo!',
      lastMessageTime: DateTime.now().subtract(Duration(hours: index)),
      unreadCount: index < 2 ? 1 : 0,
    ));
  }

  void _generateMockMessages() {
    _currentMessages = [
      Message(id: 1, senderId: 1, senderName: 'Other', text: 'Hey there!', createdAt: DateTime.now().subtract(const Duration(hours: 1)), isMe: false),
      Message(id: 2, senderId: 0, senderName: 'Me', text: 'Hello! How are you?', createdAt: DateTime.now().subtract(const Duration(minutes: 45)), isMe: true),
      Message(id: 3, senderId: 1, senderName: 'Other', text: 'I saw your latest Flutter project. Looks great!', createdAt: DateTime.now().subtract(const Duration(minutes: 30)), isMe: false),
    ];
  }
}
