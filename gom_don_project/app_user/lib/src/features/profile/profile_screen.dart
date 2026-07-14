import 'package:flutter/material.dart';
import 'package:shared/models/user_model.dart';
import 'profile_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_routes.dart';
import '../../core/utils/time_helper.dart';

/// Màn hình Hồ sơ người dùng
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _controller = ProfileController();
  String? _tenHub;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _loadHubName();
  }

  Future<void> _loadHubName() async {
    final name = await _controller.layTenHubDaChon();
    setState(() => _tenHub = name);
  }

  Future<void> _handleKetNoiVi() async {
    setState(() => _isConnecting = true);
    final success = await _controller.ketNoiVi();
    setState(() => _isConnecting = false);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Kết nối ví thành công! Số dư: 500.000đ (Mock)'),
          backgroundColor: AppColors.success,
        ),
      );
      setState(() {}); // rebuild để cập nhật số dư
    }
  }

  Future<void> _handleNgKetNoi() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ngắt kết nối ví?'),
        content: const Text('Bạn sẽ không thể đặt hàng khi ngắt kết nối.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ngắt', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _controller.ngKetNoiVi();
      if (mounted) setState(() {});
    }
  }

  Future<void> _handleDangXuat() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Đăng xuất?'),
        content: const Text('Bạn có chắc muốn đăng xuất khỏi GomĐơn?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng xuất', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await _controller.dangXuat();
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
    }
  }

  Future<void> _doiHub() async {
    await _controller.xoaHubDaChon();
    if (mounted) {
      Navigator.pushNamed(context, AppRoutes.locationHub);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _controller.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: user == null
          ? _buildNotLoggedIn()
          : CustomScrollView(
              slivers: [
                // Header gradient
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  automaticallyImplyLeading: false,
                  backgroundColor: AppColors.primary,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildProfileHeader(user),
                  ),
                  title: const Text('Hồ sơ của tôi',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      const SizedBox(height: 8),

                      // Thông tin ví
                      _buildSection('💳 Ví thanh toán', [
                        _buildWalletCard(user),
                      ]),
                      const SizedBox(height: 14),

                      // Thông tin Hub
                      _buildSection('📍 Điểm nhận hàng', [
                        Row(children: [
                          const Icon(Icons.business, color: AppColors.accent, size: 20),
                          const SizedBox(width: 10),
                          Expanded(child: Text(
                            _tenHub ?? 'Chưa chọn Hub',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _tenHub != null ? AppColors.textPrimary : AppColors.textHint,
                            ),
                          )),
                          TextButton.icon(
                            onPressed: _doiHub,
                            icon: const Icon(Icons.swap_horiz, size: 16),
                            label: const Text('Đổi'),
                            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                          ),
                        ]),
                      ]),
                      const SizedBox(height: 14),

                      // Thông tin tài khoản
                      _buildSection('👤 Thông tin tài khoản', [
                        _infoRow(Icons.person, 'Họ tên', user.tenKhachHang),
                        const SizedBox(height: 10),
                        _infoRow(Icons.phone, 'Số điện thoại', user.soDienThoai),
                        const SizedBox(height: 10),
                        _infoRow(Icons.badge, 'Mã khách hàng', user.maKhachHang),
                      ]),
                      const SizedBox(height: 14),

                      // Hỗ trợ
                      _buildSection('ℹ️ Hỗ trợ & Thông tin', [
                        _menuItem(Icons.help_outline, 'Trung tâm hỗ trợ', () {}),
                        const Divider(height: 8),
                        _menuItem(Icons.policy_outlined, 'Chính sách & Điều khoản', () {}),
                        const Divider(height: 8),
                        _menuItem(Icons.info_outline, 'Phiên bản ứng dụng',
                            () {}, trailing: const Text('1.0.0', style: TextStyle(color: AppColors.textHint))),
                      ]),
                      const SizedBox(height: 24),

                      // Nút đăng xuất
                      SizedBox(
                        width: double.infinity, height: 50,
                        child: OutlinedButton.icon(
                          onPressed: _handleDangXuat,
                          icon: const Icon(Icons.logout, color: AppColors.error),
                          label: const Text('Đăng xuất',
                              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const SizedBox(height: 40),
        CircleAvatar(
          radius: 42,
          backgroundColor: Colors.white.withOpacity(0.2),
          child: Text(
            user.tenKhachHang.isNotEmpty ? user.tenKhachHang[0].toUpperCase() : '?',
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        Text(user.tenKhachHang,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(user.soDienThoai,
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
      ]),
    );
  }

  Widget _buildWalletCard(UserModel user) {
    final isConnected = user.trangThaiVi == 'connected';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isConnected
              ? [const Color(0xFF11998e), const Color(0xFF38ef7d)]
              : [AppColors.textHint, AppColors.textSecondary],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(
              isConnected ? Icons.account_balance_wallet : Icons.account_balance_wallet_outlined,
              color: Colors.white, size: 20,
            ),
            const SizedBox(width: 6),
            Text(isConnected ? 'Ví đã kết nối' : 'Ví chưa kết nối',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 8),
          if (isConnected) ...[
            Text(TimeHelper.formatVND(user.soDuVi.toInt()),
                style: const TextStyle(color: Colors.white,
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const Text('Số dư khả dụng',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
          ] else
            const Text('Kết nối ví để đặt hàng',
                style: TextStyle(color: Colors.white70)),
        ])),

        // Nút hành động
        if (_isConnecting)
          const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
        else if (!isConnected)
          ElevatedButton(
            onPressed: _handleKetNoiVi,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.success,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: const Text('Kết nối', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        else
          TextButton(
            onPressed: _handleNgKetNoi,
            child: const Text('Ngắt kết nối', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ),
      ]),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
            blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold,
            fontSize: 14, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, size: 18, color: AppColors.textSecondary),
      const SizedBox(width: 10),
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      const Spacer(),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600,
          color: AppColors.textPrimary, fontSize: 13)),
    ]);
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap, {Widget? trailing}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(child: Text(label,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14))),
          trailing ?? const Icon(Icons.chevron_right, color: AppColors.textHint),
        ]),
      ),
    );
  }

  Widget _buildNotLoggedIn() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.person_off, size: 80, color: AppColors.textHint),
      const SizedBox(height: 16),
      const Text('Chưa đăng nhập', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
      const SizedBox(height: 24),
      ElevatedButton(
        onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, foregroundColor: Colors.white),
        child: const Text('Đăng nhập'),
      ),
    ]));
  }
}
