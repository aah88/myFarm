import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/design_tokens.dart';

/// =====================
/// ثابتـات + دوال مساعدة
/// =====================

/// قائمة الحروف العربية + "الكل"
const arabicLettersWithAll = [
  'أ','ب','ت','ث','ج','ح','خ','د','ذ','ر','ز','س','ش','ص','ض',
  'ط','ظ','ع','غ','ف','ق','ك','ل','م','ن','ه','و','ي','الكل',
];

/// القيمة الافتراضية للحرف المختار
const defaultSelectedLetter = 'الكل';

/// خريطة لتطبيع بعض الأحرف
const Map<String, String> arabicCharMap = {
  'أ': 'ا',
  'إ': 'ا',
  'آ': 'ا',
  'ى': 'ي',
};

/// تطبيع أول حرف من النص
String normalizeFirstChar(String s) {
  if (s.trim().isEmpty) return '';
  final first = s.trim()[0];
  return arabicCharMap[first] ?? first;
}

/// هل الاسم يطابق الحرف المختار؟
bool matchesLetter(String name, String selectedLetter) {
  if (selectedLetter == defaultSelectedLetter) return true;
  return normalizeFirstChar(name) == normalizeFirstChar(selectedLetter);
}

/// فلترة عامة لأي قائمة عناصر عبر اسمها
List<T> filterBySelectedLetter<T>(
  List<T> items,
  String Function(T) nameSelector,
  String selectedLetter,
) {
  return items
      .where((item) => matchesLetter(nameSelector(item), selectedLetter))
      .toList();
}

/// =====================
/// الودجت: شريط الحروف
/// =====================
class LettersBar extends StatelessWidget {
  final List<String> letters;
  final String selectedLetter;
  final ValueChanged<String> onLetterSelected;

  // تخصيصات اختيارية
  final double letterSize;
  final double allWidth;
  final Color? selectedBgColor;
  final Color? unselectedBgColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? activeTextColor; 
  final double spacing;
  final double runSpacing;

  const LettersBar({
    super.key,
    this.letters = arabicLettersWithAll, // الافتراضي: الثابت
    required this.selectedLetter,
    required this.onLetterSelected,
    this.letterSize = 37,
    this.allWidth = 45,
    this.selectedBgColor,
    this.unselectedBgColor,
    this.borderColor,
    this.textColor,
    this.activeTextColor,
    this.spacing = 6,
    this.runSpacing = 6,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveSelectedBg = selectedBgColor ?? AppColors.green;
    final Color effectiveUnselectedBg = unselectedBgColor ?? AppColors.white;
    final Color effectiveBorder = borderColor ?? AppColors.gray200;
    final Color effectiveText = textColor ?? AppColors.green;
    final Color effectiveActiveText = activeTextColor ?? AppColors.white;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        children: [
          for (final letter in letters)
            InkWell(
              onTap: () => onLetterSelected(letter),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: letter == defaultSelectedLetter ? allWidth : letterSize,
                height: letterSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selectedLetter == letter
                      ? effectiveSelectedBg
                      : effectiveUnselectedBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: effectiveBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: selectedLetter == letter
                        ? effectiveActiveText   // ← نص أخضر للزر الفعال
                        : effectiveText,              ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
