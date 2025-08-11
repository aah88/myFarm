import 'package:flutter/material.dart';
import '../../models/unit_data.dart';
import 'package:provider/provider.dart';
import '../../providers/listing_provider.dart';
import '../../services/firebase_service.dart';

class ChooseUnitScreen extends StatefulWidget {
  const ChooseUnitScreen({super.key});

  @override
  State<ChooseUnitScreen> createState() => _ChooseUnitScreenState();
}

class _ChooseUnitScreenState extends State<ChooseUnitScreen> {
  int? selectedIndex; // Selected unit index
  String? dropdownValue; // Selected dropdown value
  final FirebaseService _firebaseService = FirebaseService();

  // Controllers for input fields
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _extraTextController = TextEditingController();

  // Add a new listing to Firebase
  void _addListing(newListing) async {
    await _firebaseService.addListing(newListing);
  }

  // Finish process and validate inputs
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
    context.read<ListingProvider>().setPrice(price);
    context.read<ListingProvider>().setQty(qty);

    // Add to Firebase
    _addListing(context.read<ListingProvider>().listing);

    // Return to previous screen with result
    Navigator.pop(context, {
      'unit': selectedUnit,
      'price': price,
      'dropdownChoice': dropdownChoice,
      'extraText': extraText,
    });
  }

  // Show extra field only for specific units
  bool get _showExtraField =>
      selectedIndex != null && units[selectedIndex!].withDescription == true;

  @override
  void dispose() {
    // Dispose controllers to free memory
    _priceController.dispose();
    _qtyController.dispose();
    _extraTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر وحدة القياس'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===== Horizontal icon list for units =====
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
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120), // مدة أقصر
                        curve: Curves.easeOut,
                        width: 56,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFECF1E8) : Colors.transparent,
                          border: Border.all(
                            color: const Color(0xFFE8EBE6),
                            width: 1.2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF2E7D32).withOpacity(0.08), // ظل أخف
                                    blurRadius: 4, // نعومة أقل
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 120),
                          opacity: isSelected ? 1 : 0.9, // الفرق بسيط
                          child: AnimatedScale(
                            scale: isSelected ? 1.03 : 1.0, // تكبير بسيط جدًا
                            duration: const Duration(milliseconds: 120),
                            curve: Curves.easeOut,
                            child: Tooltip(
                              message: unit.name,
                              child: Image.asset(unit.imagePath, height: 48),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),



            const SizedBox(height: 16),

            // Price input
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "السعر",
                hintText: "أدخل السعر",
              ),
            ),

            const SizedBox(height: 16),

            // Quantity input
            TextField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "الكميه",
                hintText: "أدخل الكمية",
              ),
            ),

            const SizedBox(height: 16),

            // Dropdown for "نخب"
            DropdownButtonFormField<String>(
              value: dropdownValue,
              decoration: const InputDecoration(
                labelText: "اختر نخب من القائمة",
                hintText: "اختر من القائمة",
                prefixIcon: Icon(Icons.list_alt, color: Color(0xFF91958E)),
              ),
              items: ['نخب 1', 'نخب 2', 'نخب 3']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  dropdownValue = value;
                });
              },
            ),

            const SizedBox(height: 16),

            // Extra field for special units
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

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
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
    );
  }
}
