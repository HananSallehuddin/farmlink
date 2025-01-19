import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabControllerHelper extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final int length;

  TabControllerHelper(this.length) {
    tabController = TabController(length: length, vsync: this);
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}