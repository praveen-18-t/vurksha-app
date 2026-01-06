enum PaymentType {
  creditCard,
  debitCard,
  upi,
  netBanking,
  wallet,
  cod,
}

enum CardType {
  visa,
  mastercard,
  amex,
  rupay,
  discover,
  maestro,
  unknown,
}

enum WalletType {
  paytm,
  phonepe,
  googlePay,
  amazonPay,
  mobikwik,
  airtelMoney,
  freecharge,
  other,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  refunded,
  cancelled,
}

class PaymentMethod {
  final String id;
  final PaymentType type;
  final String? cardNumber;
  final String? cardHolderName;
  final String? expiryDate;
  final String? cvv;
  final CardType? cardType;
  final String? upiId;
  final String? bankName;
  final WalletType? walletType;
  final String? walletNumber;
  final bool isDefault;
  final bool isSaved;
  final String? token;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastUsed;

  PaymentMethod({
    required this.id,
    required this.type,
    this.cardNumber,
    this.cardHolderName,
    this.expiryDate,
    this.cvv,
    this.cardType,
    this.upiId,
    this.bankName,
    this.walletType,
    this.walletNumber,
    this.isDefault = false,
    this.isSaved = false,
    this.token,
    required this.createdAt,
    required this.updatedAt,
    this.lastUsed,
  });

  PaymentMethod copyWith({
    String? id,
    PaymentType? type,
    String? cardNumber,
    String? cardHolderName,
    String? expiryDate,
    String? cvv,
    CardType? cardType,
    String? upiId,
    String? bankName,
    WalletType? walletType,
    String? walletNumber,
    bool? isDefault,
    bool? isSaved,
    String? token,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastUsed,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      expiryDate: expiryDate ?? this.expiryDate,
      cvv: cvv ?? this.cvv,
      cardType: cardType ?? this.cardType,
      upiId: upiId ?? this.upiId,
      bankName: bankName ?? this.bankName,
      walletType: walletType ?? this.walletType,
      walletNumber: walletNumber ?? this.walletNumber,
      isDefault: isDefault ?? this.isDefault,
      isSaved: isSaved ?? this.isSaved,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  String get displayName {
    switch (type) {
      case PaymentType.creditCard:
      case PaymentType.debitCard:
        if (cardNumber != null && cardNumber!.length >= 4) {
          return '${getCardTypeName(cardType!)} ****${cardNumber!.substring(cardNumber!.length - 4)}';
        }
        return 'Card';
      case PaymentType.upi:
        return upiId ?? 'UPI';
      case PaymentType.netBanking:
        return bankName ?? 'Net Banking';
      case PaymentType.wallet:
        return getWalletName(walletType!);
      case PaymentType.cod:
        return 'Cash on Delivery';
    }
  }

  String getPaymentTypeIcon() {
    switch (type) {
      case PaymentType.creditCard:
        return 'credit_card';
      case PaymentType.debitCard:
        return 'credit_card';
      case PaymentType.upi:
        return 'upi';
      case PaymentType.netBanking:
        return 'account_balance';
      case PaymentType.wallet:
        return 'wallet';
      case PaymentType.cod:
        return 'money';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'expiryDate': expiryDate,
      'cvv': cvv,
      'cardType': cardType?.name,
      'upiId': upiId,
      'bankName': bankName,
      'walletType': walletType?.name,
      'walletNumber': walletNumber,
      'isDefault': isDefault,
      'isSaved': isSaved,
      'token': token,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastUsed': lastUsed?.toIso8601String(),
    };
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String,
      type: PaymentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PaymentType.creditCard,
      ),
      cardNumber: json['cardNumber'] as String?,
      cardHolderName: json['cardHolderName'] as String?,
      expiryDate: json['expiryDate'] as String?,
      cvv: json['cvv'] as String?,
      cardType: json['cardType'] != null
          ? CardType.values.firstWhere(
              (e) => e.name == json['cardType'],
              orElse: () => CardType.unknown,
            )
          : null,
      upiId: json['upiId'] as String?,
      bankName: json['bankName'] as String?,
      walletType: json['walletType'] != null
          ? WalletType.values.firstWhere(
              (e) => e.name == json['walletType'],
              orElse: () => WalletType.other,
            )
          : null,
      walletNumber: json['walletNumber'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      isSaved: json['isSaved'] as bool? ?? false,
      token: json['token'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastUsed: json['lastUsed'] != null
          ? DateTime.parse(json['lastUsed'] as String)
          : null,
    );
  }

  static String getCardTypeName(CardType type) {
    switch (type) {
      case CardType.visa:
        return 'Visa';
      case CardType.mastercard:
        return 'Mastercard';
      case CardType.amex:
        return 'American Express';
      case CardType.rupay:
        return 'RuPay';
      case CardType.discover:
        return 'Discover';
      case CardType.maestro:
        return 'Maestro';
      case CardType.unknown:
        return 'Card';
    }
  }

  static String getWalletName(WalletType type) {
    switch (type) {
      case WalletType.paytm:
        return 'Paytm';
      case WalletType.phonepe:
        return 'PhonePe';
      case WalletType.googlePay:
        return 'Google Pay';
      case WalletType.amazonPay:
        return 'Amazon Pay';
      case WalletType.mobikwik:
        return 'MobiKwik';
      case WalletType.airtelMoney:
        return 'Airtel Money';
      case WalletType.freecharge:
        return 'Freecharge';
      case WalletType.other:
        return 'Wallet';
    }
  }
}

class Transaction {
  final String id;
  final String orderId;
  final PaymentMethod paymentMethod;
  final double amount;
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? failureReason;
  final String? receiptUrl;
  final String? transactionId;

  Transaction({
    required this.id,
    required this.orderId,
    required this.paymentMethod,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.failureReason,
    this.receiptUrl,
    this.transactionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'paymentMethod': paymentMethod.toJson(),
      'amount': amount,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'failureReason': failureReason,
      'receiptUrl': receiptUrl,
      'transactionId': transactionId,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      paymentMethod: PaymentMethod.fromJson(json['paymentMethod'] as Map<String, dynamic>),
      amount: (json['amount'] as num).toDouble(),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      failureReason: json['failureReason'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
      transactionId: json['transactionId'] as String?,
    );
  }
}

class PaymentValidationResult {
  final bool isValid;
  final String? errorMessage;
  final Map<String, String>? fieldErrors;

  PaymentValidationResult({
    required this.isValid,
    this.errorMessage,
    this.fieldErrors,
  });

  factory PaymentValidationResult.success() {
    return PaymentValidationResult(isValid: true);
  }

  factory PaymentValidationResult.error(String message, {Map<String, String>? fieldErrors}) {
    return PaymentValidationResult(
      isValid: false,
      errorMessage: message,
      fieldErrors: fieldErrors,
    );
  }
}
