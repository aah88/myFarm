// lib/widgets/section_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/design_tokens.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,          // ← لازم تمرّره
    this.subtitle,                // ← اختياري
    this.padding = EdgeInsets.zero,
    this.gap = 4,
    this.bottomSpace = 12,
    this.titleStyle,
    this.subtitleStyle,
    this.leading,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final EdgeInsets padding;
  final double gap;
  final double bottomSpace;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final TextStyle effectiveTitleStyle = titleStyle ??
        const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.green,
        );

    final TextStyle? effectiveSubtitleStyle = subtitle == null
        ? null
        : (subtitleStyle ??
            const TextStyle(
              fontSize: 14,
              color: AppColors.text,
              height: 1.25,
            ));

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null || trailing != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (leading != null) leading!,
                if (leading != null) const SizedBox(width: 8),
                Expanded(child: Text(title, style: effectiveTitleStyle)),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ],
              ],
            )
          else
            Text(title, style: effectiveTitleStyle),

          if (subtitle != null) ...[
            SizedBox(height: gap),
            Text(subtitle!, style: effectiveSubtitleStyle),
          ],

          SizedBox(height: bottomSpace),
        ],
      ),
    );
  }
}

/// نسخة للسليفَرز
class SliverSectionHeader extends StatelessWidget {
  const SliverSectionHeader({
    super.key,
    required this.title, // ← لازم تمرّره
    this.subtitle,       // ← اختياري
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 0),
    this.gap = 4,
    this.bottomSpace = 12,
    this.titleStyle,
    this.subtitleStyle,
    this.leading,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final EdgeInsets padding;
  final double gap;
  final double bottomSpace;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: SliverToBoxAdapter(
        child: SectionHeader(
          title: title,
          subtitle: subtitle,
          padding: EdgeInsets.zero,
          gap: gap,
          bottomSpace: bottomSpace,
          titleStyle: titleStyle,
          subtitleStyle: subtitleStyle,
          leading: leading,
          trailing: trailing,
        ),
      ),
    );
  }
}
