import 'package:flutter/material.dart';
import 'package:shared/models/hub_model.dart';
import 'hub_management_controller.dart';

/// Màn hình Quản lý Hub – Admin thêm/sửa/xóa cụm điểm giao hàng
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
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    _loadHubs();
  }

  Future<void> _loadHubs() async {
    setState(() => _isLoading = true);
    final hubs = await _controller.layDanhSachHub();
    setState(() {
      _hubs = hubs;
      _isLoading = false;
    });
  }

  Future<void> _themHub() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final maHub = await _controller.themHub(
      tenHub: _tenCtrl.text.trim(),
      kinhDo: double.tryParse(_kinhDoCtrl.text) ?? 0,
      viDo: double.tryParse(_viDoCtrl.text) ?? 0,
      diaChi: _diaChiCtrl.text.trim(),
    );

    setState(() => _isSaving = false);

    if (maHub != null) {
      _tenCtrl.clear();
      _kinhDoCtrl.clear();
      _viDoCtrl.clear();
      _diaChiCtrl.clear();
      setState(() => _showForm = false);
      _loadHubs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('✅ Đã thêm Hub "${ _tenCtrl.text}" thành công!'),
          ]),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('❌ Lỗi khi thêm Hub!'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<void> _toggleHub(HubModel hub) async {
    final newState = !hub.dangHoatDong;
    await _controller.capNhatTrangThai(hub.maHub, newState);
    _loadHubs();
  }

  Future<void> _xoaHub(HubModel hub) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red),
          SizedBox(width: 8),
          Text('Xóa Hub?'),
        ]),
        content: Text(
          'Bạn có chắc muốn xóa Hub "${hub.tenHub}"?\n'
          'Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _controller.xoaHub(hub.maHub);
      _loadHubs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Đã xóa Hub "${hub.tenHub}"'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FA),
      appBar: AppBar(
        title: const Text('🗺️ Quản lý Hub',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF8E44AD),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHubs,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => setState(() => _showForm = !_showForm),
        backgroundColor: const Color(0xFF8E44AD),
        foregroundColor: Colors.white,
        icon: Icon(_showForm ? Icons.close : Icons.add_location_alt),
        label: Text(_showForm ? 'Đóng form' : 'Thêm Hub mới'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(children: [
          // ── Thống kê tổng quan ────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8E44AD), Color(0xFF6C3483)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat(
                  '📍 Tổng Hub',
                  _hubs.length.toString(),
                ),
                Container(
                    width: 1, height: 40, color: Colors.white30),
                _buildStat(
                  '✅ Đang hoạt động',
                  _hubs.where((h) => h.dangHoatDong).length.toString(),
                ),
                Container(
                    width: 1, height: 40, color: Colors.white30),
                _buildStat(
                  '⛔ Tạm dừng',
                  _hubs.where((h) => !h.dangHoatDong).length.toString(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Form thêm Hub (ẩn/hiện) ───────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildAddForm(),
            crossFadeState: _showForm
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          if (_showForm) const SizedBox(height: 16),

          // ── Danh sách Hub ─────────────────────────────────────────
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '📍 Danh sách Hub (${_hubs.length})',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2C3E50)),
            ),
          ),
          const SizedBox(height: 12),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: Color(0xFF8E44AD)),
            )
          else if (_hubs.isEmpty)
            _buildEmptyState()
          else
            ..._hubs.map((hub) => _buildHubCard(hub)),
        ]),
      ),
    );
  }

  // ── Widget Form thêm Hub ─────────────────────────────────────────
  Widget _buildAddForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8E44AD).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E44AD).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.add_location_alt, color: Color(0xFF8E44AD)),
            const SizedBox(width: 8),
            const Text(
              'Thêm Hub mới',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF8E44AD)),
            ),
          ]),
          const SizedBox(height: 14),
          _buildField(_tenCtrl, 'Tên Hub *', 'VD: Tòa nhà Viettel Cần Thơ',
              icon: Icons.business),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: _buildField(
                    _viDoCtrl, 'Vĩ độ (Latitude) *', 'VD: 10.0341',
                    isNumber: true, icon: Icons.explore)),
            const SizedBox(width: 10),
            Expanded(
                child: _buildField(
                    _kinhDoCtrl, 'Kinh độ (Longitude) *', 'VD: 105.7469',
                    isNumber: true, icon: Icons.explore_outlined)),
          ]),
          const SizedBox(height: 10),
          _buildField(_diaChiCtrl, 'Địa chỉ đầy đủ *',
              'VD: 166 Trần Hưng Đạo, Ninh Kiều, Cần Thơ',
              icon: Icons.location_on),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _themHub,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.save),
              label: Text(
                _isSaving ? 'Đang lưu...' : 'Lưu Hub lên Firestore',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8E44AD),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Card hiển thị Hub ────────────────────────────────────────────
  Widget _buildHubCard(HubModel hub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hub.dangHoatDong
              ? const Color(0xFF8E44AD).withOpacity(0.15)
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: hub.dangHoatDong
                    ? const Color(0xFF8E44AD).withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.business,
                color: hub.dangHoatDong
                    ? const Color(0xFF8E44AD)
                    : Colors.grey,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hub.tenHub,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: hub.dangHoatDong
                            ? const Color(0xFF2C3E50)
                            : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hub.maHub,
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontFamily: 'monospace'),
                    ),
                  ]),
            ),
            // Toggle bật/tắt
            Switch(
              value: hub.dangHoatDong,
              onChanged: (_) => _toggleHub(hub),
              activeColor: const Color(0xFF8E44AD),
            ),
          ]),
          const Divider(height: 16),
          // Địa chỉ
          Row(children: [
            Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Expanded(
                child: Text(
              hub.diaChi.isEmpty ? 'Chưa có địa chỉ' : hub.diaChi,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            )),
          ]),
          const SizedBox(height: 4),
          // Tọa độ
          Row(children: [
            Icon(Icons.explore, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(
              'Lat: ${hub.viDo.toStringAsFixed(4)} | Lng: ${hub.kinhDo.toStringAsFixed(4)} | Bán kính: ${hub.banKinhMacDinh}m',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ]),
          const SizedBox(height: 8),
          // Badge trạng thái + nút xóa
          Row(children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: hub.dangHoatDong
                    ? Colors.green.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                hub.dangHoatDong ? '🟢 Đang hoạt động' : '⛔ Tạm dừng',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color:
                      hub.dangHoatDong ? Colors.green.shade700 : Colors.grey,
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 20, color: Colors.red),
              onPressed: () => _xoaHub(hub),
              tooltip: 'Xóa Hub',
              splashRadius: 20,
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.location_off, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Chưa có Hub nào',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bấm "Thêm Hub mới" để tạo cụm điểm giao hàng đầu tiên',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(children: [
      Text(
        value,
        style: const TextStyle(
            color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 11),
        textAlign: TextAlign.center,
      ),
    ]);
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    String hint, {
    bool isNumber = false,
    IconData? icon,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Không được để trống' : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFF8E44AD), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tenCtrl.dispose();
    _kinhDoCtrl.dispose();
    _viDoCtrl.dispose();
    _diaChiCtrl.dispose();
    super.dispose();
  }
}
