import 'package:flutter/material.dart';

enum PaymentMethodType { card, upi, netbanking, cod }

class PaymentMethod {
  final String id;
  final PaymentMethodType type;
  final String name;
  final IconData icon;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.name,
    required this.icon,
  });
}
