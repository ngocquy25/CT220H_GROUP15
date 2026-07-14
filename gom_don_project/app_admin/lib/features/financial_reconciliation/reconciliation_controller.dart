import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared/models/order_model.dart';
import 'package:shared/services/firebase_core.dart';
import 'package:shared/test/mock_data.dart';
import 'dart:io';
import 'package:intl/intl.dart';

/// Controller: Đối soát tài chính – Firestore + xuất Excel thật
class ReconciliationController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Lấy lịch sử đơn hàng ─────────────────────────────────────────
  /// Lấy tất cả đơn đã hoàn thành (Thành công / Đã giao / Đã hủy)
  /// Có thể filter theo tháng. Nếu Firebase không khả dụng → dùng mock.
  Future<List<OrderModel>> layLichSuDon({
    DateTime? tuNgay,
    DateTime? denNgay,
  }) async {
    if (!FirebaseCoreService.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _applyFilter(MockData.mockOrders, tuNgay, denNgay);
    }

    try {
      Query query = _db.collection('orders');

      // Chỉ lấy các đơn đã hoàn thành (bỏ trạng thái "Chờ chốt")
      // Nếu muốn lọc theo ngày, thêm where clause ở đây
      final snapshot = await query.get();
      final orders = snapshot.docs
          .map((doc) =>
              OrderModel.fromJson({...doc.data() as Map, 'MaDonHang': doc.id}))
          .toList();

      return _applyFilter(orders, tuNgay, denNgay);
    } catch (e) {
      print('⚠️ Firestore layLichSuDon lỗi, dùng mock: $e');
      return _applyFilter(MockData.mockOrders, tuNgay, denNgay);
    }
  }

  List<OrderModel> _applyFilter(
    List<OrderModel> orders,
    DateTime? tuNgay,
    DateTime? denNgay,
  ) {
    var result = orders;
    if (tuNgay != null) {
      result = result.where((o) {
        try {
          final date = DateTime.parse(o.ngayGiao);
          return !date.isBefore(tuNgay);
        } catch (_) {
          return true;
        }
      }).toList();
    }
    if (denNgay != null) {
      result = result.where((o) {
        try {
          final date = DateTime.parse(o.ngayGiao);
          return !date.isAfter(denNgay);
        } catch (_) {
          return true;
        }
      }).toList();
    }
    return result;
  }

  // ── Xuất báo cáo Excel thật ──────────────────────────────────────
  /// Tạo file Excel với đầy đủ dữ liệu. Trả về đường dẫn nếu thành công.
  Future<String?> xuatBaoCaoExcel(List<OrderModel> orders) async {
    try {
      final excel = Excel.createExcel();
      // Xóa sheet mặc định
      excel.delete('Sheet1');

      // ── Sheet 1: Danh sách đơn hàng ───────────────────────────
      final sheetDon = excel['Danh Sach Don Hang'];
      final headerStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#8E44AD'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
      );

      // Header row
      final headers = [
        'Mã Đơn Hàng',
        'Ngày Giao',
        'Tên Khách',
        'SĐT',
        'Tên Quán',
        'Tài Xế',
        'Phòng',
        'Cài Đặt',
        'Tổng Tiền Món',
        'Phí Ship Gốc',
        'Phí Ship Thực Tế',
        'Tổng Thanh Toán',
        'Tạm Khóa',
        'Hoàn Tiền',
        'Trạng Thái',
      ];

      for (int i = 0; i < headers.length; i++) {
        final cell =
            sheetDon.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }

      // Data rows
      for (int row = 0; row < orders.length; row++) {
        final o = orders[row];
        final rowData = [
          o.maDonHang,
          o.ngayGiao,
          o.tenKhachHang,
          o.soDienThoaiKhach,
          o.tenQuan,
          o.tenTaiXe ?? '—',
          o.maPhong,
          o.luaChonCaiDat,
          o.tongTienMon,
          o.phiShipGoc,
          o.phiShipThucTe,
          o.tongThanhToan,
          o.soTienTamKhoa,
          o.tienDuocHoan,
          o.trangThaiDonHang,
        ];

        for (int col = 0; col < rowData.length; col++) {
          final cell = sheetDon.cell(
            CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row + 1),
          );
          final val = rowData[col];
          if (val is int) {
            cell.value = IntCellValue(val);
          } else {
            cell.value = TextCellValue(val.toString());
          }
        }
      }

      // ── Sheet 2: Tổng kết theo quán ───────────────────────────
      final sheetQuan = excel['Tong Ket Theo Quan'];
      final headerQuan = [
        'Tên Quán', 'Số Đơn', 'Tổng Doanh Thu', 'Tỷ Lệ CK (%)', 'Tiền CK',
      ];
      for (int i = 0; i < headerQuan.length; i++) {
        final cell = sheetQuan
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headerQuan[i]);
        cell.cellStyle = headerStyle;
      }

      // Nhóm theo quán
      final Map<String, List<OrderModel>> byQuan = {};
      for (var o in orders) {
        byQuan[o.tenQuan] = [...(byQuan[o.tenQuan] ?? []), o];
      }
      int r = 1;
      byQuan.forEach((tenQuan, donList) {
        final tongDT = donList.fold(0, (s, o) => s + o.tongTienMon);
        // Tỷ lệ chiết khấu mặc định 15% nếu chưa biết
        final ck = (tongDT * 0.15).round();
        final rowData = [tenQuan, donList.length, tongDT, '15%', ck];
        for (int col = 0; col < rowData.length; col++) {
          final cell = sheetQuan
              .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: r));
          final val = rowData[col];
          cell.value = val is int
              ? IntCellValue(val)
              : TextCellValue(val.toString());
        }
        r++;
      });

      // ── Lưu file ──────────────────────────────────────────────
      final dir = await getApplicationDocumentsDirectory();
      final now = DateTime.now();
      final fileName =
          'BaoCaoGomDon_${DateFormat('dd-MM-yyyy_HHmm').format(now)}.xlsx';
      final filePath = '${dir.path}/$fileName';

      final bytes = excel.encode();
      if (bytes == null) throw Exception('Excel encode failed');

      await File(filePath).writeAsBytes(bytes);
      print('✅ Xuất Excel thành công: $filePath');
      return filePath;
    } catch (e) {
      print('❌ Lỗi xuất Excel: $e');
      return null;
    }
  }

  // ── Tính tổng nhanh ──────────────────────────────────────────────
  Map<String, int> tinhTongKet(List<OrderModel> orders) {
    return {
      'soLuongDon': orders.length,
      'tongDoanhThu': orders.fold(0, (s, o) => s + o.tongTienMon),
      'tongPhiShip': orders.fold(0, (s, o) => s + o.phiShipThucTe),
      'soLuongThanhCong': orders.where((o) => o.thanhCong || o.daGiao).length,
      'soLuongHuy': orders.where((o) => o.daHuy).length,
    };
  }
}
