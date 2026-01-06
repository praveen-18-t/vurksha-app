import 'package:flutter/material.dart';

enum NotificationCategory {
  orderUpdates,
  promotionalOffers,
  accountAlerts,
  paymentNotifications,
  deliveryUpdates,
  other,
}

enum NotificationType {
  // Order Updates
  orderConfirmation,
  orderShipped,
  outForDelivery,
  orderDelivered,
  orderCancelled,
  
  // Promotional Offers
  discountsAndDeals,
  specialOffers,
  flashSales,
  limitedTimeOffers,
  
  // Account Alerts
  profileUpdates,
  passwordChanges,
  securityAlerts,
  accountVerification,
  
  // Payment Notifications
  paymentSuccess,
  paymentFailure,
  refundStatus,
  walletTransactions,
  
  // Delivery Updates
  deliveryPersonDetails,
  deliveryTimeChanges,
  failedDeliveryAttempts,
  deliveryInstructionsUpdate,
  
  // Other
  general,
}

class NotificationModel {
  final String id;
  final NotificationCategory category;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data; // For deep linking and other metadata

  NotificationModel({
    required this.id,
    required this.category,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.data,
  });

  NotificationModel copyWith({
    String? id,
    NotificationCategory? category,
    NotificationType? type,
    String? title,
    String? body,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      category: category ?? this.category,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }

  IconData get icon {
    switch (category) {
      case NotificationCategory.orderUpdates:
        return Icons.shopping_bag_outlined;
      case NotificationCategory.promotionalOffers:
        return Icons.local_offer_outlined;
      case NotificationCategory.accountAlerts:
        return Icons.person_outline;
      case NotificationCategory.paymentNotifications:
        return Icons.payment_outlined;
      case NotificationCategory.deliveryUpdates:
        return Icons.local_shipping_outlined;
      case NotificationCategory.other:
        return Icons.notifications_outlined;
    }
  }

  Color get iconColor {
    switch (category) {
      case NotificationCategory.orderUpdates:
        return Colors.blue;
      case NotificationCategory.promotionalOffers:
        return Colors.green;
      case NotificationCategory.accountAlerts:
        return Colors.orange;
      case NotificationCategory.paymentNotifications:
        return Colors.purple;
      case NotificationCategory.deliveryUpdates:
        return Colors.teal;
      case NotificationCategory.other:
        return Colors.grey;
    }
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      category: NotificationCategory.values[json['category'] as int],
      type: NotificationType.values[json['type'] as int],
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.index,
      'type': type.index,
      'title': title,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'data': data,
    };
  }
}

class NotificationSettings {
  bool pushNotificationsEnabled;
  bool emailNotificationsEnabled;
  bool smsNotificationsEnabled;
  bool soundEnabled;
  bool vibrationEnabled;
  TimeOfDay? quietHoursStart;
  TimeOfDay? quietHoursEnd;
  Map<NotificationCategory, bool> categorySettings;

  NotificationSettings({
    this.pushNotificationsEnabled = true,
    this.emailNotificationsEnabled = true,
    this.smsNotificationsEnabled = false,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.quietHoursStart,
    this.quietHoursEnd,
    Map<NotificationCategory, bool>? categorySettings,
  }) : categorySettings = categorySettings ??
            {
              for (var category in NotificationCategory.values)
                if (category != NotificationCategory.other)
                  category: true,
            };

  NotificationSettings copyWith({
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? smsNotificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
    Map<NotificationCategory, bool>? categorySettings,
  }) {
    return NotificationSettings(
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      smsNotificationsEnabled: smsNotificationsEnabled ?? this.smsNotificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      categorySettings: categorySettings ?? this.categorySettings,
    );
  }
}
