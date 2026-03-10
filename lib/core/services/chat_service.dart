import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prozync/models/chat_model.dart';

class ChatService extends ChangeNotifier {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<ChatPreview> _chats = [];
  List<Message> _currentMessages = [];
  bool _isLoading = false;

  List<ChatPreview> get chats => _chats;
  List<Message> get currentMessages => _currentMessages;
  bool get isLoading => _isLoading;

  String _getChatId(String uid1, String uid2) {
    List<String> ids = [uid1, uid2];
    ids.sort();
    return ids.join('_');
  }

  Future<void> fetchChats() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('conversations')
          .orderBy('last_message_time', descending: true)
          .get();

      _chats = snapshot.docs.map((doc) {
        return ChatPreview.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      debugPrint('Error fetching chats: $e');
      notifyListeners();
    }
  }

  Stream<List<Message>> getMessagesStream(String otherUserId) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    final chatId = _getChatId(user.uid, otherUserId);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                return Message.fromJson({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }, user.uid);
              })
              .toList()
              .reversed
              .toList();
        });
  }

  Future<bool> sendMessage(String receiverId, String text) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final chatId = _getChatId(user.uid, receiverId);
    final timestamp = FieldValue.serverTimestamp();

    try {
      // Add message to chat
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
            'sender': user.uid,
            'receiver': receiverId,
            'message': text,
            'timestamp': timestamp,
            'read': false,
          });

      // Update conversation for sender
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('conversations')
          .doc(receiverId)
          .set({
            'other_user_name': 'User', // In real app, fetch name or store it
            'last_message': text,
            'last_message_time': timestamp,
            'unread_count': 0,
          }, SetOptions(merge: true));

      // Update conversation for receiver
      await _firestore
          .collection('users')
          .doc(receiverId)
          .collection('conversations')
          .doc(user.uid)
          .set({
            'other_user_name': user.displayName ?? 'User',
            'last_message': text,
            'last_message_time': timestamp,
            'unread_count': FieldValue.increment(1),
          }, SetOptions(merge: true));

      return true;
    } catch (e) {
      debugPrint('Error sending message: $e');
      return false;
    }
  }

  Future<void> markConversationAsRead(String otherUserId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('conversations')
          .doc(otherUserId)
          .update({'unread_count': 0});

      // Mark messages as read in the chat collection for this user
      final chatId = _getChatId(user.uid, otherUserId);
      final unreadMessages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('receiver', isEqualTo: user.uid)
          .where('read', isEqualTo: false)
          .get();

      for (var doc in unreadMessages.docs) {
        await doc.reference.update({'read': true});
      }
    } catch (e) {
      debugPrint('Error marking conversation as read: $e');
    }
  }

  void clear() {
    _chats = [];
    _currentMessages = [];
    _isLoading = false;
    notifyListeners();
  }
}
