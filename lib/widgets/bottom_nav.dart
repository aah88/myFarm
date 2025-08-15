// lib/widgets/bottom_nav.dart
import 'package:flutter/material.dart';

enum AppTab { home, orders, reports, profile }

extension on AppTab {
  String get route {
    switch (this) {
      case AppTab.home:    return '/home';
      case AppTab.orders:  return '/orders';
      case AppTab.reports: return '/reports';
      case AppTab.profile: return '/profile';
    }
  }
}

class BottomNav extends StatelessWidget {
  final AppTab current;
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
      _NavSpec(tab: AppTab.home,    icon: Icons.home_rounded),
      _NavSpec(tab: AppTab.orders,  icon: Icons.shopping_cart_rounded),
      _NavSpec(tab: AppTab.reports, icon: Icons.favorite_border_rounded),
      _NavSpec(
        tab: AppTab.profile,
        icon: Icons.notifications_none_rounded,
        showDot: showNotificationsDot,
      ),
    ];

    // بدون SafeArea لتقليل الفراغ السفلي قدر الإمكان
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
          final selected = current == spec.tab;
          return Expanded(
            child: _NavItem(
              icon: spec.icon,
              selected: selected,
              showDot: spec.showDot && spec.tab == AppTab.profile,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
              onTap: () {
                if (!selected) {
                  // ينتقل ويستبدل الصفحة الحالية (ما يكدّس الستاك)
                  Navigator.of(context).pushReplacementNamed(spec.tab.route);

                  // بديل: لو تبي ترجع الستاك نظيف دائمًا
                  // Navigator.of(context).pushNamedAndRemoveUntil(spec.tab.route, (route) => false);
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
    required this.activeColor,
    required this.inactiveColor,
    this.showDot = false,
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
