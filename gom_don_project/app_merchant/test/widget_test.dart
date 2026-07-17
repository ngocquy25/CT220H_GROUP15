import 'package:flutter_test/flutter_test.dart';
import 'package:app_merchant/main.dart';

void main() {
  testWidgets('Merchant App smoke test', (WidgetTester tester) async {
    // Chỉ cần test xem app có thể khởi chạy mà không bị crash
    await tester.pumpWidget(const GomDonMerchantApp());
    expect(find.text('GomĐơn - Quán ăn'), findsOneWidget);
  });
}
