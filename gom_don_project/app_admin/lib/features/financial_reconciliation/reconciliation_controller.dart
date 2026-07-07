import 'package:shared/models/order_model.dart';
import 'package:shared/test/mock_data.dart';

/// Controller: Đối soát tài chính và xuất Excel
class ReconciliationController {
  /// Lấy toàn bộ lịch sử đơn hàng (để đối soát)
  Future<List<OrderModel>> layLichSuDon() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // TODO: Firestore: lấy tất cả orders trong tháng
    return MockData.mockOrders;
  }

  /// Xuất báo cáo sang file Excel
  /// Trả về đường dẫn file nếu thành công, null nếu lỗi
  Future<String?> xuatBaoCaoExcel(List<OrderModel> orders) async {
    await Future.delayed(const Duration(seconds: 1));

    try {
      // TODO: Tích hợp package 'excel':
      // final excel = Excel.createExcel();
      // final sheet = excel['BaoCao'];
      // sheet.appendRow(['MaDonHang', 'TenQuan', 'TenTaiXe', 'TongTienMon', 'PhiShipThucTe']);
      // for (var o in orders) {
      //   sheet.appendRow([o.maDonHang, o.tenQuan, o.tenTaiXe ?? '-', o.tongTienMon, o.phiShipThucTe]);
      // }
      // final dir = await getApplicationDocumentsDirectory();
      // final filePath = '${dir.path}/bao_cao_gomdon.xlsx';
      // await File(filePath).writeAsBytes(excel.encode()!);
      // return filePath;

      // Mock: giả lập thành công
      print('✅ [MOCK] Xuất ${orders.length} đơn hàng ra Excel');
      return '/storage/BaoCaoGomDon_${DateTime.now().day}_${DateTime.now().month}.xlsx';
    } catch (e) {
      print('❌ Lỗi xuất Excel: $e');
      return null;
    }
  }
}
