import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared/theme/app_colors.dart';

/// Màn hình Đăng nhập — Admin
/// Màu chủ đạo: Tím hoàng gia (roleAdmin)
/// Tài khoản duy nhất: admin@gomdon.vn / 123456
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController(text: 'admin@gomdon.vn');
  final _passCtrl  = TextEditingController(text: '123456');
  bool _isLoading      = false;
  bool _obscurePass    = true;
  String? _errorMsg;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.25), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _errorMsg = 'Vui lòng nhập đầy đủ thông tin!');
      return;
    }
    setState(() { _isLoading = true; _errorMsg = null; });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, password: pass);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMsg = _mapAuthError(e.code));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':       return 'Tài khoản không tồn tại!';
      case 'wrong-password':       return 'Mật khẩu không đúng!';
      case 'invalid-credential':   return 'Email hoặc mật khẩu không đúng!';
      case 'invalid-email':        return 'Email không hợp lệ!';
      case 'user-disabled':        return 'Tài khoản đã bị vô hiệu hóa!';
      case 'too-many-requests':    return 'Quá nhiều lần thử. Vui lòng thử lại sau!';
      case 'network-request-failed': return 'Lỗi kết nối mạng!';
      default: return 'Đăng nhập thất bại ($code)';
    }
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
              Color(0xFF4A0080), // Tím đậm
              AppColors.roleAdmin,
              Color(0xFF9B59B6), // Tím nhạt
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // ── Logo ──────────────────────────────
                    Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.4), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 48, color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text('GomĐơn', style: TextStyle(
                      fontSize: 34, fontWeight: FontWeight.bold,
                      color: Colors.white, letterSpacing: 1.5,
                    )),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('QUẢN TRỊ VIÊN', style: TextStyle(
                        fontSize: 11, color: Colors.white,
                        fontWeight: FontWeight.bold, letterSpacing: 2,
                      )),
                    ),

                    const SizedBox(height: 48),

                    // ── Form Card ─────────────────────────
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 30, offset: const Offset(0, 12)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Đăng nhập', style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          )),
                          const SizedBox(height: 4),
                          Text('Chỉ dành cho quản trị viên hệ thống',
                            style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade500)),
                          const SizedBox(height: 24),

                          // Email
                          _buildTextField(
                            controller: _emailCtrl,
                            label: 'Email quản trị',
                            icon: Icons.alternate_email_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),

                          // Mật khẩu
                          _buildTextField(
                            controller: _passCtrl,
                            label: 'Mật khẩu',
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscurePass,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePass
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.roleAdmin,
                              ),
                              onPressed: () =>
                                  setState(() => _obscurePass = !_obscurePass),
                            ),
                          ),

                          // Error message
                          if (_errorMsg != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: AppColors.error.withOpacity(0.3)),
                              ),
                              child: Row(children: [
                                const Icon(Icons.error_outline,
                                    color: AppColors.error, size: 16),
                                const SizedBox(width: 8),
                                Expanded(child: Text(_errorMsg!,
                                  style: const TextStyle(
                                      color: AppColors.error, fontSize: 13))),
                              ]),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Nút đăng nhập
                          SizedBox(
                            width: double.infinity, height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.roleAdmin,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                elevation: 4,
                                shadowColor:
                                    AppColors.roleAdmin.withOpacity(0.4),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22, height: 22,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : const Text('ĐĂNG NHẬP', style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quick-fill hint
                    GestureDetector(
                      onTap: () {
                        _emailCtrl.text = 'admin@gomdon.vn';
                        _passCtrl.text  = '123456';
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.flash_on_rounded,
                                color: Colors.white70, size: 15),
                            const SizedBox(width: 6),
                            Text('Điền nhanh: admin@gomdon.vn / 123456',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    Text('GomĐơn v1.0 • Cần Thơ',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.4), fontSize: 12)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.roleAdmin, size: 20),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.roleAdmin, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}
