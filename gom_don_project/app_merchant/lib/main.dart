import 'package:flutter/material.dart';
import 'package:shared/services/firebase_core.dart';

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
          seedColor: const Color(0xFF27AE60),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const _MerchantHome(),
    );
  }
}

class _MerchantHome extends StatelessWidget {
  const _MerchantHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GomĐơn - Quán ăn'),
        backgroundColor: const Color(0xFF27AE60), foregroundColor: Colors.white),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.restaurant_menu, size: 80, color: Color(0xFF27AE60)),
          const SizedBox(height: 16),
          const Text('Chờ đến 10:00 để nhận đơn tổng',
            style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const _KitchenPlaceholder())),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27AE60), foregroundColor: Colors.white),
            child: const Text('Xem đơn tổng bếp'),
          ),
        ]),
      ),
    );
  }
}

class _KitchenPlaceholder extends StatelessWidget {
  const _KitchenPlaceholder();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Đơn tổng bếp')),
    body: const Center(child: Text('→ Xem kitchen_dashboard_screen.dart')),
  );
}
