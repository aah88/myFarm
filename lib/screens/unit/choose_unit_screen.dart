import 'package:flutter/material.dart';
import '../../models/unit_data.dart'; // your static units list
import 'package:provider/provider.dart';
import '../../providers/listing_provider.dart';
import '../../services/firebase_service.dart';
class ChooseUnitScreen extends StatefulWidget {
  const ChooseUnitScreen({super.key});

  @override
  State<ChooseUnitScreen> createState() => _ChooseUnitScreenState();
}

class _ChooseUnitScreenState extends State<ChooseUnitScreen> {
  int? selectedIndex;
  String? dropdownValue;
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _extraTextController = TextEditingController();

  void _addListing(newListing) async {
      await _firebaseService.addListing(newListing);
  }
  
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
 
  context.read<ListingProvider>().setUnit(selectedUnit);
  context.read<ListingProvider>().setPrice(price);
  context.read<ListingProvider>().setQty(qty);

   _addListing( context.read<ListingProvider>().listing);
   //Start date
  // Example: Navigate or save to DB here
  Navigator.pop(context, {
    'unit': selectedUnit,
    'price': price,
    'dropdownChoice': dropdownChoice,
    'extraText': extraText,
  });
  }

  bool get _showExtraField =>
      selectedIndex != null &&
      units[selectedIndex!].withDescription == true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر وحدة القياس'),
        backgroundColor: Color(0xFF2E7D32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // GRIDVIEW of units
            Expanded(
              child: GridView.builder(
                itemCount: units.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final unit = units[index];
                  final isSelected = selectedIndex == index;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.red.shade100 : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? Colors.red : Color(0xFF2E7D32),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(unit.imagePath, height: 60),
                          const SizedBox(height: 8),
                          Text(
                            unit.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.red : Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Always visible TextField
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: "السعر",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),
            // Always visible TextField
            TextField(
              controller: _qtyController,
              decoration: const InputDecoration(
                labelText: "الكميه",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Always visible Dropdown
            DropdownButtonFormField<String>(
              value: dropdownValue,
              decoration: const InputDecoration(
                labelText: "اختر نخب من القائمة",
                border: OutlineInputBorder(),
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

            // Extra TextField only for special unit
            if (_showExtraField) ...[
              TextField(
                controller: _extraTextController,
                decoration: InputDecoration(
                  labelText: "إدخال إضافي لـ ${units[selectedIndex!].name}",
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Finish button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2E7D32),
                  padding: const EdgeInsets.symmetric(vertical: 14),
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
