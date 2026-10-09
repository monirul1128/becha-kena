import 'package:flutter_test/flutter_test.dart';

import 'package:bechakena_hub/oms_demo.dart';

void main() {
  test('parses quoted CSV values, embedded commas, and newlines', () {
    expect(
      parseCsvRows(
        '\uFEFFcategory,title,description,wholesale_price\r\n'
        '"Home, Kitchen","Bottle","Keeps drinks cold,\n'
        'even overnight",250\r\n'
        '"Fashion","T-Shirt","She said ""hello""",200',
      ),
      [
        ['category', 'title', 'description', 'wholesale_price'],
        [
          'Home, Kitchen',
          'Bottle',
          'Keeps drinks cold,\neven overnight',
          '250',
        ],
        ['Fashion', 'T-Shirt', 'She said "hello"', '200'],
      ],
    );
  });

  test('rejects malformed CSV with an unclosed quote', () {
    expect(
      () => parseCsvRows('name,mobile_number\n"Rahim,01700000000'),
      throwsA(isA<FormatException>()),
    );
  });

  group('DemoOmsStore', () {
    test('divides a target into available wholesale prices', () {
      expect(
        DemoOmsStore.divideTarget(500, [200, 300, 250]),
        containsAll([200, 300]),
      );
      expect(DemoOmsStore.divideTarget(750, [200, 300]), isEmpty);
      expect(
        DemoOmsStore.divideTarget(700, [200, 300, 250]).reduce((a, b) => a + b),
        700,
      );
    });

    test('blocks partial settlement and credits a full batch once', () {
      final store = DemoOmsStore();
      expect(store.currentDivision.reduce((a, b) => a + b), 500);
      expect(store.canSettleCurrentBatch, isFalse);
      expect(store.settleCurrentBatch, throwsA(isA<StateError>()));
      expect(store.resellerCapital, 0);

      store.confirmPayment(store.orders.first);
      expect(
        () => store.confirmPayment(store.orders.first),
        throwsA(isA<StateError>()),
      );
      expect(store.canSettleCurrentBatch, isFalse);

      for (final order in store.orders.toList()) {
        if (order.batchId == store.currentBatchId &&
            order.status == DemoOrderStatus.pending) {
          store.confirmPayment(order);
        }
      }
      expect(store.canSettleCurrentBatch, isTrue);
      expect(store.settleCurrentBatch(), isTrue);
      expect(store.settledBatchIds, contains('B-001'));
      expect(
        store.orders
            .where((order) => order.batchId == 'B-001')
            .every((order) => order.status == DemoOrderStatus.delivered),
        isTrue,
      );
      expect(store.resellerCapital, 500);
      expect(store.resellerProfit, 150);
      expect(store.walletEntries, hasLength(2));
      expect(
        store.walletEntries.map((entry) => entry.orderId).toSet(),
        hasLength(2),
      );
      expect(store.currentBatchId, 'B-002');
      expect(store.currentBatchTarget, 750);
      expect(store.batchOrderTotal, 750);
    });

    test('transfers an unpaid order and counts each transfer', () {
      final store = DemoOmsStore();
      final order = store.orders.first;
      final assigned = order.reseller;

      store.transferOrder(order);
      expect(order.transferNumber, 1);
      expect(order.reseller.active, isTrue);
      expect(order.reseller, isNot(same(assigned)));
      expect(order.paymentStatus, DemoPaymentStatus.unpaid);
    });

    test('keeps settlement atomic when the next target cannot be divided', () {
      final store = DemoOmsStore()
        ..products.removeWhere((product) => product.wholesalePrice == 250);
      for (final order in store.orders) {
        store.confirmPayment(order);
      }

      expect(store.settleCurrentBatch, throwsA(isA<StateError>()));
      expect(store.currentBatchId, 'B-001');
      expect(store.settledBatchIds, isEmpty);
      expect(store.resellerCapital, 0);
      expect(
        store.orders.every(
          (order) => order.status == DemoOrderStatus.processing,
        ),
        isTrue,
      );

      store.settings.growthRate = 40;
      store.settleCurrentBatch();
      expect(store.currentBatchId, 'B-002');
      expect(store.currentBatchTarget, 700);
    });

    test(
      'updates pending prices and rejects payments while the system is off',
      () {
        final store = DemoOmsStore();
        store.updateProfitRate(40);
        expect(
          store.orders.first.retailPrice,
          (store.orders.first.wholesalePrice * 1.4).round(),
        );
        store.settings.systemEnabled = false;
        expect(
          () => store.confirmPayment(store.orders.first),
          throwsA(isA<StateError>()),
        );
        expect(store.orders.first.paymentStatus, DemoPaymentStatus.unpaid);
      },
    );

    test('reserves withdrawals and prevents duplicate results', () {
      final store = DemoOmsStore();
      for (final order in store.orders) {
        store.confirmPayment(order);
      }
      store.settleCurrentBatch();
      final reseller = store.resellers.first;
      final available = store.availableBalanceFor(reseller);

      expect(
        () => store.requestWithdrawal(
          reseller: reseller,
          amount: available + 1,
          method: 'bKash',
          account: '01700000000',
        ),
        throwsA(isA<StateError>()),
      );
      final request = store.requestWithdrawal(
        reseller: reseller,
        amount: 100,
        method: 'bKash',
        account: '01700000000',
      );
      expect(store.availableBalanceFor(reseller), available - 100);
      store.movePendingWithdrawalsToProcessing();
      store.applyDemoDisbursementResult(request, approved: true);
      expect(request.status, DemoWithdrawalStatus.approved);
      expect(request.transactionReference, isNotNull);
      expect(store.availableBalanceFor(reseller), available - 100);
      expect(
        () => store.applyDemoDisbursementResult(request, approved: true),
        throwsA(isA<StateError>()),
      );
    });
  });
}
