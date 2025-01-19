import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:farmlink/styles.dart';
import 'package:farmlink/controllers/ChatController.dart';

class bottomNavigationBarCustomer extends StatelessWidget {
  final String currentRoute;
  final ChatController chatController = Get.find<ChatController>();

  bottomNavigationBarCustomer({
    Key? key,
    required this.currentRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Styles.primaryColor,
      elevation: 8,
      child: SizedBox(
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              icon: Icons.home,
              label: 'Home',
              isSelected: currentRoute == '/homepageCustomer',
              onPressed: () {
                if (currentRoute != '/homepageCustomer') {
                  Get.offAllNamed('/homepageCustomer');
                }
              },
            ),
            _buildNavItem(
              icon: Icons.receipt_long,
              label: 'Orders',
              isSelected: currentRoute == '/orders',
              onPressed: () {
                if (currentRoute != '/orders') {
                  Get.toNamed('/orders');
                }
              },
            ),
            _buildNavItem(
              icon: Icons.chat,
              label: 'Chat',
              isSelected: currentRoute == '/chatRoomList' || currentRoute == '/chat',
              onPressed: () {
                if (currentRoute != '/chatRoomList') {
                  Get.toNamed('/chatRoomList');
                }
              },
              badgeCount: chatController.unreadCount,
            ),
            _buildNavItem(
              icon: Icons.person,
              label: 'Profile',
              isSelected: currentRoute == '/custprofile',
              onPressed: () {
                if (currentRoute != '/custprofile') {
                  Get.toNamed('/custprofile');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
    RxInt? badgeCount,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    color: isSelected ?  Colors.white : Styles.subtitleColor,
                    size: 24,
                  ),
                  if (badgeCount != null)
                    Obx(() {
                      if (badgeCount.value > 0) {
                        return Positioned(
                          right: -8,
                          top: -8,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              badgeCount.value.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    }),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ?  Colors.white : Styles.subtitleColor,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}