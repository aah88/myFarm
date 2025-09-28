import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/design_tokens.dart';
import 'package:flutter_application_1/widgets/bottom_nav.dart';
import '../../models/local_data.dart';
import 'package:provider/provider.dart';
import '../../providers/listing_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/listing_services.dart';

class ChooseUnitScreen extends StatefulWidget {
  const ChooseUnitScreen({super.key});

  @override
  State<ChooseUnitScreen> createState() => _ChooseUnitScreenState();
}

class _ChooseUnitScreenState extends State<ChooseUnitScreen> {
  int? selectedIndex; // Stores the selected unit index
  String? dropdownValue; // Stores the selected dropdown value
  final ListingService _firebaseListingService = ListingService();

  // Controllers for input fields
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _extraTextController = TextEditingController();

  // Constant: available grade options
  static const List<String> _grades = ['نخب 1', 'نخب 2', 'نخب 3'];

  // Constants: dimensions for unit icons
  static const double _unitItemWidth = 56;
  static const double _unitIconHeight = 48;

  // Add new listing to Firebase
  Future<void> _addListing(newListing) async {
    await _firebaseListingService.addListing(newListing);
  }

  // Handle finishing process and validating inputs
  void _finishProcess() {
    if (selectedIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء اختيار وحدة قياس أولاً")),
      );
      return;
    }

    final selectedUnit = units[selectedIndex!].name;
    final price = _priceController.text;
    final qty = _qtyController.text;
    final dropdownChoice = dropdownValue;
    final extraText = _showExtraField ? _extraTextController.text : null;

    // Save data in provider
    context.read<ListingProvider>().setUnit(selectedUnit);
    context.read<ListingProvider>().setPrice(double.parse(price));
    context.read<ListingProvider>().setQty(int.parse(qty));
    context.read<ListingProvider>().setSellerName(
      context.read<UserProvider>().userName!,
    );

    // Save to Firebase
    _addListing(context.read<ListingProvider>().listing);

    // Return to previous screen with the collected data
    Navigator.pop(context, {
      'unit': selectedUnit,
      'price': price,
      'dropdownChoice': dropdownChoice,
      'extraText': extraText,
    });
  }

  // Show extra text field only for specific units
  bool get _showExtraField =>
      selectedIndex != null && units[selectedIndex!].withDescription == true;

  @override
  void dispose() {
    // Dispose controllers to free memory and avoid leaks
    _priceController.dispose();
    _qtyController.dispose();
    _extraTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFE8EBE6); // Light gray border color

    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر وحدة القياس'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ==== Section Title for Unit Selection ====
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                "اختر الايقونة المناسبة:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF91958E),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ==== Horizontal list of unit icons ====
            SizedBox(
              height: 80,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(units.length, (index) {
                    final unit = units[index];
                    final isSelected = selectedIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            curve: Curves.easeOut,
                            width: _unitItemWidth,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? const Color(0xFFECF1E8)
                                      : Colors.transparent,
                              border: Border.all(
                                color: borderColor,
                                width: 1.2,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow:
                                  isSelected
                                      ? [
                                        BoxShadow(
                                          color: AppColors.green.withValues(
                                            alpha: 0.08,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                      : const [],
                            ),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 120),
                              opacity: isSelected ? 1 : 0.9,
                              child: AnimatedScale(
                                scale: isSelected ? 1.03 : 1.0,
                                duration: const Duration(milliseconds: 120),
                                curve: Curves.easeOut,
                                child: Tooltip(
                                  message: unit.name,
                                  child: Image.asset(
                                    unit.imagePath,
                                    height: _unitIconHeight,
                                    filterQuality: FilterQuality.low,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            unit.name,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ==== Price Input Field ====
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "السعر",
                hintText: "أدخل السعر",
              ),
            ),

            const SizedBox(height: 16),

            // ==== Quantity Input Field ====
            TextField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "الكميه",
                hintText: "أدخل الكمية",
              ),
            ),

            const SizedBox(height: 16),

            // ==== Dropdown Menu for Grade Selection ====
            DropdownButtonFormField<String>(
              initialValue: dropdownValue,
              borderRadius: BorderRadius.circular(12),
              dropdownColor: Colors.white,
              decoration: const InputDecoration(
                labelText: "اختر نخب من القائمة",
                hintText: "اختر من القائمة",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.list_alt, color: Color(0xFF91958E)),
              ),
              items:
                  _grades
                      .map(
                        (e) =>
                            DropdownMenuItem<String>(value: e, child: Text(e)),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  dropdownValue = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // ==== Extra Information Field (only for special units) ====
            if (_showExtraField) ...[
              TextField(
                controller: _extraTextController,
                decoration: InputDecoration(
                  labelText:
                      "معلومات اضافية عن محتوى ال ${units[selectedIndex!].name}",
                  hintText: "أدخل المعلومات الإضافية",
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ==== Submit Button ====
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _finishProcess,
                child: const Text(
                  "إنهاء العملية",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      // ✅ BottomNav بدون تفعيل أي تبويب
      bottomNavigationBar: const BottomNav(current: null),
    );
  }
}
