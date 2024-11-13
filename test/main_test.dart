import 'package:flutter_test/flutter_test.dart';

import '../lib2/main.dart';

void main() {
  testWidgets('placeholder', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
  });
}
