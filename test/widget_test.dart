import 'package:flutter_test/flutter_test.dart';
import 'package:roozino/main.dart';

void main() {
  testWidgets('Roozino app loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const RoozinoApp());

    expect(find.text('سلام 👋'), findsOneWidget);

    expect(find.text('امروز'), findsWidgets);
    expect(find.text('کارها'), findsOneWidget);
    expect(find.text('تقویم'), findsOneWidget);
    expect(find.text('تمرکز'), findsOneWidget);
    expect(find.text('بیشتر'), findsOneWidget);

    expect(find.text('ارسال گزارش پروژه'), findsOneWidget);
    expect(find.text('تماس با مشتری'), findsOneWidget);
  });
}
