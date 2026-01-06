import 'package:flutter/material.dart' hide SearchBar;
import 'package:vurksha_farm_delivery/presentation/search/widgets/search_bar.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: const Column(
        children: [
          SearchBar(),
          // Expanded(child: Center(child: Text('Search Results'))),
        ],
      ),
    );
  }
}
