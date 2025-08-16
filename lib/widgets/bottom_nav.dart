import 'package:flutter/material.dart';

/// حدّثنا التبويبات: استبدلنا reports بـ cart
enum AppTab { home, favorites, cart, notifications }

extension on AppTab {
  String get route {
    switch (this) {
      case AppTab.home:    return '/home';
      case AppTab.favorites:  return '/favorites';
      case AppTab.cart:    return '/cart';     // مسار جديد
      case AppTab.notifications: return '/notifications';
    }
  }
}

class BottomNav extends StatelessWidget {
  /// nullable: لو null ما يميّز أي تبويب (مفيد للصفحات الفرعية)
  final AppTab? current;
  final bool showNotificationsDot;

  /// ألوان وخلفية وارتفاع الشريط
  final Color activeColor;
  final Color inactiveColor;
  final Color backgroundColor;
  final double barHeight;

  const BottomNav({
    super.key,
    required this.current,
    this.showNotificationsDot = true,
    this.activeColor = const Color(0xFF2E7D32),
    this.inactiveColor = const Color(0xFFB6BAB5),
    this.backgroundColor = Colors.white,
    this.barHeight = 56,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_NavSpec>[
      _NavSpec(tab: AppTab.home,   icon: Icons.home_rounded),
      _NavSpec(tab: AppTab.favorites, icon: Icons.favorite),  // أوامر/طلبات
      _NavSpec(tab: AppTab.cart,   icon: Icons.shopping_cart_rounded), // السلة
      _NavSpec(
        tab: AppTab.notifications,
        icon: Icons.notifications_none_rounded,
        showDot: showNotificationsDot,
      ),
    ];

    return Container(
      width: double.infinity,
      height: barHeight,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: items.map((spec) {
          final selected = (current != null && current == spec.tab);
          return Expanded(
            child: _NavItem(
              icon: spec.icon,
              selected: selected,
              showDot: spec.showDot && spec.tab == AppTab.notifications,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
              onTap: () {
                if (!selected) {
                  Navigator.of(context).pushReplacementNamed(spec.tab.route);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NavSpec {
  final AppTab tab;
  final IconData icon;
  final bool showDot;
  const _NavSpec({required this.tab, required this.icon, this.showDot = false});
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool showDot;
  final Color activeColor;
  final Color inactiveColor;

  const _NavItem({
    required this.icon,
    required this.selected,
    required this.onTap,
    this.showDot = false,
    this.activeColor = const Color(0xFF2E7D32),
    this.inactiveColor = const Color(0xFFB6BAB5),
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? activeColor : inactiveColor;

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: double.infinity,
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 24, color: color),
              if (showDot)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
