import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

enum ChatBotIntentType {
  greeting,
  orderStatus,
  paymentIssue,
  shippingInfo,
  accountIssue,
  productInfo,
  sellerInfo,
  generalHelp,
  returns,
  feedback,
  unknown
}

class ChatBotIntent {
  final ChatBotIntentType type;
  //represent common phrase that trigger this intent
  final List<String> patterns;
  //predefined response the chatbot will give when intent is matched
  final List<String> responses;
  //chatbot ask after delivering response
  final List<String>? followUpQuestions;
  //stores predefined quick replies (button)
  final Map<String, String>? quickReplies;

  ChatBotIntent({
    required this.type,
    required this.patterns,
    required this.responses,
    this.followUpQuestions,
    this.quickReplies,
  });
}

class SupportChatBot {
  //hold all intent chatbot can handle
  static final List<ChatBotIntent> intents = [
    // Greeting Intent
    ChatBotIntent(
      type: ChatBotIntentType.greeting,
      patterns: [
        'hello',
        'hi',
        'hey',
        'good morning',
        'good afternoon',
        'good evening',
        'help',
      ],
      responses: [
        'Hello! Welcome to FarmLink Support. How can I help you today?',
        'Hi there! I\'m here to help. What can I assist you with?'
      ],
      quickReplies: {
        'Check Order Status': 'I want to check my order status',
        'Payment Issues': 'I have a payment issue',
        'Shipping Question': 'I have a question about shipping',
        'Account Help': 'I need help with my account',
      },
    ),

    // Order Status Intent
    ChatBotIntent(
      type: ChatBotIntentType.orderStatus,
      patterns: [
        'order status',
        'where is my order',
        'track order',
        'order tracking',
        'check order',
        'my order',
      ],
      responses: [
        'I can help you check your order status. Please note that:\n\n' +
        '1. Pending: Order is being reviewed\n' +
        '2. Processing: Order is confirmed and being prepared\n' +
        '3. Shipped: Order is on the way\n' +
        '4. Delivered: Order has been received\n\n' +
        'You can check your order status in the "Orders" tab of your account.',
      ],
      followUpQuestions: [
        'Would you like to know more about our shipping process?',
        'Is there anything specific about your order you\'d like to know?'
      ],
      quickReplies: {
        'View Orders': 'Take me to my orders',
        'Shipping Info': 'Tell me about shipping',
        'Payment Status': 'Check payment status',
      },
    ),

    // Payment Issue Intent
    ChatBotIntent(
      type: ChatBotIntentType.paymentIssue,
      patterns: [
        'payment',
        'payment issue',
        'payment failed',
        'payment method',
        'payment options',
        'how to pay',
        'cant pay',
      ],
      responses: [
        'Currently, FarmLink supports Cash on Delivery (COD) payment method. ' +
        'If you\'re having issues with payment, here are some tips:\n\n' +
        '1. Ensure your shipping address is correct\n' +
        '2. Check if the products are still in stock\n' +
        '3. Try refreshing the app and placing the order again\n\n' +
        'If you continue to experience issues, please let me know.',
      ],
      quickReplies: {
        'Update Address': 'Update delivery address',
        'Try Again': 'Retry payment',
        'Other Issues': 'I have other payment issues',
      },
    ),

    // Shipping Info Intent
    ChatBotIntent(
      type: ChatBotIntentType.shippingInfo,
      patterns: [
        'shipping',
        'delivery',
        'shipping time',
        'delivery time',
        'when will i receive',
        'shipping address',
        'change address',
      ],
      responses: [
        'Here\'s what you need to know about our shipping:\n\n' +
        '1. Delivery times vary by location\n' +
        '2. You can track your order status in the Orders tab\n' +
        '3. Make sure your address is correct before checkout\n' +
        '4. You can update your address in your profile settings\n\n' +
        'Would you like to know more about any of these topics?',
      ],
      quickReplies: {
        'Update Address': 'Change my address',
        'Track Order': 'Track my order',
        'Delivery Areas': 'Check delivery areas',
      },
    ),

    // Account Issue Intent
    ChatBotIntent(
      type: ChatBotIntentType.accountIssue,
      patterns: [
        'account',
        'login',
        'cant login',
        'password',
        'forgot password',
        'reset password',
        'change email',
        'update profile',
      ],
      responses: [
        'I can help you with account-related issues. Here are common solutions:\n\n' +
        '1. For password reset, use the "Forgot Password" option on login\n' +
        '2. Ensure your email is verified\n' +
        '3. Update your profile in the Profile tab\n' +
        '4. Make sure you\'re using the correct email\n\n' +
        'What specific account issue are you facing?',
      ],
      quickReplies: {
        'Reset Password': 'Reset my password',
        'Verify Email': 'Verify my email',
        'Update Profile': 'Update my profile',
      },
    ),

    // Product Info Intent
    ChatBotIntent(
      type: ChatBotIntentType.productInfo,
      patterns: [
        'product',
        'product info',
        'product details',
        'item details',
        'product quality',
        'product description',
        'stock',
      ],
      responses: [
        'For product information:\n\n' +
        '1. Each product listing shows detailed information\n' +
        '2. You can see stock availability in real-time\n' +
        '3. Product images show actual items\n' +
        '4. You can contact sellers directly for specific questions\n\n' +
        'Would you like to know more about any product features?',
      ],
      quickReplies: {
        'Find Products': 'Search products',
        'Contact Seller': 'Talk to seller',
        'Check Stock': 'Check availability',
      },
    ),

    // Seller Info Intent
    ChatBotIntent(
      type: ChatBotIntentType.sellerInfo,
      patterns: [
        'seller',
        'seller info',
        'contact seller',
        'message seller',
        'seller rating',
        'seller details',
      ],
      responses: [
        'About our sellers:\n\n' +
        '1. All sellers are verified local farmers\n' +
        '2. You can chat with sellers directly\n' +
        '3. View seller details on product pages\n' +
        '4. Report any issues with sellers to support\n\n' +
        'How can I help you with seller-related questions?',
      ],
      quickReplies: {
        'Find Seller': 'Find a seller',
        'Message Seller': 'Message a seller',
        'Report Issue': 'Report a problem',
      },
    ),

    // Returns Intent
    ChatBotIntent(
      type: ChatBotIntentType.returns,
      patterns: [
        'return',
        'refund',
        'cancel order',
        'wrong item',
        'damaged item',
        'quality issue',
      ],
      responses: [
        'For returns and refunds:\n\n' +
        '1. Contact the seller directly through chat\n' +
        '2. Document any issues with photos\n' +
        '3. Don\'t accept damaged deliveries\n' +
        '4. Report serious issues to support\n\n' +
        'What specific issue are you facing?',
      ],
      quickReplies: {
        'Contact Seller': 'Contact seller',
        'Report Issue': 'Report problem',
        'Cancel Order': 'Cancel my order',
      },
    ),

    // General Help Intent
    ChatBotIntent(
      type: ChatBotIntentType.generalHelp,
      patterns: [
        'help',
        'support',
        'guide',
        'how to',
        'tutorial',
        'instructions',
      ],
      responses: [
        'Here are the main features of FarmLink:\n\n' +
        '1. Browse and buy local produce\n' +
        '2. Chat with sellers directly\n' +
        '3. Track your orders\n' +
        '4. Manage your profile and addresses\n\n' +
        'What would you like to learn more about?',
      ],
      quickReplies: {
        'Shopping Guide': 'How to shop',
        'Chat Guide': 'How to chat',
        'Order Guide': 'How to order',
      },
    ),

    // Feedback Intent
    ChatBotIntent(
      type: ChatBotIntentType.feedback,
      patterns: [
        'feedback',
        'suggestion',
        'review',
        'rate',
        'complaint',
        'improve',
      ],
      responses: [
        'We value your feedback! You can:\n\n' +
        '1. Rate products after delivery\n' +
        '2. Contact sellers directly\n' +
        '3. Report issues to support\n' +
        '4. Suggest improvements\n\n' +
        'What type of feedback would you like to provide?',
      ],
      quickReplies: {
        'Rate Product': 'Rate a product',
        'Give Feedback': 'Provide feedback',
        'Report Issue': 'Report a problem',
      },
    ),

    // Unknown Intent
    ChatBotIntent(
      type: ChatBotIntentType.unknown,
      patterns: [],
      responses: [
        'I\'m not sure I understand. Could you please rephrase that or choose from these common topics?',
        'I apologize, but I\'m not sure about that. Would you like to try one of these common topics?',
      ],
      quickReplies: {
        'Order Help': 'Help with orders',
        'Payment Help': 'Help with payment',
        'Account Help': 'Help with account',
        'Contact Support': 'Talk to human support',
      },
    ),
  ];
  
