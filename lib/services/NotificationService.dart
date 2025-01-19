import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> init() async {
    try {
      // Request notification permissions
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
        
        // Get FCM token
        String? token = await _messaging.getToken();
        if (token != null) {
          await _updateFcmToken(token);
        }

        // Listen for token refresh
        _messaging.onTokenRefresh.listen(_updateFcmToken);

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle background messages
        FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

        // Handle message open
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpen);
      }

      _setupChatNotificationListener();
    } catch (e) {
      print('Error initializing notification service: $e');
    }
  }

  Future<void> _updateFcmToken(String token) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .update({'fcmToken': token});
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  void _setupChatNotificationListener() {
    User? user = _auth.currentUser;
    if (user == null) return;

    // Listen for new messages in chat rooms
    _firestore
        .collection('chatRooms')
        .where('receiverId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.modified) {
              Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;
              
              if (data['hasUnreadMessages'] == true) {
                _sendChatNotification(
                  senderName: data['senderName'] ?? 'Someone',
                  message: data['lastMessage'] ?? 'New message',
                  chatRoomId: change.doc.id,
                  productName: data['productName'],
                );
              }
            }
          }
        }, onError: (error) {
          print('Error in chat notification listener: $error');
        });
  }

  Future<void> _sendChatNotification({
    required String senderName,
    required String message,
    required String chatRoomId,
    String? productName,
  }) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // Get user's FCM token
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) return;

      String? fcmToken = (userDoc.data() as Map<String, dynamic>)['fcmToken'];
      if (fcmToken == null) return;

      // Create notification payload
      Map<String, dynamic> notification = {
        'title': productName != null ? 'Message about $productName' : 'New message from $senderName',
        'body': message,
        'clickAction': 'FLUTTER_NOTIFICATION_CLICK',
        'chatRoomId': chatRoomId,
      };

      // Store notification in Firestore for history
      await _firestore.collection('notifications').add({
        'userId': currentUser.uid,
        'title': notification['title'],
        'body': notification['body'],
        'chatRoomId': chatRoomId,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      // Show local notification if app is in foreground
      _showLocalNotification(notification);
    } catch (e) {
      print('Error sending chat notification: $e');
    }
  }

  void _showLocalNotification(Map<String, dynamic> notification) {
    Get.snackbar(
      notification['title'],
      notification['body'],
      duration: Duration(seconds: 3),
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      onTap: (_) {
        if (notification['chatRoomId'] != null) {
          Get.toNamed('/chat', arguments: notification['chatRoomId']);
        }
      },
    );
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (message.notification != null) {
      _showLocalNotification({
        'title': message.notification!.title ?? 'New Message',
        'body': message.notification!.body ?? '',
        'chatRoomId': message.data['chatRoomId'],
      });
    }
  }

  void _handleMessageOpen(RemoteMessage message) {
    if (message.data['chatRoomId'] != null) {
      Get.toNamed('/chat', arguments: message.data['chatRoomId']);
    }
  }
}

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}