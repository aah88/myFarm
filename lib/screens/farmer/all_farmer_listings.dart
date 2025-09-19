import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/design_tokens.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/models/cart_model.dart';
import 'package:flutter_application_1/models/full_listing.dart';
import 'package:flutter_application_1/widgets/bottom_nav.dart';

import '../../providers/cart_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/firebase_service.dart';
import '../../widgets/product_listing_card.dart'; // ✅ الكارت الجديد

class AllFarmerListingsScreen extends StatefulWidget {
  const AllFarmerListingsScreen({super.key});

  @override
  State<AllFarmerListingsScreen> createState() =>
      _AllFarmerListingsScreenState();
}

class _AllFarmerListingsScreenState extends State<AllFarmerListingsScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  final String farmerImage =
      'https://cdn-icons-png.flaticon.com/512/3595/3595455.png';

  // ===== شريط الفلاتر (واجهة) =====
  final List<String> _segments = const ['الكل','فواكه', 'خضار', 'بيض', 'لحم', 'اعشاب و ورقيات','حليب و مشتقاته' ];
  String _selectedSegment = 'الكل'; // لتلوين الشريحة المختارة فقط الآن

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إدارة منتجاتك',
          style: TextStyle(color: AppColors.green),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // 🌿 نص إرشادي أعلى الصفحة
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'حدّث محاصيلك بسهولة:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.green,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "اختر أحد المنتجات أدناه لتعديل المنتج او حذفه.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),

            // ===== شريط الفلاتر قبل المنتجات =====
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 6, 0, 8),
              child: Wrap(
                textDirection: TextDirection.rtl,   // حتى يبدأ من اليمين
                alignment: WrapAlignment.start,     // محاذاة العناصر في كل سطر
                runAlignment: WrapAlignment.start,  // محاذاة الأسطر عموديًا
                spacing: 8,                         // مسافة بين الشرائح أفقياً
                runSpacing: 8,                      // مسافة بين الأسطر عمودياً
                children: _segments.map((label) {
                  final bool selected = _selectedSegment == label;
                  return ChoiceChip(
                    label: Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppColors.green,
                      ),
                    ),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedSegment = label),
                    shape: const StadiumBorder(),
                    backgroundColor: const Color(0xFFF1F4F1),
                    selectedColor: AppColors.green,
                    side: BorderSide.none,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ),

            // 🛒 شبكة المنتجات
            Expanded(
              child: FutureBuilder<List<FullListing>>(
                future: _firebaseService.getFarmerFullListings(
                  context.read<UserProvider>().userId!,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('حدث خطأ: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('لا توجد منتجات متاحة'));
                  }

                  final listings = snapshot.data!;
                  // ملاحظة: شريط الفلاتر واجهة فقط؛ لو عندك حقل تصنيف بالـ FullListing
                  // فعّل الفلترة هنا حسب _selectedSegment.

                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: GridView.builder(
                      padding: const EdgeInsets.only(top: 4),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 250, // 👈 أقصى عرض للكارت الواحد
                        childAspectRatio:
                            0.9, // 👈 اضبط حسب ارتفاع/عرض الكارت عندك
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: listings.length,
                      itemBuilder: (context, index) {
                        final listing = listings[index];
                        return ProductListingCard(
                          imageUrl: listing.productImageUrl,
                          title: listing.productName,
                          rating: listing.rating,
                          price: listing.price,
                          farmerName: listing.farmerName,
                          distance: 0,
                          action: ListingCardAction
                              .edit, // أو ListingCardAction.add للمشتري
                          onEdit: () {
                            Navigator.pushNamed(
                              context,
                              '/edit-listing',
                              arguments: listing.id,
                            ).then((_) => setState(() {}));
                          },
                          onAddToCart: () {},

                          // ✅ زر الحذف (اختياري، يظهر فقط إذا مرّرناه)
                          onDelete: () {
                            Navigator.pushNamed(
                              context,
                              '/edit-listing',
                              arguments: listing.id,
                            ).then((_) => setState(() {}));
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(current: null),
    );
  }
}
