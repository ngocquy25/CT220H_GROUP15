import 'package:flutter/material.dart';
import '../features/auth/login_screen.dart';
import '../features/location_hub/location_hub_screen.dart';
import '../features/search_food/search_food_screen.dart';
import '../features/room_group/room_detail_screen.dart';
import '../features/checkout/payment_screen.dart';

/// Định nghĩa tất cả các route điều hướng trong App User
class AppRoutes {
  AppRoutes._();

  // ── Tên các route ─────────────────────────────────────────
  static const String login = '/';
  static const String locationHub = '/location-hub';
  static const String searchFood = '/search-food';
  static const String roomDetail = '/room-detail';
  static const String payment = '/payment';

  // ── Map routes cho MaterialApp ────────────────────────────
  static Map<String, WidgetBuilder> get routes => {
    login: (_) => const LoginScreen(),
    locationHub: (_) => const LocationHubScreen(),
    searchFood: (_) => const SearchFoodScreen(),
    roomDetail: (_) => const RoomDetailScreen(),
    payment: (_) => const PaymentScreen(),
  };
}
