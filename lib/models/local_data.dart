import 'unit_model.dart';
import 'delivery_mean_model.dart';
import 'payment_mean_mode.dart';
const List<Unit> units = [
  Unit(name: "كيلوغرام", imagePath: "lib/assets/images/unit_icons/kilo_icon.png", withDescription: false, description: ""),
  Unit(name: "لتر", imagePath: "lib/assets/images/unit_icons/liter_icon.png",withDescription: false, description: ""),
  Unit(name: "صندوق", imagePath: "lib/assets/images/unit_icons/box_icon.png",withDescription: true, description: ""),
  Unit(name: "كيس", imagePath: "lib/assets/images/unit_icons/bag_icon.png",withDescription: true, description: ""),
];
 
const List<PaymentMean> paymentMeans = [
  PaymentMean(id: '1', name: "الدفع عند الاستلام", value: "cash",  description: ""),
  PaymentMean(id: '2', name: "بطاقة بنكية",  value: "card",  description: ""),
];


const List<DeliveryMean> deliveryMeans = [
  DeliveryMean(id: '1', name: "استلام من المزرعة", value: "pickup" ,  description: ""),
  DeliveryMean(id: '2', name: "خدمة توصيل", value: "courier", description: ""),
];