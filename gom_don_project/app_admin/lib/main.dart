import 'package:flutter/material.dart';
import 'package:shared/services/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseCoreService.initialize();
  runApp(const GomDonAdminApp());
}

class GomDonAdminApp extends StatelessWidget {
  const GomDonAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GomĐơn - Quản trị',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8E44AD),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const _AdminHome(),
    );
  }
}

class _AdminHome extends StatelessWidget {
  const _AdminHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FA),
      appBar: AppBar(title: const Text('GomĐơn - Quản trị viên'),
        backgroundColor: const Color(0xFF8E44AD), foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.admin_panel_settings, size: 80, color: Color(0xFF8E44AD)),
            const SizedBox(height: 8),
            const Text('Bảng điều khiển Quản trị', textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            _buildMenuButton(context, '🗺️ Quản lý Hub', '/hub-management', Icons.location_city),
            const SizedBox(height: 12),
            _buildMenuButton(context, '📊 Đối soát tài chính', '/reconciliation', Icons.assessment),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String label, String route, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.pushNamed(context, route),
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8E44AD),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
