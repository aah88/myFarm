import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/design_tokens.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/listing_services.dart';
import '../../models/listing_model.dart';

class FavoritesScreen extends StatefulWidget {
  /// مرّر قائمة معرفات العروض (Listing IDs) المفضلة.
  /// مثال: FavoritesScreen(listingIds: ['abc', 'def'])
  const FavoritesScreen({super.key, this.listingIds});

  final List<String>? listingIds;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ListingService _firebaseListingService = ListingService();

  bool _loading = true;
  List<String> _ids = [];
  Map<String, Listing> _listingMap = {};

  @override
  void initState() {
    super.initState();
    _ids = List<String>.from(widget.listingIds ?? const []);
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    if (_ids.isEmpty) {
      _listingMap = {};
      setState(() => _loading = false);
      return;
    }

    final listings = await _firebaseListingService.getListingsByIds(_ids);
    _listingMap = {for (var l in listings) l.id: l};

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _refresh() async => _load();

  void _removeFromFavorites(String listingId) {
    setState(() {
      _ids.remove(listingId);
      _listingMap.remove(listingId);
    });
    // ملاحظة: هنا أزلناها محليًا. لو عندك تخزين للمفضلة (Firestore/Provider)
    // نفّذ الاستدعاء المناسب لحفظ التغيير أيضًا.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تمت إزالة العنصر من المفضلة')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cart = cartProvider.cart;
    return AppScaffold(
      currentTab: AppTab.favorites,
      cartPadgeCount: cart.items.length,
      appBar: AppBar(
        title: const Text('المفضلة'),
        actions: [
          if (_ids.isNotEmpty)
            IconButton(
              tooltip: 'مسح الكل',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () {
                setState(() {
                  _ids.clear();
                  _listingMap.clear();
                });
              },
            ),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _ids.isEmpty
              ? const _EmptyState()
              : RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                  itemCount: _ids.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final id = _ids[index];
                    final listing = _listingMap[id];
                    if (listing == null) {
                      // لو ما قدر يجلب العنصر، نخفيه بهدوء
                      return const SizedBox.shrink();
                    }

                    return _FavoriteCard(
                      listing: listing,
                      onRemove: () => _removeFromFavorites(id),
                      onOpen: () {
                        // افتح تفاصيل العرض لو عندك شاشة لذلك:
                        // Navigator.push(context, MaterialPageRoute(builder: (_) => ListingDetailsScreen(listing: listing)));
                      },
                    );
                  },
                ),
              ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  const _FavoriteCard({
    required this.listing,
    required this.onRemove,
    required this.onOpen,
  });

  final Listing listing;
  final VoidCallback onRemove;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    // خصائص مع fallback بسيط لو الحقول غير موجودة في الموديل
    final unit = _try(() => listing.unit) ?? 'وحدة';
    final price = _try(() => listing.price)?.toString() ?? '—';
    final imageUrl = _try(() => (listing as dynamic).imageUrl as String?) ?? '';
    final productName =
        _try(() => (listing as dynamic).productName as String?) ??
        'Product name';
    final farmerName =
        _try(() => (listing as dynamic).farmerName as String?) ?? 'المزارع';

    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onOpen,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE8EBE6)),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // الصورة
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    imageUrl.isNotEmpty
                        ? Image.network(
                          imageUrl,
                          height: 72,
                          width: 72,
                          fit: BoxFit.cover,
                        )
                        : Container(
                          height: 72,
                          width: 72,
                          color: const Color(0xFFF1F3F0),
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
              ),
              const SizedBox(width: 12),

              // معلومات
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      farmerName,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'الوحدة: $unit',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$price ل.س',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // أزرار سريعة
              Column(
                children: [
                  IconButton(
                    tooltip: 'إزالة من المفضلة',
                    icon: const Icon(Icons.favorite, color: Colors.redAccent),
                    onPressed: onRemove,
                  ),
                  IconButton(
                    tooltip: 'فتح',
                    icon: const Icon(Icons.open_in_new),
                    onPressed: onOpen,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ويدجت الحالة الفارغة
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
            Icon(Icons.favorite_border_rounded, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('لا توجد عناصر في المفضلة'),
            SizedBox(height: 4),
            Text(
              'أضف منتجات إلى المفضلة لعرضها هنا.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

/// دالة مساعدة لقراءة حقول اختيارية بأمان دون كسر الترجمة عند غياب الحقل
T? _try<T>(T Function() fn) {
  try {
    return fn();
  } catch (_) {
    return null;
  }
}
