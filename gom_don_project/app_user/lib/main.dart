import 'package:flutter/material.dart';
import 'package:shared/services/firebase_core.dart';
import 'src/core/app_routes.dart';
import 'src/core/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseCoreService.initialize();
  runApp(const GomDonUserApp());
}

class GomDonUserApp extends StatelessWidget {
  const GomDonUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GomĐơn - Đặt hàng theo cụm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
