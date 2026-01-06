class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String unit;
  final String image;
  final int stock;
  final bool isActive;
  final bool isOrganic;
  final double rating;
  final int reviewCount;
  final String farmSource;
  final List<String> tags;
  final double? discountPercentage;

  Product({
    required this.id,
    required this.name,
    this.description = '',
    required this.category,
    required this.price,
    this.unit = 'kg',
    this.image = '',
    required this.stock,
    this.isActive = true,
    this.isOrganic = false,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.farmSource = '',
    this.tags = const [],
    this.discountPercentage,
  });

  // Get discounted price if applicable
  double get effectivePrice {
    if (discountPercentage != null && discountPercentage! > 0) {
      return price * (1 - discountPercentage! / 100);
    }
    return price;
  }

  // Check if product is in stock
  bool get isInStock => stock > 0;

  // Check if product has discount
  bool get hasDiscount => discountPercentage != null && discountPercentage! > 0;

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? price,
    String? unit,
    String? image,
    int? stock,
    bool? isActive,
    bool? isOrganic,
    double? rating,
    int? reviewCount,
    String? farmSource,
    List<String>? tags,
    double? discountPercentage,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      image: image ?? this.image,
      stock: stock ?? this.stock,
      isActive: isActive ?? this.isActive,
      isOrganic: isOrganic ?? this.isOrganic,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      farmSource: farmSource ?? this.farmSource,
      tags: tags ?? this.tags,
      discountPercentage: discountPercentage ?? this.discountPercentage,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      unit: json['unit'] as String? ?? 'kg',
      image: json['image'] as String? ?? '',
      stock: json['stock'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      isOrganic: json['isOrganic'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      farmSource: json['farmSource'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'unit': unit,
      'image': image,
      'stock': stock,
      'isActive': isActive,
      'isOrganic': isOrganic,
      'rating': rating,
      'reviewCount': reviewCount,
      'farmSource': farmSource,
      'tags': tags,
      'discountPercentage': discountPercentage,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'unit': unit,
      'image': image,
      'stock': stock,
      'isActive': isActive,
      'isOrganic': isOrganic,
      'rating': rating,
      'reviewCount': reviewCount,
      'farmSource': farmSource,
      'tags': tags,
      'discountPercentage': discountPercentage,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      price: map['price'] as double,
      unit: map['unit'] as String,
      image: map['image'] as String,
      stock: map['stock'] as int,
      isActive: map['isActive'] as bool,
      isOrganic: map['isOrganic'] as bool,
      rating: map['rating'] as double,
      reviewCount: map['reviewCount'] as int,
      farmSource: map['farmSource'] as String,
      tags: List<String>.from(map['tags'] as List),
      discountPercentage: map['discountPercentage'] as double?,
    );
  }
}
