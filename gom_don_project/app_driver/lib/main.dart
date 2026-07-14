import 'package:flutter/material.dart';
import 'package:shared/services/firebase_core.dart';
import 'firebase_options.dart';
import 'src/features/pooling/trip_pool_screen.dart';
import 'src/features/delivery/verification_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseCoreService.initialize(
      options: DefaultFirebaseOptions.currentPlatform);
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
      home: const DriverHomeScreen(),
    );
  }
}

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A5276),
              Color(0xFF2980B9),
              Color(0xFF5DADE2),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // ── Logo & Tên ──────────────────────────────
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.3), width: 2),
                      ),
                      child: const Icon(
                        Icons.delivery_dining_rounded,
                        size: 55,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'GomĐơn',
                      style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Kênh Tài Xế Gom Sỉ',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8)),
                    ),

                    const Spacer(flex: 1),

                    // ── Info badges ──────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildBadge(Icons.verified_user, 'ID: DRIVER_TEST'),
                        const SizedBox(width: 12),
                        _buildBadge(Icons.circle, '🟢 Trực tuyến',
                            color: Colors.green),
                      ],
                    ),

                    const Spacer(flex: 2),

                    // ── Nút chức năng ────────────────────────────
                    _buildMenuButton(
                      context,
                      icon: Icons.explore_rounded,
                      label: 'Xem danh sách chuyến',
                      subtitle: 'Nhận chuyến gom đang chờ sau 10:05',
                      color: Colors.white,
                      textColor: const Color(0xFF2980B9),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const TripPoolScreen()),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildMenuButton(
                      context,
                      icon: Icons.task_alt_rounded,
                      label: 'Chuyến của tôi',
                      subtitle: 'Xác nhận giao hàng bằng PIN hoặc QR',
                      color: Colors.white.withOpacity(0.15),
                      textColor: Colors.white,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const VerificationScreen()),
                      ),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.5), width: 1.5),
                    ),

                    const Spacer(flex: 2),

                    // ── Footer ───────────────────────────────────
                    Text(
                      'GomĐơn v1.0 • Cần Thơ',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label,
      {Color color = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
    BoxBorder? border,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          border: border,
          boxShadow: color == Colors.white
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ]
              : null,
        ),
        child: Row(children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: textColor, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: textColor),
        ]),
      ),
    );
  }
}
