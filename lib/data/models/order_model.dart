import '../models/order_model.dart';

class Order {
  final String id;
  final String orderNumber;
  final DateTime date;
  final String status;
  final double total;
  final String deliveryAddress;
  final DateTime? estimatedDelivery;
  final List<OrderItem> items;
  final double deliveryFee;
  final double subTotal;
  final PaymentDetails paymentDetails;

  Order({
    required this.id,
    required this.orderNumber,
    required this.date,
    required this.status,
    required this.total,
    required this.deliveryAddress,
    this.estimatedDelivery,
    required this.items,
    required this.deliveryFee,
    required this.subTotal,
    required this.paymentDetails,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      date: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String,
      total: (json['total'] as num).toDouble(),
      deliveryAddress: json['deliveryAddress'] is String
          ? json['deliveryAddress']
          : 'Address details',
      estimatedDelivery: json['scheduledDeliveryDate'] != null
          ? DateTime.parse(json['scheduledDeliveryDate'] as String)
          : null,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      subTotal: (json['subtotal'] as num).toDouble(),
      paymentDetails: PaymentDetails(
        paymentMethod: json['paymentMethod'] as String? ?? 'COD',
        transactionId: '',
      ),
    );
  }
}

class OrderItem {
  final String name;
  final int quantity;
  final String weight;
  final double price;
  final String imageUrl;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.weight,
    required this.price,
    required this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['productName'] as String,
      quantity: json['quantity'] as int,
      weight: json['unit'] as String? ?? 'kg',
      price: (json['unitPrice'] as num).toDouble(),
      imageUrl: json['productImage'] as String? ?? '',
    );
  }
}

class PaymentDetails {
  final String paymentMethod;
  final String transactionId;

  PaymentDetails({required this.paymentMethod, required this.transactionId});
}
