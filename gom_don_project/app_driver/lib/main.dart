import 'package:flutter/material.dart';
import 'package:shared/services/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseCoreService.initialize();
  runApp(const GomDonDriverApp());
}

class GomDonDriverApp extends StatelessWidget {
  const GomDonDriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GomĐơn - Tài xế',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2980B9),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const _DriverHome(),
    );
  }
}

class _DriverHome extends StatelessWidget {
  const _DriverHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GomĐơn - Tài xế'),
        backgroundColor: const Color(0xFF2980B9), foregroundColor: Colors.white),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.delivery_dining, size: 80, color: Color(0xFF2980B9)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const _PoolingPlaceholder())),
            child: const Text('Danh sách chuyến xe'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const _DeliveryPlaceholder())),
            child: const Text('Xác nhận giao hàng'),
          ),
        ]),
      ),
    );
  }
}

class _PoolingPlaceholder extends StatelessWidget {
  const _PoolingPlaceholder();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Danh sách chuyến xe')),
    body: const Center(child: Text('→ Xem trip_pool_screen.dart')),
  );
}

class _DeliveryPlaceholder extends StatelessWidget {
  const _DeliveryPlaceholder();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Xác nhận giao hàng')),
    body: const Center(child: Text('→ Xem verification_screen.dart')),
  );
}
