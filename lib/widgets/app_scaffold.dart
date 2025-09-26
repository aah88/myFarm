import 'package:flutter/material.dart';
import 'bottom_nav.dart'; // 👈 لازم نستورد AppTab من هنا فقط

class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;

  /// لو null يعني لا تفعّل أي تبويب (مفيد للصفحات الفرعية)
  final AppTab? currentTab;

  final int? cartPadgeCount; // أو أي مصدر للعدد

  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final bool extendBody;

  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    required this.currentTab, // خليها مطلوبة حتى تنتبه تمرّرها (حتى لو null)
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.extendBody = false,
    this.cartPadgeCount,
  });

  @override
  Widget build(BuildContext context) {
    // debugPrint('[AppScaffold] currentTab=$currentTab'); // تشخيص إن احتجت
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      body: body,
      bottomNavigationBar: BottomNav(
        current: currentTab,
        cartPadgeCount: cartPadgeCount ?? 0,
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      extendBody: extendBody,
    );
  }
}
