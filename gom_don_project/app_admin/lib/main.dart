import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared/services/firebase_core.dart';
import 'package:shared/theme/app_colors.dart';
import 'firebase_options.dart';
import 'features/mock_data_seeder.dart';
import 'features/hub_management/hub_management_screen.dart';
import 'features/financial_reconciliation/reconciliation_screen.dart';
import 'features/auth/admin_login_screen.dart';
import 'features/auth/seed_auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseCoreService.initialize(
      options: DefaultFirebaseOptions.currentPlatform);
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
          seedColor: AppColors.roleAdmin,
          brightness: Brightness.light,
          surface: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const AdminLoginScreen(),
        '/home':  (context) => const AdminHomeScreen(),
        '/hub-management': (context) => const HubManagementScreen(),
        '/reconciliation': (context) => const ReconciliationScreen(),
      },
    );
  }
}

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  bool _isSeeding     = false;
  bool _isSeedingAuth = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ── Đăng xuất ───────────────────────────────────────────
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  // ── Nạp data kiểm thử ───────────────────────────────────
  Future<void> _seedData() async {
    setState(() => _isSeeding = true);
    try {
      await MockDataSeeder.seedAllData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              '✅ Nạp dữ liệu kiểm thử thành công!\n'
              '→ Mở app Tài xế / Merchant để test các chức năng.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lỗi nạp dữ liệu: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isSeeding = false);
    }
  }

  // ── Tạo tài khoản hệ thống ──────────────────────────────
  Future<void> _seedAuthAccounts() async {
    setState(() => _isSeedingAuth = true);
    try {
      final results = await SeedAuthService.seedAllAccounts();
      if (!mounted) return;

      final success = results.where((r) => r.$2).length;
      final fail    = results.where((r) => !r.$2).length;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Row(children: [
            Icon(Icons.group_add, color: AppColors.roleAdmin),
            SizedBox(width: 8),
            Text('Kết quả tạo tài khoản'),
          ]),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: results.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final r = results[i];
                return ListTile(
                  dense: true,
                  leading: Icon(
                    r.$2 ? Icons.check_circle : Icons.error,
                    color: r.$2 ? AppColors.success : AppColors.error,
                    size: 18,
                  ),
                  title: Text(r.$1,
                      style: const TextStyle(fontSize: 12)),
                  subtitle: Text(r.$3,
                      style: TextStyle(
                        fontSize: 11,
                        color: r.$2
                            ? AppColors.success
                            : AppColors.error,
                      )),
                );
              },
            ),
          ),
          actions: [
            Text('✅ $success thành công  ❌ $fail lỗi',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lỗi tạo tài khoản: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isSeedingAuth = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            // ── App Bar ───────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.roleAdmin,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  tooltip: 'Đăng xuất',
                  onPressed: _signOut,
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('GomĐơn Admin',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.roleAdminDark,
                        AppColors.roleAdmin,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        Container(
                          width: 70, height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings_rounded,
                            size: 40, color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Bảng Điều Khiển Quản Trị',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Nội dung ─────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Firebase status
                  _buildStatusBanner(),
                  const SizedBox(height: 20),

                  // Section: Chức năng chính
                  const Text('⚙️ Chức năng quản lý',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textDark)),
                  const SizedBox(height: 12),

                  _buildFeatureCard(
                    context,
                    icon: Icons.location_city_rounded,
                    title: '🗺️ Quản lý Hub cố định',
                    description:
                        'Thêm / Xóa / Bật-Tắt cụm điểm giao hàng (Hub). '
                        'Mỗi Hub là tòa nhà nơi khách tập trung nhận đồ.',
                    color: AppColors.roleAdmin,
                    onTap: () =>
                        Navigator.pushNamed(context, '/hub-management'),
                    badge: 'Firestore',
                  ),
                  const SizedBox(height: 12),

                  _buildFeatureCard(
                    context,
                    icon: Icons.bar_chart_rounded,
                    title: '📊 Đối soát Tài chính',
                    description:
                        'Xem lịch sử toàn bộ đơn hàng, lọc theo ngày, '
                        'xuất báo cáo Excel (2 sheet: đơn hàng + tổng kết quán).',
                    color: AppColors.success,
                    onTap: () =>
                        Navigator.pushNamed(context, '/reconciliation'),
                    badge: 'Excel',
                  ),

                  const SizedBox(height: 28),

                  // Section: Công cụ dev
                  const Text('🔧 Công cụ kiểm thử (DEV)',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textDark)),
                  const SizedBox(height: 12),

                  // Tạo tài khoản hệ thống
                  _buildSeedAuthCard(),
                  const SizedBox(height: 12),

                  _buildDevToolCard(),

                  const SizedBox(height: 20),

                  // Hướng dẫn test
                  _buildTestGuide(),

                  const SizedBox(height: 30),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    final isFirebase = FirebaseCoreService.isInitialized;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isFirebase ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFirebase
              ? Colors.green.shade200
              : Colors.orange.shade200,
        ),
      ),
      child: Row(children: [
        Icon(
          isFirebase ? Icons.cloud_done : Icons.cloud_off,
          color: isFirebase ? AppColors.success : Colors.orange,
          size: 22,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isFirebase
                    ? '🟢 Kết nối Firebase thành công'
                    : '🟡 Chưa kết nối Firebase (Chế độ Mock)',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isFirebase
                        ? Colors.green.shade700
                        : Colors.orange.shade700),
              ),
              Text(
                isFirebase
                    ? 'Dữ liệu đọc/ghi trực tiếp lên Firestore.'
                    : 'Đặt google-services.json vào android/app/ để kết nối.',
                style: TextStyle(
                    fontSize: 11,
                    color: isFirebase
                        ? Colors.green.shade600
                        : Colors.orange.shade600),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildSeedAuthCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.group_add_rounded,
                color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            const Text('Tạo tài khoản hệ thống',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.primary)),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('1 LẦN',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(
            'Tạo 7 tài khoản Firebase Auth: 1 Admin, 3 Driver, 3 Merchant.\n'
            'Mật khẩu chung: 123456. Chỉ cần chạy 1 lần duy nhất.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: _isSeedingAuth ? null : _seedAuthAccounts,
              icon: _isSeedingAuth
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.person_add_rounded, size: 18),
              label: Text(
                _isSeedingAuth
                    ? 'Đang tạo tài khoản...'
                    : 'TẠO TÀI KHOẢN HỆ THỐNG',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 6, height: 90,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16)),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textDark)),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(badge,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: color,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ]),
                    const SizedBox(height: 4),
                    Text(description,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Icon(Icons.arrow_forward_ios, size: 14, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevToolCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.science, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            const Text('Nạp dữ liệu kiểm thử',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.red)),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('DEV ONLY',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(
            'Tạo 4 phòng + 4 đơn hàng mẫu lên Firestore để test toàn bộ luồng nghiệp vụ. '
            'Bao gồm: ROOM_001 (chờ nhận), ROOM_003 (DRIVER_TEST đã nhận).',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity, height: 44,
            child: ElevatedButton.icon(
              onPressed: _isSeeding ? null : _seedData,
              icon: _isSeeding
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.upload_file, size: 18),
              label: Text(
                _isSeeding ? 'Đang nạp dữ liệu...' : 'NẠP DATA KIỂM THỬ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestGuide() {
    const steps = [
      ('1', AppColors.roleAdmin,    'Admin nạp data',     'Nhấn "NẠP DATA KIỂM THỬ"'),
      ('2', AppColors.roleMerchant, 'Merchant xem bếp',   'App Merchant → Chọn quán → Xem đơn ROOM_001'),
      ('3', AppColors.primary,      'Driver nhận chuyến', 'App Driver → Nhận ROOM_001 (ROOM_002 đã bị lấy)'),
      ('4', AppColors.warning,      'Driver xác nhận giao', 'Chuyến ROOM_003 → PIN 9999 → Đã giao'),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.route, color: AppColors.roleAdmin, size: 18),
            SizedBox(width: 8),
            Text('Luồng kiểm thử nhanh:',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ]),
          const SizedBox(height: 12),
          ...steps.map((step) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        color: step.$2, shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(step.$1,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(step.$3,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                          Text(step.$4,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
