import 'package:flutter/material.dart';
import 'register_controller.dart';
import '../../core/app_colors.dart';
import '../../core/app_routes.dart';

/// Màn hình Đăng ký tài khoản mới
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _controller = RegisterController();
  final _tenCtrl = TextEditingController();
  final _sdtCtrl = TextEditingController();
  final _mkCtrl = TextEditingController();
  final _xnMkCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscureMk = true;
  bool _obscureXnMk = true;

  Future<void> _handleRegister() async {
    setState(() => _isLoading = true);
    final error = await _controller.dangKy(
      tenKhachHang: _tenCtrl.text,
      soDienThoai: _sdtCtrl.text.trim(),
      matKhau: _mkCtrl.text,
      xacNhanMatKhau: _xnMkCtrl.text,
    );
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Đăng ký thành công! Vui lòng đăng nhập.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Đăng ký tài khoản', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const SizedBox(height: 16),

            // Icon header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
              ),
              child: const Icon(Icons.person_add, color: AppColors.primary, size: 48),
            ),
            const SizedBox(height: 16),
            const Text('Tạo tài khoản GomĐơn',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const Text('Miễn phí • Giao hàng theo cụm • Tiết kiệm hơn',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 32),

            // Form
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16, offset: const Offset(0, 4),
                )],
              ),
              child: Column(children: [
                _buildField(
                  controller: _tenCtrl,
                  label: 'Họ và tên',
                  icon: Icons.person,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 14),
                _buildField(
                  controller: _sdtCtrl,
                  label: 'Số điện thoại',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                _buildField(
                  controller: _mkCtrl,
                  label: 'Mật khẩu (tối thiểu 6 ký tự)',
                  icon: Icons.lock,
                  obscure: _obscureMk,
                  onToggleObscure: () => setState(() => _obscureMk = !_obscureMk),
                ),
                const SizedBox(height: 14),
                _buildField(
                  controller: _xnMkCtrl,
                  label: 'Xác nhận mật khẩu',
                  icon: Icons.lock_outline,
                  obscure: _obscureXnMk,
                  onToggleObscure: () => setState(() => _obscureXnMk = !_obscureXnMk),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Đăng ký', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('Đã có tài khoản? ', style: TextStyle(color: AppColors.textSecondary)),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text('Đăng nhập',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    VoidCallback? onToggleObscure,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: onToggleObscure,
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tenCtrl.dispose();
    _sdtCtrl.dispose();
    _mkCtrl.dispose();
    _xnMkCtrl.dispose();
    super.dispose();
  }
}
