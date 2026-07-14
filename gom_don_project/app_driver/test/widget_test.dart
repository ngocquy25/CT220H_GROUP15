import 'package:flutter_test/flutter_test.dart';
import 'package:app_driver/main.dart';

void main() {
  testWidgets('Driver App smoke test', (WidgetTester tester) async {
    // Chỉ cần test xem app có thể khởi chạy mà không bị crash
    await tester.pumpWidget(const GomDonDriverApp());
    expect(find.text('GomĐơn - Tài xế'), findsOneWidget);
  });
}
