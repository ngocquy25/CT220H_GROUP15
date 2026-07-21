import 'package:flutter/material.dart';
import 'package:shared/services/firebase_core.dart';
import 'firebase_options.dart';
import 'src/core/app_routes.dart';
import 'src/core/app_colors.dart';
import 'src/core/app_text_styles.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseCoreService.initialize(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
          surface: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        // Be Vietnam Pro — font hỗ trợ tiếng Việt đầy đủ (thay Roboto chưa khai báo)
        textTheme: AppTextStyles.textTheme,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
