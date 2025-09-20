// product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/design_tokens.dart';
import 'package:flutter_application_1/widgets/bottom_nav.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _pageCtrl = PageController();
  int _page = 0;
  int _qty = 1;
  bool _fav = false;
  bool _expanded = false;

  final List<String> _assetImages = const [
    'lib/assets/images/tomato.jpg',
    'lib/assets/images/tomato.jpg',
    'lib/assets/images/tomato.jpg',
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final priceStyle = Theme.of(
      context,
    ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w700);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            tooltip: 'رجوع',
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          actions: [
            IconButton(
              tooltip: _fav ? 'إزالة من المفضلة' : 'أضف إلى المفضلة',
              onPressed: () => setState(() => _fav = !_fav),
              icon: Icon(
                _fav ? Icons.favorite : Icons.favorite_border,
                color: _fav ? Colors.red : Colors.black54,
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min, // حتى يأخذ أقل ارتفاع ممكن
          children: [
            // شريط السعر + زر أضف إلى السلة (كما هو)
            SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '15000 ليرة',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تمت إضافة $_qty إلى السلة'),
                            ),
                          );
                        },
                        child: const Text(
                          'أضف إلى السلة',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 👇 الـ BottomNav في الأسفل دائماً
            const BottomNav(current: null),
          ],
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // الصور + المؤشر
              AspectRatio(
                aspectRatio: 1.4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      PageView.builder(
                        controller: _pageCtrl,
                        itemCount: _assetImages.length,
                        onPageChanged: (i) => setState(() => _page = i),
                        itemBuilder:
                            (_, i) => Ink.image(
                              image: AssetImage(_assetImages[i]),
                              fit: BoxFit.cover,
                            ),
                      ),
                      Positioned(
                        bottom: 12,
                        child: _Dots(
                          count: _assetImages.length,
                          index: _page,
                          activeColor: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ✅ الشريط الجديد (نجمة – موقع – اسم المزرعة) مع فواصل داخل إطار دائري
              _InfoStrip(
                farmName: 'اسم المزرعة',
                region: 'ريف حماة',
                rating: 4.8,
                color: AppColors.green,
                bkColor: AppColors.white,
              ),

              const SizedBox(height: 16),

              // العنوان و الوزن
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'منتج بلاستيك',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.black54),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'بندورة حمراء بلدية',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.green,
                          ),
                        ),

                        const SizedBox(height: 4),
                        Text(
                          '5 كيلو',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      _QtyButton(
                        icon: Icons.remove,
                        onTap:
                            () => setState(() {
                              if (_qty > 1) _qty--;
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          '$_qty',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      _QtyButton(
                        icon: Icons.add,
                        onTap: () => setState(() => _qty++),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // الوصف
              Text(
                'بندورة طازجة مزروعة محلياً في تربة عضوية نقية، ناضجة وقطوفة يومياً لتصل إليك بأعلى جودة وطعم غني. مثالية للسلطات، الصلصات، والطبخ اليومي...',
                maxLines: _expanded ? null : 3,
                overflow:
                    _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  child: Text(_expanded ? 'إظهار أقل' : 'اقرأ المزيد'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// =====================
/// Widgets المساعدة
/// =====================

/// شريط معلومات داخل حاوية بحواف دائرية وفواصل عمودية
class _InfoStrip extends StatelessWidget {
  final String farmName;
  final String region;
  final double rating;
  final Color color; // لون الأيقونات/النص
  final Color bkColor; // لون الخلفية الجديد

  const _InfoStrip({
    required this.farmName,
    required this.region,
    required this.rating,
    required this.color,
    this.bkColor = const Color(0xFFF8FAF8), // القيمة الافتراضية القديمة
  });

  @override
  Widget build(BuildContext context) {
    final divider = Container(
      width: 1,
      height: 22,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: const Color(0xFFE6E9EA),
    );

    final textStyle = TextStyle(
      color: color,
      fontWeight: FontWeight.w600,
      height: 1.2,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bkColor, // ← تم اعتماد لون الخلفية القادم من البارامتر
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE6E9EA)),
      ),
      child: Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, size: 20, color: Colors.amber),
              const SizedBox(width: 6),
              Text(
                rating.toStringAsFixed(
                  rating.truncateToDouble() == rating ? 0 : 1,
                ),
              ),
            ],
          ),
          divider,
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.place_rounded, size: 20, color: color),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    region,
                    style: textStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          divider,
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.home_outlined, size: 20, color: color),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    farmName,
                    style: textStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// مؤشر نقاط للصور
class _Dots extends StatelessWidget {
  final int count;
  final int index;
  final Color activeColor;
  const _Dots({
    required this.count,
    required this.index,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        count,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: i == index ? 10 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: i == index ? activeColor : Colors.white70,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

/// زر عدد (+ / -)
class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE6E9EA)),
        shape: BoxShape.circle,
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: 20), // ← يستخدم الأيقونة الممرَّرة
        ),
      ),
    );
  }
}
