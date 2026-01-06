/// Cart item model for shopping cart functionality
class CartItem {
  final String id;
  final String name;
  final String description;
  final double pricePerUnit;
  int quantity;
  final String unit;
  final String imageUrl;
  final int stockAvailable;
  final List<String> tags;
  final DateTime addedAt;

  CartItem({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerUnit,
    required this.quantity,
    required this.unit,
    required this.imageUrl,
    required this.stockAvailable,
    this.tags = const [],
    required this.addedAt,
  });

  CartItem copyWith({
    String? id,
    String? name,
    String? description,
    double? pricePerUnit,
    int? quantity,
    String? unit,
    String? imageUrl,
    int? stockAvailable,
    List<String>? tags,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      imageUrl: imageUrl ?? this.imageUrl,
      stockAvailable: stockAvailable ?? this.stockAvailable,
      tags: tags ?? this.tags,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  /// Calculate total price for this cart item
  double get totalPrice => pricePerUnit * quantity;

  /// Check if item is in stock
  bool get isInStock => stockAvailable > 0;

  /// Check if quantity exceeds available stock
  bool get isOverStock => quantity > stockAvailable;

  // fromJson constructor to create a CartItem from a map
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      quantity: json['quantity'] as int,
      unit: json['unit'] as String,
      imageUrl: json['imageUrl'] as String,
      stockAvailable: json['stockAvailable'] as int,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      addedAt: json['addedAt'] != null 
          ? DateTime.parse(json['addedAt'] as String)
          : DateTime.now(),
    );
  }

  // toJson method to convert CartItem to a map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pricePerUnit': pricePerUnit,
      'quantity': quantity,
      'unit': unit,
      'imageUrl': imageUrl,
      'stockAvailable': stockAvailable,
      'tags': tags,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CartItem{id: $id, name: $name, quantity: $quantity, pricePerUnit: $pricePerUnit}';
  }
}
