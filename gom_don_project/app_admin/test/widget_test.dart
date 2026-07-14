import 'package:flutter_test/flutter_test.dart';
import 'package:app_admin/main.dart';

void main() {
  testWidgets('Admin App smoke test', (WidgetTester tester) async {
    // Chỉ cần test xem app có thể khởi chạy mà không bị crash
    await tester.pumpWidget(const GomDonAdminApp());
    expect(find.text('GomĐơn - Quản trị viên'), findsOneWidget);
  });
}