  //generate response based on user input
  static String generateResponse(String userInput) {
    try {
      final normalizedInput = userInput.toLowerCase().trim();
      
      // Find matching intent
      for (var intent in intents) {
        for (var pattern in intent.patterns) {
          if (normalizedInput.contains(pattern.toLowerCase())) {
            // Randomly select a response from available responses
            final response = intent.responses[
              DateTime.now().millisecondsSinceEpoch % intent.responses.length
            ];

            // Add follow-up question if available
            if (intent.followUpQuestions != null && intent.followUpQuestions!.isNotEmpty) {
              final followUp = intent.followUpQuestions![
                DateTime.now().millisecondsSinceEpoch % intent.followUpQuestions!.length
              ];
              return '$response\n\n$followUp';
            }

            return response;
          }
        }
      }

      // Return unknown intent response if no match found
      final unknownIntent = intents.firstWhere((i) => i.type == ChatBotIntentType.unknown);
      return unknownIntent.responses[
        DateTime.now().millisecondsSinceEpoch % unknownIntent.responses.length
      ];
    } catch (e) {
      print('Error generating response: $e');
      return 'I apologize, but I\'m having trouble processing your request. Please try again or choose from the common topics.';
    }
  }

  static Map<String, String>? getQuickReplies(String userInput) {
    try {
      final normalizedInput = userInput.toLowerCase().trim();
      
      // Find matching intent
      for (var intent in intents) {
        for (var pattern in intent.patterns) {
          if (normalizedInput.contains(pattern.toLowerCase())) {
            return intent.quickReplies;
          }
        }
      }

      // Return unknown intent quick replies if no match found
      final unknownIntent = intents.firstWhere((i) => i.type == ChatBotIntentType.unknown);
      return unknownIntent.quickReplies;
    } catch (e) {
      print('Error getting quick replies: $e');
      return null;
    }
  }
}