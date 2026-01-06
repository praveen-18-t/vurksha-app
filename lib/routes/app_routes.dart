import 'package:flutter/material.dart';
import '../presentation/product_details_screen/product_details_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/shopping_cart_screen/shopping_cart_screen.dart';
import '../presentation/phone_authentication_screen/phone_authentication_screen.dart';
import '../presentation/home_screen/home_screen.dart';
import '../presentation/category_listing_screen/category_listing_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/profile_screen/profile_screen.dart';
import '../presentation/order_history_screen/order_history_screen.dart';
import '../presentation/order_details_screen/order_details_screen.dart';
import '../presentation/notification_screen/notification_screen.dart';
import '../presentation/admin_panel/admin_panel_screen.dart';
import '../presentation/delivery_address_screen/delivery_address_screen.dart';
import '../presentation/user_details_screen/user_details_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String productDetails = '/product-details-screen';
  static const String splash = '/splash-screen';
  static const String shoppingCart = '/shopping-cart-screen';
  static const String phoneAuthentication = '/phone-authentication-screen';
  static const String home = '/home-screen';
  static const String categoryListing = '/category-listing-screen';
  static const String profile = '/profile-screen';
  static const String settings = '/settings-screen';
  static const String orderHistory = '/order-history-screen';
  static const String orderDetails = '/order-details-screen';
  static const String notifications = '/notifications-screen';
  static const String adminPanel = '/admin-panel-screen';
  static const String deliveryAddresses = '/delivery-address-screen';
  static const String selectDeliveryAddress = '/select-delivery-address-screen';
  static const String userDetails = '/user-details-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    productDetails: (context) => const ProductDetailsScreen(),
    splash: (context) => const SplashScreen(),
    shoppingCart: (context) => const ShoppingCartScreen(),
    phoneAuthentication: (context) => const PhoneAuthenticationScreen(),
    home: (context) => const HomeScreen(),
    categoryListing: (context) => const CategoryListingScreen(),
    profile: (context) => const ProfileScreen(),
    settings: (context) => const SettingsScreen(),
    orderHistory: (context) => const OrderHistoryScreen(),
    orderDetails: (context) => const OrderDetailsScreen(),
    notifications: (context) => const NotificationScreen(),
    adminPanel: (context) => const AdminPanelScreen(),
    deliveryAddresses: (context) => const DeliveryAddressScreen(),
    selectDeliveryAddress: (context) => const DeliveryAddressScreen(selectionMode: true),
    userDetails: (context) => const UserDetailsScreen(),
  };
}
