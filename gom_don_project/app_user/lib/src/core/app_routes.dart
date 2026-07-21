import 'package:flutter/material.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/location_hub/location_hub_screen.dart';
import '../features/search_food/merchant_detail_screen.dart';
import '../features/room_group/cart_screen.dart';
import '../features/room_group/room_detail_screen.dart';
import '../features/checkout/payment_screen.dart';
import '../features/order_history/order_history_screen.dart';
import '../features/profile/profile_screen.dart';
import 'home_wrapper.dart';

/// Định nghĩa tất cả các route điều hướng trong App User
class AppRoutes {
  AppRoutes._();

  // ── Tên các route ──────────────────────────────────────────
  static const String login          = '/';
  static const String register       = '/register';
  static const String locationHub    = '/location-hub';
  static const String home           = '/home';
  static const String searchFood     = '/search-food';
  static const String merchantDetail = '/merchant-detail';
  static const String cart           = '/cart';
  static const String roomDetail     = '/room-detail';
  static const String payment        = '/payment';
  static const String orderHistory   = '/order-history';
  static const String profile        = '/profile';

  // ── Map routes cho MaterialApp ─────────────────────────────
  static Map<String, WidgetBuilder> get routes => {
    login:          (_) => const LoginScreen(),
    register:       (_) => const RegisterScreen(),
    locationHub:    (_) => const LocationHubScreen(),
    home:           (_) => const HomeWrapper(),
    merchantDetail: (ctx) => MerchantDetailScreen(
          merchant: ModalRoute.of(ctx)!.settings.arguments as dynamic,
        ),
    cart:           (_) => const CartScreen(),
    roomDetail:     (_) => const RoomDetailScreen(),
    payment:        (_) => const PaymentScreen(),
    orderHistory:   (_) => const OrderHistoryScreen(),
    profile:        (_) => const ProfileScreen(),
  };
}
