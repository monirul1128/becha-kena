import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bechakena_hub/main.dart';
import 'package:bechakena_hub/oms_demo.dart';

void main() {
  testWidgets('role picker opens the reseller workspace', (tester) async {
    await tester.pumpWidget(const BechaKenaHubApp());

    expect(find.text('BKH Business Manager'), findsOneWidget);
    expect(find.text('Reseller'), findsOneWidget);
    expect(find.text('Administrator'), findsOneWidget);

    await tester.tap(find.text('Reseller'));
    await tester.pumpAndSettle();

    expect(find.text('Order Overview'), findsOneWidget);
    expect(find.text('Hello, Reseller!'), findsOneWidget);
    expect(find.textContaining('DEMO DATA'), findsNothing);

    await tester.tap(find.text('Orders'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Sample orders from all reseller accounts'),
      findsNothing,
    );

    await tester.tap(find.text('Wallet'));
    await tester.pumpAndSettle();
    expect(find.textContaining('DEMO WALLET'), findsNothing);
  });

  testWidgets('reseller catalog opens details for the selected product', (
    tester,
  ) async {
    await tester.pumpWidget(const BechaKenaHubApp());
    await tester.tap(find.text('Reseller'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Catalog'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('View Details').first);
    await tester.pumpAndSettle();

    expect(find.text('Product Details'), findsOneWidget);
    expect(find.text('Type-C Fast Charging Cable'), findsWidgets);
    expect(find.text('Order Details'), findsNothing);
  });

  testWidgets('admin navigation opens management sections', (tester) async {
    await tester.pumpWidget(const BechaKenaHubApp());

    await tester.tap(find.text('Administrator'));
    await tester.pumpAndSettle();
    expect(find.text('Platform Overview'), findsOneWidget);
    expect(find.textContaining('DEMO DATA'), findsNothing);

    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();
    final drawerList = find.descendant(
      of: find.byType(Drawer),
      matching: find.byType(Scrollable),
    );
    await tester.drag(drawerList, const Offset(0, -180));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Withdrawal & Disbursement'));
    await tester.pumpAndSettle();

    expect(find.text('Withdrawal & Disbursement'), findsOneWidget);
    expect(find.text('Move Pending to Processing'), findsOneWidget);
    expect(find.text('Copy processing CSV'), findsOneWidget);
    expect(find.text('Disbursement'), findsOneWidget);
    expect(
      find.text('No withdrawal requests match this filter.'),
      findsOneWidget,
    );
  });

  testWidgets('admin products exposes Excel bulk upload and category first', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 3600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const BechaKenaHubApp());
    await tester.tap(find.text('Administrator'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Product Management'));
    await tester.pumpAndSettle();

    expect(find.text('Product Category'), findsOneWidget);
    expect(find.text('Upload product Excel file (.xlsx)'), findsOneWidget);
    expect(find.textContaining('Excel columns: category'), findsOneWidget);
    expect(find.textContaining('Select product CSV'), findsNothing);

    final categoryDropdown = find.byType(DropdownButtonFormField<String>);
    final titleField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.labelText == 'Title',
    );
    expect(categoryDropdown, findsOneWidget);
    expect(titleField, findsOneWidget);
    expect(
      tester.getTopLeft(categoryDropdown).dy,
      lessThan(tester.getTopLeft(titleField).dy),
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is DropdownButtonFormField<String> &&
            widget.decoration.labelText == 'Title',
      ),
      findsNothing,
    );

    await tester.tap(find.text('Edit').first);
    await tester.pumpAndSettle();
    final editTitle = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.labelText == 'Title',
      ),
    );
    await tester.enterText(editTitle, 'Edited demo cable');
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    expect(find.text('Edited demo cable'), findsOneWidget);

    await tester.tap(find.text('Delete').first);
    await tester.pumpAndSettle();
    expect(find.text('Delete product?'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Delete'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Edited demo cable'), findsNothing);
  });

  testWidgets('admin customers exposes Excel bulk upload', (tester) async {
    await tester.pumpWidget(const BechaKenaHubApp());
    await tester.tap(find.text('Administrator'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Customer Management'));
    await tester.pumpAndSettle();

    expect(find.text('Upload customer Excel file (.xlsx)'), findsOneWidget);
    expect(find.textContaining('Excel columns: name'), findsOneWidget);
    expect(find.textContaining('Select customer CSV'), findsNothing);
  });

  testWidgets('admin reseller management shows order and wallet breakdowns', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 3600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const BechaKenaHubApp());
    await tester.tap(find.text('Administrator'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();
    final drawerScrollable = find.descendant(
      of: find.byType(Drawer),
      matching: find.byType(Scrollable),
    );
    await tester.drag(drawerScrollable, const Offset(0, -120));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reseller Management'));
    await tester.pumpAndSettle();

    expect(find.text('Rahim Store'), findsOneWidget);
    expect(find.text('Orders'), findsNWidgets(3));
    expect(find.text('Pending'), findsNWidgets(3));
    expect(find.text('Processing'), findsNWidgets(3));
    expect(find.text('Delivered'), findsNWidgets(3));
    expect(find.text('Cancelled'), findsNWidgets(3));
    expect(find.text('Wallet'), findsNWidgets(3));
    expect(find.text('Capital'), findsNWidgets(3));
    expect(find.text('Profit'), findsNWidgets(3));
    expect(find.text('Current Balance'), findsNWidgets(3));
    expect(find.text('Withdraw'), findsNWidgets(3));
  });

  testWidgets('batch page shows calculations while orders show assignments', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 3600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    demoOms.resetSystem();
    await tester.pumpWidget(const BechaKenaHubApp());
    await tester.tap(find.text('Administrator'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Batch Management'));
    await tester.pumpAndSettle();
    expect(find.text('Batch Calculations & Division'), findsOneWidget);
    expect(find.text('৳300 + ৳200'), findsNWidgets(2));
    expect(find.text('Assignment'), findsNothing);

    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Order Management').last);
    await tester.pumpAndSettle();
    expect(find.text('Batch'), findsNWidgets(2));
    expect(find.text('Assignment'), findsNWidgets(2));
    expect(find.text('Transfer number'), findsNWidgets(2));
    expect(find.text('Settlement'), findsNWidgets(3));
  });

  testWidgets('admin wallet summaries and reset confirmation are available', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 3600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    demoOms.resetSystem();
    demoOms.products.removeAt(0);
    await tester.pumpWidget(const BechaKenaHubApp());
    await tester.tap(find.text('Administrator'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wallet'));
    await tester.pumpAndSettle();
    expect(find.text('Payment'), findsOneWidget);
    expect(find.text('Withdraw'), findsOneWidget);
    expect(find.text('Current Balance'), findsOneWidget);
    expect(find.text('Transaction History'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    expect(find.text('Reset System'), findsOneWidget);
    await tester.tap(find.text('Reset System'));
    await tester.pumpAndSettle();
    expect(find.text('Reset system data?'), findsOneWidget);
    expect(find.textContaining('Server data is not connected'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Reset System'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      demoOms.products.any(
        (product) => product.title == 'Type-C Fast Charging Cable',
      ),
      isTrue,
    );
    expect(find.text('System data and settings were reset.'), findsOneWidget);
  });
}
