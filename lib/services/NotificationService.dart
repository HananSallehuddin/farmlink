import 'dart:async';  // Add this import for StreamSubscription
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
  
  if (message.notification != null) {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('notifications').add({
      'title': message.notification!.title,
      'body': message.notification!.body,
      'type': message.data['type'],
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
      'userId': message.data['userId'],
      ...message.data,
    });
  }
}

class NotificationService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Observable counters for badges
  final RxInt unreadChats = 0.obs;
  final RxInt unreadOrders = 0.obs;

  // Stream subscriptions for real-time updates
  StreamSubscription? _chatNotificationsSubscription;
  StreamSubscription? _orderNotificationsSubscription;
  StreamSubscription? _productNotificationsSubscription;

  Future<void> init() async {
    try {
      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request notification permissions
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get FCM token
        String? token = await _messaging.getToken();
        if (token != null) {
          await _updateFcmToken(token);
        }

        // Listen for token refresh
        _messaging.onTokenRefresh.listen(_updateFcmToken);

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle message open
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpen);

        // Set up background message handler
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      }

      // Setup auth state listener
      _auth.authStateChanges().listen((User? user) {
        if (user != null) {
          // Set up notification listeners when user logs in
          _setupNotificationListeners();
          // Initialize counts
          updateUnreadChatCount();
          updateUnreadOrderCount();
        } else {
          // Clear notifications when user logs out
          unreadChats.value = 0;
          unreadOrders.value = 0;
          _chatNotificationsSubscription?.cancel();
          _orderNotificationsSubscription?.cancel();
        }
      });

    } catch (e) {
      print('Error initializing notification service: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
        
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },
    );

    // Create notification channel for Android
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'farmlink_notifications',
            'FarmLink Notifications',
            description: 'Notifications for FarmLink app',
            importance: Importance.high,
          ),
        );
  }

  void _setupNotificationListeners() {
    User? user = _auth.currentUser;
    if (user == null) return;

    // Cancel existing subscriptions
    _chatNotificationsSubscription?.cancel();
    _orderNotificationsSubscription?.cancel();

    // Setup real-time listener for chat notifications
    _chatNotificationsSubscription = _firestore
        .collection('notifications')
        .where('type', isEqualTo: 'chat')
        .where('userId', isEqualTo: user.uid)
        .where('read', isEqualTo: false)
        .snapshots()
        .listen(
      (snapshot) {
        unreadChats.value = snapshot.docs.length;
        print('Unread chats updated: ${unreadChats.value}');
      },
      onError: (error) {
        print('Error in chat notifications listener: $error');
      },
    );

    // Setup real-time listener for order notifications
    _orderNotificationsSubscription = _firestore
        .collection('notifications')
        .where('type', isEqualTo: 'order')
        .where('userId', isEqualTo: user.uid)
        .where('read', isEqualTo: false)
        .snapshots()
        .listen(
      (snapshot) {
        unreadOrders.value = snapshot.docs.length;
        print('Unread orders updated: ${unreadOrders.value}');
      },
      onError: (error) {
        print('Error in order notifications listener: $error');
      },
    );
  }

  // Add method to initialize notifications on app start
  Future<void> initializeNotifications() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    // Get initial unread counts
    await updateUnreadChatCount();
    await updateUnreadOrderCount();

    // Setup real-time listeners
    _setupNotificationListeners();
  }

  void _setupChatNotificationsListener() {
    User? user = _auth.currentUser;
    if (user == null) return;

    // Cancel existing subscription if any
    _chatNotificationsSubscription?.cancel();

    // Setup new real-time listener for chat notifications
    _chatNotificationsSubscription = _firestore
        .collection('notifications')
        .where('type', isEqualTo: 'chat')
        .where('userId', isEqualTo: user.uid)
        .where('read', isEqualTo: false)
        .snapshots()
        .listen(
          (snapshot) {
            unreadChats.value = snapshot.docs.length;
          },
          onError: (error) {
            print('Error in chat notifications listener: $error');
          },
        );
  }

  void _setupOrderNotificationsListener() {
    User? user = _auth.currentUser;
    if (user == null) return;

    // Cancel existing subscription if any
    _orderNotificationsSubscription?.cancel();

    // Setup new real-time listener for order notifications
    _orderNotificationsSubscription = _firestore
        .collection('notifications')
        .where('type', isEqualTo: 'order')
        .where('userId', isEqualTo: user.uid)
        .where('read', isEqualTo: false)
        .snapshots()
        .listen(
          (snapshot) {
            unreadOrders.value = snapshot.docs.length;
          },
          onError: (error) {
            print('Error in order notifications listener: $error');
          },
        );
  }

  void _setupProductNotificationsListener() {
    User? user = _auth.currentUser;
    if (user == null) return;

    // Cancel existing subscription if any
    _productNotificationsSubscription?.cancel();

    // Setup new real-time listener for product notifications
    _productNotificationsSubscription = _firestore
        .collection('localProduce')
        .where('userRef', isEqualTo: _firestore.collection('users').doc(user.uid))
        .snapshots()
        .listen(
          (snapshot) {
            for (var change in snapshot.docChanges) {
              if (change.type == DocumentChangeType.modified) {
                var productData = change.doc.data();
                if (productData != null && productData['stock'] == 0) {
                  _sendProductStockNotification(
                    productId: change.doc.id,
                    productName: productData['productName'],
                    sellerId: user.uid,
                  );
                }
              }
            }
          },
          onError: (error) {
            print('Error in product notifications listener: $error');
          },
        );
  }

  Future<void> _updateFcmToken(String token) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': token
        });
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  Future<void> _sendProductStockNotification({
    required String productId,
    required String productName,
    required String sellerId,
  }) async {
    try {
      String title = 'Product Out of Stock';
      String body = 'Your product "$productName" is now out of stock.';

      // Get the seller's FCM token
      DocumentSnapshot sellerDoc = await _firestore
          .collection('users')
          .doc(sellerId)
          .get();
      String? fcmToken = (sellerDoc.data() as Map<String, dynamic>)['fcmToken'];
      
      if (fcmToken != null) {
        // Store notification in Firestore first
        await _firestore.collection('notifications').add({
          'userId': sellerId,
          'title': title,
          'body': body,
          'type': 'stock',
          'productId': productId,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });

        // Show local notification
        await _showLocalNotification(
          id: productId.hashCode,
          title: title,
          body: body,
          payload: 'product:$productId',
        );
      }

      // Store notification in Firestore
      await _firestore.collection('notifications').add({
        'userId': sellerId,
        'title': title,
        'body': body,
        'productId': productId,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'type': 'stock',
      });

      // Show local notification
      await _showLocalNotification(
        id: productId.hashCode,
        title: title,
        body: body,
        payload: 'product:$productId',
      );
    } catch (e) {
      print('Error sending product stock notification: $e');
    }
  }

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'farmlink_notifications',
      'FarmLink Notifications',
      channelDescription: 'Notifications for FarmLink app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  void _handleForegroundMessage(RemoteMessage message) async {
    if (message.notification != null) {
      // Store notification in Firestore
      await _firestore.collection('notifications').add({
        'title': message.notification!.title,
        'body': message.notification!.body,
        'type': message.data['type'],
        'userId': message.data['userId'],
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        ...message.data,
      });

      // Show local notification
      await _showLocalNotification(
        id: message.messageId.hashCode,
        title: message.notification!.title ?? 'New Notification',
        body: message.notification!.body ?? '',
        payload: _getNotificationPayload(message),
      );

      // Update notification counts
      await _updateNotificationCounts(message.data['type']);
    }
  }

  String _getNotificationPayload(RemoteMessage message) {
    switch (message.data['type']) {
      case 'order_update':
        return 'order:${message.data['orderId']}';
      case 'chat':
        return 'chat:${message.data['chatRoomId']}';
      case 'stock_update':
        return 'product:${message.data['productId']}';
      default:
        return '';
    }
  }

  void _handleMessageOpen(RemoteMessage message) {
    final type = message.data['type'];
    if (type == 'order_update') {
      Get.toNamed('/orders');
      markNotificationsAsRead('order', id: message.data['orderId']);
    } else if (type == 'stock_update') {
      Get.toNamed('/homepageSeller');
      markNotificationsAsRead('stock', id: message.data['productId']);
    } else if (type == 'chat') {
      final chatRoomId = message.data['chatRoomId'];
      if (chatRoomId != null) {
        Get.toNamed('/chat', arguments: chatRoomId);
        markNotificationsAsRead('chat', id: chatRoomId);
      }
    }
  }

  void _handleNotificationTap(String? payload) {
    if (payload != null) {
      final parts = payload.split(':');
      if (parts.length == 2) {
        final type = parts[0];
        final id = parts[1];
        switch (type) {
          case 'order':
            Get.toNamed('/orders');
            markNotificationsAsRead('order', id: id);
            break;
          case 'product':
            Get.toNamed('/homepageSeller');
            markNotificationsAsRead('stock', id: id);
            break;
          case 'chat':
            Get.toNamed('/chat', arguments: id);
            markNotificationsAsRead('chat', id: id);
            break;
        }
      }
    }
  }

  Future<void> _updateNotificationCounts(String? type) async {
    if (type == 'chat') {
      await updateUnreadChatCount();
    } else if (type == 'order') {
      await updateUnreadOrderCount();
    }
  }

  Future<void> updateUnreadChatCount() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      QuerySnapshot unreadChatsSnapshot = await _firestore
          .collection('notifications')
          .where('type', isEqualTo: 'chat')
          .where('userId', isEqualTo: currentUser.uid)
          .where('read', isEqualTo: false)
          .get();

      unreadChats.value = unreadChatsSnapshot.docs.length;
      print('Updated unread chats count: ${unreadChats.value}');
    } catch (e) {
      print('Error updating unread chat count: $e');
    }
  }

  Future<void> updateUnreadOrderCount() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      QuerySnapshot unreadOrdersSnapshot = await _firestore
          .collection('notifications')
          .where('type', isEqualTo: 'order')
          .where('userId', isEqualTo: currentUser.uid)
          .where('read', isEqualTo: false)
          .get();

      unreadOrders.value = unreadOrdersSnapshot.docs.length;
      print('Updated unread orders count: ${unreadOrders.value}');
    } catch (e) {
      print('Error updating unread order count: $e');
    }
  }

  Future<void> markNotificationsAsRead(String type, {String? id}) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      WriteBatch batch = _firestore.batch();
      QuerySnapshot notifications;

      if (id != null) {
        notifications = await _firestore
            .collection('notifications')
            .where('type', isEqualTo: type)
            .where('userId', isEqualTo: currentUser.uid)
            .where(type == 'order'
                ? 'orderId'
                : type == 'chat'
                    ? 'chatRoomId'
                    : 'productId', isEqualTo: id)
            .where('read', isEqualTo: false)
            .get();
      } else {
        notifications = await _firestore
            .collection('notifications')
            .where('type', isEqualTo: type)
            .where('userId', isEqualTo: currentUser.uid)
            .where('read', isEqualTo: false)
            .get();
      }

      for (var doc in notifications.docs) {
        batch.update(doc.reference, {'read': true});
      }

      await batch.commit();

      // Update local counts
      await _updateNotificationCounts(type);
    } catch (e) {
      print('Error marking notifications as read: $e');
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      WriteBatch batch = _firestore.batch();

      QuerySnapshot notifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: currentUser.uid)
          .where('read', isEqualTo: false)
          .get();

      for (var doc in notifications.docs) {
        batch.update(doc.reference, {'read': true});
      }

      await batch.commit();

      // Clear local notification counts
      unreadChats.value = 0;
      unreadOrders.value = 0;

      // Clear device notifications
      await _localNotifications.cancelAll();
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  @override
  void onClose() {
    _chatNotificationsSubscription?.cancel();
    _orderNotificationsSubscription?.cancel();
    _productNotificationsSubscription?.cancel();
    super.onClose();
  }
}