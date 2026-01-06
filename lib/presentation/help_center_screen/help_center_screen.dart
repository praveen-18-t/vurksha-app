import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
      ),
      body: ListView(
        children: const [
          ExpansionTile(
            title: Text('How do I track my order?'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                    'You can track your order from the "My Orders" section. Once your order is shipped, you will receive a tracking link via email and SMS.'),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('What are the delivery charges?'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                    'Delivery charges vary based on your location and order value. You can see the final delivery charge at checkout.'),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('How do I return an item?'),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                    'You can initiate a return from the "My Orders" section within 7 days of delivery. Please refer to our return policy for more details.'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
