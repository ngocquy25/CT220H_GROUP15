import 'package:flutter/material.dart';
import 'package:shared/models/hub_model.dart';
import 'hub_management_controller.dart';

/// Màn hình Quản lý Hub - Admin thêm/sửa cụm điểm giao hàng
class HubManagementScreen extends StatefulWidget {
  const HubManagementScreen({super.key});

  @override
  State<HubManagementScreen> createState() => _HubManagementScreenState();
}

class _HubManagementScreenState extends State<HubManagementScreen> {
  final _controller = HubManagementController();
  final _formKey = GlobalKey<FormState>();
  final _tenCtrl = TextEditingController();
  final _kinhDoCtrl = TextEditingController();
  final _viDoCtrl = TextEditingController();
  final _diaChiCtrl = TextEditingController();
  List<HubModel> _hubs = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadHubs();
  }

  Future<void> _loadHubs() async {
    final hubs = await _controller.layDanhSachHub();
    setState(() { _hubs = hubs; _isLoading = false; });
  }

  Future<void> _themHub() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await _controller.themHub(
      tenHub: _tenCtrl.text.trim(),
      kinhDo: double.parse(_kinhDoCtrl.text),
      viDo: double.parse(_viDoCtrl.text),
      diaChi: _diaChiCtrl.text.trim(),
    );
    setState(() => _isSaving = false);
    _tenCtrl.clear(); _kinhDoCtrl.clear(); _viDoCtrl.clear(); _diaChiCtrl.clear();
    _loadHubs();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Thêm Hub thành công!'), backgroundColor: Colors.purple));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FA),
      appBar: AppBar(
        title: const Text('Quản lý Hub', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF8E44AD),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Form thêm Hub mới
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07),
                  blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('➕ Thêm Hub mới',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,
                    color: Color(0xFF8E44AD))),
                const SizedBox(height: 12),
                _buildField(_tenCtrl, 'Tên Hub', 'VD: Tòa nhà Viettel Cần Thơ'),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _buildField(_viDoCtrl, 'Vĩ độ (lat)', 'VD: 10.0341',
                    isNumber: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildField(_kinhDoCtrl, 'Kinh độ (lng)', 'VD: 105.7469',
                    isNumber: true)),
                ]),
                const SizedBox(height: 10),
                _buildField(_diaChiCtrl, 'Địa chỉ đầy đủ', 'VD: 166 Trần Hưng Đạo, Ninh Kiều'),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _themHub,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8E44AD),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isSaving
                        ? const SizedBox(height: 20, width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Lưu Hub lên Firestore'),
                  ),
                ),
              ]),
            ),
          ),

          const SizedBox(height: 20),
          const Align(alignment: Alignment.centerLeft,
            child: Text('📍 Danh sách Hub hiện tại:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          const SizedBox(height: 10),

          if (_isLoading)
            const CircularProgressIndicator()
          else
            ..._hubs.map((hub) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
                    blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Row(children: [
                const Icon(Icons.business, color: Color(0xFF8E44AD)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(hub.tenHub, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(hub.diaChi, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  Text('📍 ${hub.viDo}, ${hub.kinhDo}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                ])),
                Switch(
                  value: hub.dangHoatDong,
                  onChanged: (_) {},
                  activeColor: const Color(0xFF8E44AD),
                ),
              ]),
            )),
        ]),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, String hint,
      {bool isNumber = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (v) => (v == null || v.isEmpty) ? 'Không được để trống' : null,
      decoration: InputDecoration(
        labelText: label, hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF8E44AD), width: 2),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tenCtrl.dispose(); _kinhDoCtrl.dispose();
    _viDoCtrl.dispose(); _diaChiCtrl.dispose();
    super.dispose();
  }
}
