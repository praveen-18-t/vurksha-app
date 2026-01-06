import 'package:flutter/material.dart';

enum NotificationBadgeType { dot, count, auto }

enum NotificationType {
  ORDER_UPDATE,
  PAYMENT_CONFIRMATION,
  DELIVERY_UPDATE,
  PROMOTIONAL,
  SYSTEM,
}

// Mapping for compatibility if needed, or just use NotificationType
typedef AppNotificationType = NotificationType;

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String? imageUrl;
  final String? actionType;
  final Map<String, dynamic>? actionData;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.imageUrl,
    this.actionType,
    this.actionData,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      type: _parseType(json['type'] as String),
      title: json['title'] as String,
      body: json['body'] as String,
      imageUrl: json['imageUrl'] as String?,
      actionType: json['actionType'] as String?,
      actionData: json['actionData'] as Map<String, dynamic>?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static NotificationType _parseType(String type) {
    return NotificationType.values.firstWhere(
      (e) => e.toString().split('.').last == type,
      orElse: () => NotificationType.SYSTEM,
    );
  }

  AppNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    String? imageUrl,
    String? actionType,
    Map<String, dynamic>? actionData,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      actionType: actionType ?? this.actionType,
      actionData: actionData ?? this.actionData,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  IconData get icon {
    switch (type) {
      case NotificationType.ORDER_UPDATE:
        return Icons.shopping_bag_outlined;
      case NotificationType.PROMOTIONAL:
        return Icons.local_offer_outlined;
      case NotificationType.SYSTEM:
        return Icons.notifications_outlined;
      case NotificationType.PAYMENT_CONFIRMATION:
        return Icons.payment_outlined;
      case NotificationType.DELIVERY_UPDATE:
        return Icons.local_shipping_outlined;
    }
  }
}
