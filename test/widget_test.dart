import 'package:flutter_test/flutter_test.dart';

import 'package:bechakena_hub/main.dart';

void main() {
  testWidgets('role picker opens the reseller workspace', (tester) async {
    await tester.pumpWidget(const BechaKenaHubApp());

    expect(find.text('BechaKena Hub'), findsOneWidget);
    expect(find.text('Reseller'), findsOneWidget);
    expect(find.text('Administrator'), findsOneWidget);

    await tester.tap(find.text('Reseller'));
    await tester.pumpAndSettle();

    expect(find.text('Order Overview'), findsOneWidget);
    expect(find.text('Hello, Reseller!'), findsOneWidget);
  });

  testWidgets('admin navigation opens management sections', (tester) async {
    await tester.pumpWidget(const BechaKenaHubApp());

    await tester.tap(find.text('Administrator'));
    await tester.pumpAndSettle();
    expect(find.text('Platform Overview'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Withdrawal Requests'));
    await tester.pumpAndSettle();

    expect(find.text('Move Pending to Processing'), findsOneWidget);
    expect(
      find.text('No withdrawal requests match this filter.'),
      findsOneWidget,
    );
  });

  testWidgets('admin products exposes category and CSV bulk upload', (
    tester,
  ) async {
    await tester.pumpWidget(const BechaKenaHubApp());
    await tester.tap(find.text('Administrator'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Product Management'));
    await tester.pumpAndSettle();

    expect(find.text('Product Category'), findsOneWidget);
    expect(find.text('Select product CSV to bulk upload'), findsOneWidget);
  });
}
