import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmlink/controllers/LoginController.dart';
import 'package:farmlink/models/ChatMessage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:farmlink/services/NotificationService.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LoginController loginController = Get.find<LoginController>();
  final NotificationService notificationService = Get.find<NotificationService>();

  var chatRooms = <ChatRoom>[].obs;
  var currentMessages = <ChatMessage>[].obs;
  var isLoading = false.obs;
  StreamSubscription? _chatRoomsSubscription;
  StreamSubscription? _messagesSubscription;

  @override
  void onInit() {
    super.onInit();
    setupChatRoomsListener();
    refreshChatRooms();
  }

  void setupChatRoomsListener() {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    // Cancel existing subscription if any
    _chatRoomsSubscription?.cancel();

    // Setup new real-time listener
    _chatRoomsSubscription = _firestore
        .collection('chatRooms')
        .where('participants', arrayContains: currentUser.uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            chatRooms.value = snapshot.docs
                .map((doc) => ChatRoom.fromJson(doc.data()))
                .toList();
            notificationService.updateUnreadChatCount();
          },
          onError: (error) {
            print('Error in chat rooms listener: $error');
          },
        );
  }

  Future<void> refreshChatRooms() async {
    try {
      isLoading.value = true;
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      String? role = await loginController.getUserRole();
      if (role == null) return;

      Query query = _firestore.collection('chatRooms');
      
      if (role == 'Seller') {
        query = query
            .where('sellerId', isEqualTo: currentUser.uid)
            .orderBy('lastMessageTime', descending: true);
      } else {
        query = query
            .where('customerId', isEqualTo: currentUser.uid)
            .orderBy('lastMessageTime', descending: true);
      }

      QuerySnapshot snapshot = await query.get();
      chatRooms.value = snapshot.docs
          .map((doc) => ChatRoom.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Update notification counts
      await notificationService.updateUnreadChatCount();
    } catch (e) {
      print('Error refreshing chat rooms: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMessages(String chatRoomId) async {
    try {
      isLoading.value = true;

      // Cancel existing message subscription if any
      _messagesSubscription?.cancel();

      // Set up real-time listener for messages
      _messagesSubscription = _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen(
            (snapshot) {
              currentMessages.value = snapshot.docs
                  .map((doc) => ChatMessage.fromJson(doc.data()))
                  .toList();
            },
            onError: (error) {
              print('Error in messages listener: $error');
            },
          );

      // Mark messages as read
      await markMessagesAsRead(chatRoomId);

      // Mark chat room notifications as read
      await _markChatRoomAsRead(chatRoomId);
    } catch (e) {
      print('Error loading messages: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _markChatRoomAsRead(String chatRoomId) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      WriteBatch batch = _firestore.batch();

      // Update chat room's unread status
      DocumentReference chatRoomRef = _firestore.collection('chatRooms').doc(chatRoomId);
      batch.update(chatRoomRef, {
        'hasUnreadMessages': false,
        'receiverId': '',
      });

      // Update notifications in Firestore
      QuerySnapshot notificationsDocs = await _firestore
          .collection('notifications')
          .where('type', isEqualTo: 'chat')
          .where('chatRoomId', isEqualTo: chatRoomId)
          .where('userId', isEqualTo: currentUser.uid)
          .where('read', isEqualTo: false)
          .get();

      for (var doc in notificationsDocs.docs) {
        batch.update(doc.reference, {'read': true});
      }

      await batch.commit();

      // Update local notification count
      await notificationService.updateUnreadChatCount();
    } catch (e) {
      print('Error marking chat room as read: $e');
    }
  }

  Future<void> sendMessage(String chatRoomId, String message,
      {String? productId, String? productName}) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Get the chat room details
      DocumentSnapshot chatRoomDoc =
          await _firestore.collection('chatRooms').doc(chatRoomId).get();

      if (!chatRoomDoc.exists) {
        throw Exception('Chat room not found');
      }

      Map<String, dynamic> chatRoomData = chatRoomDoc.data() as Map<String, dynamic>;

      // Determine receiver ID based on current user role
      String receiverId;
      if (currentUser.uid == chatRoomData['customerId']) {
        receiverId = chatRoomData['sellerId'];
      } else {
        receiverId = chatRoomData['customerId'];
      }

      // Start a batch write
      WriteBatch batch = _firestore.batch();

      // Create message reference
      DocumentReference messageRef = _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc();

      // Create new message
      ChatMessage newMessage = ChatMessage(
        messageId: messageRef.id,
        senderId: currentUser.uid,
        senderName: currentUser.displayName ?? 'User',
        receiverId: receiverId,
        message: message,
        timestamp: DateTime.now(),
        type: MessageType.user,
        productId: productId,
        productName: productName,
      );

      // Add message to batch
      batch.set(messageRef, newMessage.toJson());

      // Update chat room's last message
      batch.update(
        _firestore.collection('chatRooms').doc(chatRoomId),
        {
          'lastMessage': message,
          'lastMessageTime': FieldValue.serverTimestamp(),
          'hasUnreadMessages': true,
          'receiverId': receiverId,
          'participants': [currentUser.uid, receiverId],
        },
      );

      // Store notification
      DocumentReference notificationRef =
          _firestore.collection('notifications').doc();
      
      batch.set(notificationRef, {
        'type': 'chat',
        'chatRoomId': chatRoomId,
        'senderId': currentUser.uid,
        'userId': receiverId,  // Using receiverId as userId for notification
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      // Commit the batch
      await batch.commit();

      // Update notification badges
      await notificationService.updateUnreadChatCount();
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  Future<void> createChatRoom(String sellerId, String sellerName,
      {String? productId, String? productName}) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      String? role = await loginController.getUserRole();
      if (role != 'Customer') {
        Get.snackbar('Error', 'Only customers can initiate chat');
        return;
      }

      // Get seller's information
      DocumentSnapshot sellerDoc =
          await _firestore.collection('users').doc(sellerId).get();
      
      if (!sellerDoc.exists) {
        throw Exception('Seller not found');
      }

      Map<String, dynamic> sellerData = sellerDoc.data() as Map<String, dynamic>;
      String actualSellerName = sellerData['username'] ?? 'Seller';

      // Create a unique room ID based on participants and product
      String roomId = '${currentUser.uid}_${sellerId}';
      if (productId != null) {
        roomId += '_$productId';
      }

      // Start a batch write
      WriteBatch batch = _firestore.batch();

      // Check if chat room exists
      DocumentSnapshot roomDoc =
          await _firestore.collection('chatRooms').doc(roomId).get();

      if (!roomDoc.exists) {
        // Create new chat room
        ChatRoom newRoom = ChatRoom(
          roomId: roomId,
          customerId: currentUser.uid,
          customerName: currentUser.displayName ?? 'Customer',
          sellerId: sellerId,
          sellerName: actualSellerName,
          lastMessageTime: DateTime.now(),
          lastMessage: productName != null ? 'Inquiry about: $productName' : 'Chat started',
          productId: productId,
          productName: productName,
          receiverId: sellerId,
        );

        batch.set(
          _firestore.collection('chatRooms').doc(roomId),
          newRoom.toJson(),
        );

        // Create initial system message
        DocumentReference messageRef = _firestore
            .collection('chatRooms')
            .doc(roomId)
            .collection('messages')
            .doc();

        ChatMessage systemMessage = ChatMessage(
          messageId: messageRef.id,
          senderId: 'system',
          senderName: 'System',
          receiverId: sellerId,
          message: productName != null
              ? 'Inquiry about product: $productName'
              : 'Chat started',
          timestamp: DateTime.now(),
          type: MessageType.system,
          productId: productId,
          productName: productName,
        );

        batch.set(messageRef, systemMessage.toJson());

        // Commit the batch
        await batch.commit();
      }

      Get.toNamed('/chat', arguments: roomId);
    } catch (e) {
      print('Error creating chat room: $e');
      Get.snackbar('Error', 'Failed to create chat room');
    }
  }

  Future<void> markMessagesAsRead(String chatRoomId) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      WriteBatch batch = _firestore.batch();

      // Get unread messages for current user
      QuerySnapshot unreadMessages = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .where('receiverId', isEqualTo: currentUser.uid)
          .where('isRead', isEqualTo: false)
          .get();

      // Mark each message as read
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      // Update chat room unread status
      DocumentReference chatRoomRef =
          _firestore.collection('chatRooms').doc(chatRoomId);
      batch.update(chatRoomRef, {
        'hasUnreadMessages': false,
        'receiverId': '',
      });

      // Commit the batch
      await batch.commit();

      // Update local unread count
      await refreshChatRooms();
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  @override
  void onClose() {
    _chatRoomsSubscription?.cancel();
    _messagesSubscription?.cancel();
    currentMessages.clear();
    chatRooms.clear();
    super.onClose();
  }
}