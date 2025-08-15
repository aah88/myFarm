import 'package:flutter/material.dart';
import 'bottom_nav.dart';

class AppScaffold extends StatelessWidget {
  final AppTab currentTab;
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Color? backgroundColor;

  const AppScaffold({
    super.key,
    required this.currentTab,
    required this.body,
    this.appBar,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.white,
      appBar: appBar,
      body: SafeArea(child: body),
      bottomNavigationBar: BottomNav(
        current: AppTab.home,
        activeColor: Colors.teal,      // لون الأيقونة المفعّلة
        inactiveColor: Colors.grey,    // (اختياري)
      ),

    );
  }
}
