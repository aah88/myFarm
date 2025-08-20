import 'package:flutter/material.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  readyForDelivery,
  outForDelivery,
  delivered,
  completed,
  cancelled,
  failed,
}


extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return "قيد الانتظار";
      case OrderStatus.confirmed:
        return "تم التأكيد";
      case OrderStatus.processing:
        return "قيد التحضير";
      case OrderStatus.readyForDelivery:
        return "جاهز للتسليم";
      case OrderStatus.outForDelivery:
        return "قيد التوصيل";
      case OrderStatus.delivered:
        return "تم التسليم";
      case OrderStatus.completed:
        return "مكتمل";
      case OrderStatus.cancelled:
        return "ملغي";
      case OrderStatus.failed:
        return "فشل";
    }
  }

  // Optional: for UI icons
  IconData get icon {
    switch (this) {
      case OrderStatus.pending:
        return Icons.hourglass_empty;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.processing:
        return Icons.build_circle_outlined;
      case OrderStatus.readyForDelivery:
        return Icons.inventory_2_outlined;
      case OrderStatus.outForDelivery:
        return Icons.local_shipping_outlined;
      case OrderStatus.delivered:
        return Icons.home_filled;
      case OrderStatus.completed:
        return Icons.verified;
      case OrderStatus.cancelled:
        return Icons.cancel;
      case OrderStatus.failed:
        return Icons.error_outline;
    }
  }
}