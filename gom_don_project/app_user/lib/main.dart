import 'package:flutter/material.dart';
import 'src/core/app_routes.dart';
import 'src/core/app_colors.dart';
import 'src/core/app_text_styles.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Khởi tạo Firebase khi tích hợp thật:
  // await FirebaseCoreService.initialize();
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
          background: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        // Be Vietnam Pro — font hỗ trợ tiếng Việt đầy đủ (thay Roboto chưa khai báo)
        textTheme: AppTextStyles.textTheme,
        appBarTheme: const AppBarTheme(
          elevation: 0,start ms-settings:developers
          centerTitle: false,
        )
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        cardTheme: CardThemeData(
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
