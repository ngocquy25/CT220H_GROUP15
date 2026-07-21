import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared/theme/app_colors.dart';

/// Màn hình Đăng nhập — Chủ quán (Merchant)
/// Màu chủ đạo: Xanh lá tươi (roleMerchant #00B894)
/// 3 tài khoản: merchant1/2/3@gomdon.vn / 123456
class MerchantLoginScreen extends StatefulWidget {
  const MerchantLoginScreen({super.key});

  @override
  State<MerchantLoginScreen> createState() => _MerchantLoginScreenState();
}

class _MerchantLoginScreenState extends State<MerchantLoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController(text: '123456');
  bool _isLoading   = false;
  bool _obscurePass = true;
  String? _errorMsg;
  int? _selectedAccount;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const _accounts = [
    ('merchant1@gomdon.vn', 'Cơm Tấm Bà Ba', '🍚'),
    ('merchant2@gomdon.vn', 'Bún Bò Huế', '🍜'),
    ('merchant3@gomdon.vn', 'Bánh Mì Thanh', '🥪'),
  ];

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

  void _selectAccount(int idx) {
    setState(() {
      _selectedAccount = idx;
      _emailCtrl.text = _accounts[idx].$1;
      _errorMsg = null;
    });
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
      case 'too-many-requests':    return 'Quá nhiều lần thử!';
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
              Color(0xFF00816A), // roleMerchantDark
              AppColors.roleMerchant, // #00B894
              Color(0xFF55EFC4), // Xanh lá nhạt
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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 48),

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
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: const Icon(Icons.restaurant_menu_rounded,
                          size: 48, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    const Text('GomĐơn', style: TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold,
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
                      child: const Text('CỔNG CHỦ QUÁN', style: TextStyle(
                        fontSize: 11, color: Colors.white,
                        fontWeight: FontWeight.bold, letterSpacing: 2,
                      )),
                    ),

                    const SizedBox(height: 32),

                    // ── Chọn nhanh quán ──────────────────
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Chọn quán của bạn:',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: List.generate(_accounts.length, (i) {
                        final isSelected = _selectedAccount == i;
                        return GestureDetector(
                          onTap: () => _selectAccount(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.3),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(children: [
                              Text(_accounts[i].$3,
                                  style: const TextStyle(fontSize: 22)),
                              const SizedBox(width: 12),
                              Expanded(child: Text(_accounts[i].$2,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.roleMerchantDark
                                      : Colors.white,
                                ))),
                              if (isSelected)
                                Icon(Icons.check_circle_rounded,
                                    color: AppColors.roleMerchant, size: 20),
                            ]),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 20),

                    // ── Form Card ─────────────────────────
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 30, offset: const Offset(0, 12)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Đăng nhập', style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          )),
                          const SizedBox(height: 18),

                          _buildTextField(
                            controller: _emailCtrl,
                            label: 'Email quán ăn',
                            icon: Icons.store_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 14),

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
                                color: AppColors.roleMerchant,
                              ),
                              onPressed: () =>
                                  setState(() => _obscurePass = !_obscurePass),
                            ),
                          ),

                          if (_errorMsg != null) ...[
                            const SizedBox(height: 10),
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

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity, height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.roleMerchant,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                elevation: 4,
                                shadowColor:
                                    AppColors.roleMerchant.withOpacity(0.4),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22, height: 22,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : const Text('VÀO BẾP', style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

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
        prefixIcon: Icon(icon, color: AppColors.roleMerchant, size: 20),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.roleMerchant, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}
