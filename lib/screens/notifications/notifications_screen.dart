import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/design_tokens.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/bottom_nav.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

enum NotificationType { orderUpdate, promotion, system, message }

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  final NotificationType type;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<AppNotification> _items = [
    AppNotification(
      id: '1',
      title: 'تم استلام طلبك',
      body: 'تم استلام طلبك رقم #124 وسيتم التجهيز قريبًا.',
      time: DateTime.now().subtract(const Duration(minutes: 15)),
      type: NotificationType.orderUpdate,
      isRead: false,
    ),
    AppNotification(
      id: '2',
      title: 'عرض اليوم',
      body: 'خصم 10% على البطاطا حتى نهاية اليوم.',
      time: DateTime.now().subtract(const Duration(hours: 3)),
      type: NotificationType.promotion,
      isRead: false,
    ),
    AppNotification(
      id: '3',
      title: 'تذكير',
      body: 'لا تنسَ تحديث قائمة منتجاتك لهذا الأسبوع.',
      time: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      type: NotificationType.system,
      isRead: true,
    ),
    AppNotification(
      id: '4',
      title: 'رسالة من المشتري',
      body: 'هل متاح خيار التغليف بوحدات أصغر؟',
      time: DateTime.now().subtract(const Duration(days: 4)),
      type: NotificationType.message,
      isRead: true,
    ),
  ];

  Future<void> _refresh() async {
    // هنا تقدر تجيب إشعارات من السيرفر
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {});
  }

  void _markAllRead() {
    setState(() {
      for (final n in _items) {
        n.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تحديد كل الإشعارات كمقروءة')),
    );
  }

  void _toggleRead(AppNotification n) {
    setState(() => n.isRead = !n.isRead);
  }

  void _delete(String id) {
    setState(() => _items.removeWhere((e) => e.id == id));
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupBySection(_items);
    final cartProvider = context.watch<CartProvider>();
    final cart = cartProvider.cart;
    return AppScaffold(
      currentTab: AppTab.notifications,
      cartPadgeCount: cart.items.length,
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          if (_items.any((e) => !e.isRead))
            IconButton(
              tooltip: 'تحديد الكل كمقروء',
              icon: const Icon(Icons.mark_email_read_outlined),
              onPressed: _markAllRead,
            ),
          PopupMenuButton<String>(
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'clear', child: Text('مسح الكل')),
                ],
            onSelected: (v) {
              if (v == 'clear') {
                setState(() => _items.clear());
              }
            },
          ),
        ],
      ),
      body:
          _items.isEmpty
              ? const _EmptyState()
              : RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final entry = grouped[index];
                    if (entry.isHeader) {
                      return _SectionHeader(title: entry.header!);
                    } else {
                      final n = entry.notification!;
                      return Dismissible(
                        key: ValueKey(n.id),
                        direction: DismissDirection.endToStart,
                        background: _deleteBg(),
                        onDismissed: (_) => _delete(n.id),
                        child: _NotificationTile(
                          n: n,
                          onToggleRead: () => _toggleRead(n),
                        ),
                      );
                    }
                  },
                ),
              ),
    );
  }

  // ====== Helpers ======

  List<_RowEntry> _groupBySection(List<AppNotification> list) {
    final now = DateTime.now();
    final today = <AppNotification>[];
    final yesterday = <AppNotification>[];
    final earlier = <AppNotification>[];

    for (final n in list..sort((a, b) => b.time.compareTo(a.time))) {
      if (_isSameDay(n.time, now)) {
        today.add(n);
      } else if (_isSameDay(n.time, now.subtract(const Duration(days: 1)))) {
        yesterday.add(n);
      } else {
        earlier.add(n);
      }
    }

    final entries = <_RowEntry>[];
    if (today.isNotEmpty) {
      entries.add(_RowEntry.header('اليوم'));
      entries.addAll(today.map(_RowEntry.item));
    }
    if (yesterday.isNotEmpty) {
      entries.add(_RowEntry.header('أمس'));
      entries.addAll(yesterday.map(_RowEntry.item));
    }
    if (earlier.isNotEmpty) {
      entries.add(_RowEntry.header('الأقدم'));
      entries.addAll(earlier.map(_RowEntry.item));
    }
    return entries;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _deleteBg() => Container(
    color: Colors.red.withValues(alpha: 0.1),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    alignment: Alignment.centerRight,
    child: const Icon(Icons.delete_outline, color: Colors.red),
  );
}

class _RowEntry {
  final String? header;
  final AppNotification? notification;

  bool get isHeader => header != null;

  _RowEntry.header(this.header) : notification = null;
  _RowEntry.item(this.notification) : header = null;
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.green,
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification n;
  final VoidCallback onToggleRead;

  const _NotificationTile({required this.n, required this.onToggleRead});

  @override
  Widget build(BuildContext context) {
    final icon = _iconForType(n.type);
    final bg = _bgForType(n.type);
    final timeStr = _formatTime(n.time);
    final unreadDot = !n.isRead;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: bg,
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(
        n.title,
        style: TextStyle(
          fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w800,
        ),
      ),
      subtitle: Text(n.body, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            timeStr,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          if (unreadDot)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      onTap: onToggleRead,
      onLongPress: onToggleRead,
    );
  }

  static IconData _iconForType(NotificationType t) {
    switch (t) {
      case NotificationType.orderUpdate:
        return Icons.local_shipping_rounded;
      case NotificationType.promotion:
        return Icons.local_offer_rounded;
      case NotificationType.system:
        return Icons.info_rounded;
      case NotificationType.message:
        return Icons.chat_bubble_rounded;
    }
  }

  static Color _bgForType(NotificationType t) {
    switch (t) {
      case NotificationType.orderUpdate:
        return const Color(0xFF66BB6A);
      case NotificationType.promotion:
        return const Color(0xFFFFA726);
      case NotificationType.system:
        return const Color(0xFF42A5F5);
      case NotificationType.message:
        return const Color(0xFFAB47BC);
    }
  }

  static String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 12),
            Text('لا توجد إشعارات حالياً'),
            SizedBox(height: 4),
            Text('سنخبرك بكل جديد هنا.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
