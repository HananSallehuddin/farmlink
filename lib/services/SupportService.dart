import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:farmlink/models/SupportMessage.dart';
import 'package:farmlink/models/SupportChatBot.dart';
import 'package:image_picker/image_picker.dart';

class SupportService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Support chat states
  final RxBool isProcessing = false.obs;
  final RxString currentContext = ''.obs;
  final RxInt messageCount = 0.obs;

  Future<String> createSupportChat(String userId) async {
    try {
      String chatId = 'support_$userId';
      await _firestore.collection('supportChats').doc(chatId).set({
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': 'Chat started',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'status': 'active',
        'context': '',
      });
      return chatId;
    } catch (e) {
      print('Error creating support chat: $e');
      rethrow;
    }
  }

  Stream<List<SupportMessage>> getChatMessages(String chatId) {
    return _firestore
        .collection('supportChats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SupportMessage.fromJson(doc.data()))
            .toList());
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String message,
    SupportMessageType type = SupportMessageType.text,
    Map<String, dynamic>? metadata,
    String? attachmentUrl,
    Map<String, String>? actions,
  }) async {
    try {
      isProcessing.value = true;
      
      final messageRef = _firestore
          .collection('supportChats')
          .doc(chatId)
          .collection('messages')
          .doc();

      final supportMessage = SupportMessage(
        messageId: messageRef.id,
        senderId: senderId,
        senderName: senderName,
        receiverId: 'support_bot',
        message: message,
        timestamp: DateTime.now(),
        type: type,
        metadata: metadata,
        attachmentUrl: attachmentUrl,
        actions: actions,
      );

      await messageRef.set(supportMessage.toJson());

      // Update chat metadata
      await _firestore.collection('supportChats').doc(chatId).update({
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'messageCount': FieldValue.increment(1),
      });

      messageCount.value++;

      // Generate and send bot response
      if (type == SupportMessageType.text) {
        await _handleBotResponse(chatId, message);
      }
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> _handleBotResponse(String chatId, String userMessage) async {
    try {
      // Update context based on user message
      _updateContext(userMessage);

      // Generate bot response
      final botResponse = SupportChatBot.generateResponse(userMessage);
      final quickReplies = SupportChatBot.getQuickReplies(userMessage);

      // Send bot response with delay
      await Future.delayed(Duration(seconds: 1));

      final messageRef = _firestore
          .collection('supportChats')
          .doc(chatId)
          .collection('messages')
          .doc();

      final supportMessage = SupportMessage(
        messageId: messageRef.id,
        senderId: 'support_bot',
        senderName: 'Support Bot',
        receiverId: chatId.replaceAll('support_', ''),
        message: botResponse,
        timestamp: DateTime.now(),
        type: SupportMessageType.text,
        actions: quickReplies,
      );

      await messageRef.set(supportMessage.toJson());

      // Update chat metadata
      await _firestore.collection('supportChats').doc(chatId).update({
        'lastMessage': botResponse,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'messageCount': FieldValue.increment(1),
      });

      messageCount.value++;
    } catch (e) {
      print('Error handling bot response: $e');
    }
  }

  void _updateContext(String message) {
    // Simple context tracking
    if (message.toLowerCase().contains('order')) {
      currentContext.value = 'order';
    } else if (message.toLowerCase().contains('payment')) {
      currentContext.value = 'payment';
    } else if (message.toLowerCase().contains('shipping')) {
      currentContext.value = 'shipping';
    } else if (message.toLowerCase().contains('account')) {
      currentContext.value = 'account';
    }
  }

  Future<String?> uploadAttachment(XFile file) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final Reference ref = _storage.ref().child('support_attachments').child(fileName);

      final UploadTask uploadTask = ref.putFile(File(file.path));
      final TaskSnapshot snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        return await snapshot.ref.getDownloadURL();
      }
      return null;
    } catch (e) {
      print('Error uploading attachment: $e');
      return null;
    }
  }

  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      WriteBatch batch = _firestore.batch();

      QuerySnapshot unreadMessages = await _firestore
          .collection('supportChats')
          .doc(chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  Future<void> endSupportChat(String chatId) async {
    try {
      await _firestore.collection('supportChats').doc(chatId).update({
        'status': 'closed',
        'closedAt': FieldValue.serverTimestamp(),
      });

      // Send closing message
      final messageRef = _firestore
          .collection('supportChats')
          .doc(chatId)
          .collection('messages')
          .doc();

      final closingMessage = SupportMessage(
        messageId: messageRef.id,
        senderId: 'support_bot',
        senderName: 'Support Bot',
        receiverId: chatId.replaceAll('support_', ''),
        message: 'Chat session ended. You can start a new chat anytime from the Support tab!',
        timestamp: DateTime.now(),
        type: SupportMessageType.system,
      );

      await messageRef.set(closingMessage.toJson());
    } catch (e) {
      print('Error ending support chat: $e');
      rethrow;
    }
  }

  Future<void> clearChatHistory(String chatId) async {
    try {
      // Delete all messages
      final messages = await _firestore
          .collection('supportChats')
          .doc(chatId)
          .collection('messages')
          .get();

      WriteBatch batch = _firestore.batch();
      for (var message in messages.docs) {
        batch.delete(message.reference);
      }
      await batch.commit();

      // Reset chat metadata
      await _firestore.collection('supportChats').doc(chatId).update({
        'messageCount': 0,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      messageCount.value = 0;
    } catch (e) {
      print('Error clearing chat history: $e');
      rethrow;
    }
  }

  @override
  void onClose() {
    currentContext.value = '';
    messageCount.value = 0;
    super.onClose();
  }
}