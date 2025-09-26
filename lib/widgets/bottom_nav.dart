import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/design_tokens.dart';

/// التبويبات الحالية
enum AppTab { home, favorites, cart, notifications }

extension on AppTab {
  String get route {
    switch (this) {
      case AppTab.home:
        return '/home';
      case AppTab.favorites:
        return '/favorites';
      case AppTab.cart:
        return '/cart';
      case AppTab.notifications:
        return '/notifications';
    }
  }
}

class BottomNav extends StatelessWidget {
  /// nullable: لو null ما يميّز أي تبويب (مفيد للصفحات الفرعية)
  final AppTab? current;
  final bool showNotificationsDot;

  /// عدد العناصر في السلة (لإظهار الشارة)
  final int cartPadgeCount;

  /// ألوان وخلفية وارتفاع الشريط
  final Color activeColor;
  final Color inactiveColor;
  final Color backgroundColor;
  final double barHeight;

  const BottomNav({
    super.key,
    required this.current,
    this.showNotificationsDot = true,
    this.cartPadgeCount = 0,
    this.activeColor = AppColors.green,
    this.inactiveColor = const Color(0xFFB6BAB5),
    this.backgroundColor = Colors.white,
    this.barHeight = 56,
  });

  @override
  Widget build(BuildContext context) {
    // لكل تبويب: أيقونة مفعّلة (filled) وأيقونة غير مفعّلة (outline)
    final items = <_NavSpec>[
      const _NavSpec(
        tab: AppTab.home,
        activeIcon: Icons.home_rounded,
        inactiveIcon: Icons.home_outlined,
      ),
      _NavSpec(
        tab: AppTab.cart,
        activeIcon: Icons.shopping_cart_rounded,
        inactiveIcon: Icons.shopping_cart_outlined,
        badgeCount: cartPadgeCount, // ← شارة السلة
      ),
      const _NavSpec(
        tab: AppTab.favorites,
        activeIcon: Icons.favorite, // filled
        inactiveIcon: Icons.favorite_border_rounded, // outline
      ),
      _NavSpec(
        tab: AppTab.notifications,
        activeIcon: Icons.notifications_rounded,
        inactiveIcon: Icons.notifications_none_rounded,
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
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children:
            items.map((spec) {
              final selected = (current != null && current == spec.tab);
              return Expanded(
                child: _NavItem(
                  icon: selected ? spec.activeIcon : spec.inactiveIcon,
                  selected: selected,
                  // نقطة الإشعارات فقط لتبويب الإشعارات
                  showDot: spec.showDot && spec.tab == AppTab.notifications,
                  // الشارة الرقمية فقط لتبويب السلة
                  badgeCount: spec.tab == AppTab.cart ? spec.badgeCount : 0,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                  onTap: () {
                    if (selected) return;

                    if (spec.tab == AppTab.home) {
                      // Home يرجع للجذر (أنظف)
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushNamedAndRemoveUntil('/home', (route) => false);
                    } else {
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushReplacementNamed(spec.tab.route);
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
  final IconData activeIcon;
  final IconData inactiveIcon;
  final bool showDot;
  final int badgeCount; // للسلة

  const _NavSpec({
    required this.tab,
    required this.activeIcon,
    required this.inactiveIcon,
    this.showDot = false,
    this.badgeCount = 0,
  });
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool showDot;
  final int badgeCount; // > 0 => show numeric badge
  final Color activeColor;
  final Color inactiveColor;

  const _NavItem({
    required this.icon,
    required this.selected,
    required this.onTap,
    this.showDot = false,
    this.badgeCount = 0,
    this.activeColor = AppColors.green,
    this.inactiveColor = const Color(0xFFB6BAB5),
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? activeColor : inactiveColor;
    final showBadge = badgeCount > 0;
    // نحد العداد إلى 99+ لعدم كسر التصميم
    final badgeText = (badgeCount > 99) ? '99+' : badgeCount.toString();

    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: double.infinity,
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 24, color: color),

              // نقطة الإشعارات (صغيرة)
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

              // شارة السلة الرقمية
              if (showBadge)
                Positioned(
                  right: -8,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
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
