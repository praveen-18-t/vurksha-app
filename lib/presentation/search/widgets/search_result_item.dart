import 'package:flutter/material.dart';
import 'package:vurksha_farm_delivery/widgets/custom_image_widget.dart';

class SearchResultItem extends StatelessWidget {
  const SearchResultItem({
    super.key,
    required this.product,
    required this.onTap,
  });

  final Map<String, dynamic> product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CustomImageWidget(
        imageUrl: product['image'] as String,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      ),
      title: Text(product['name'] as String),
      subtitle: Text(product['price'] as String),
      onTap: onTap,
    );
  }
}
