import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared/services/firebase_core.dart';
import 'package:shared/theme/app_colors.dart';
import 'features/bulk_order/kitchen_dashboard_screen.dart';
import 'features/auth/merchant_login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseCoreService.initialize();
  runApp(const GomDonMerchantApp());
}

class GomDonMerchantApp extends StatelessWidget {
  const GomDonMerchantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GomĐơn - Quán ăn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          surface: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const MerchantLoginScreen(),
        '/home':  (context) => const MerchantHomeScreen(),
      },
    );
  }
}

class MerchantHomeScreen extends StatelessWidget {
  const MerchantHomeScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  String get _merchantEmail =>
      FirebaseAuth.instance.currentUser?.email ?? 'merchant@gomdon.vn';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('GomĐơn - Quán ăn',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.roleMerchant,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Đăng xuất',
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: AppColors.roleMerchant.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.roleMerchant.withOpacity(0.3), width: 2),
              ),
              child: const Icon(Icons.restaurant_menu_rounded,
                  size: 54, color: AppColors.roleMerchant),
            ),
            const SizedBox(height: 16),

            // Email tài khoản
            Text(_merchantEmail,
              style: const TextStyle(
                fontSize: 14, color: AppColors.textSecondary,
                fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            const Text('Chờ đến 10:00 để nhận đơn tổng',
              style: TextStyle(color: AppColors.textHint, fontSize: 13)),

            const SizedBox(height: 28),

            // Nút vào bếp
            ElevatedButton.icon(
              onPressed: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => const KitchenDashboardScreen())),
              icon: const Icon(Icons.soup_kitchen_rounded),
              label: const Text('Xem đơn tổng bếp',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.roleMerchant,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
