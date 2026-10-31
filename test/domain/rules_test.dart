import 'package:flutter_test/flutter_test.dart';
import 'package:budget_bites/domain/money.dart';
import 'package:budget_bites/domain/lunch_lens.dart';
import 'package:budget_bites/models/purchase_log.dart';

List<PurchaseLog> history(List<int> cents) => [
  for (int i = 0; i < cents.length; i++)
    PurchaseLog(
      id: i + 1,
      mealId: 1,
      actualPriceMinor: cents[i],
      purchasedAt: DateTime(2026, 1, i + 1),
      saveToken: 't$i',
    ),
];
void main() {
  test('Decimal amounts become exact integer cents', () {
    expect(parseMoney('4.50'), 450);
    expect(parseMoney('0.1'), 10);
    expect(parseMoney('12'), 1200);
  });
  test('Reject malformed negative and excess precision', () {
    for (final v in ['-1', '1.001', 'NaN', '', '10000', '1e2']) {
      expect(() => parseMoney(v), throwsFormatException);
    }
  });
  test('Zero and largest accepted monetary boundary', () {
    expect(parseMoney('0'), 0);
    expect(parseMoney('9999.99'), 999999);
  });
  test('H1 normal estimate and last-price baseline', () {
    final e = estimateLunch(history([450, 600, 750]), 1, DateTime(2026, 2))!;
    expect(e.mean, 600);
    expect(e.baseline, 750);
  });
  test('H2 insufficient history gives no numeric estimate', () {
    expect(estimateLunch(history([450, 600]), 1, DateTime(2026, 2)), isNull);
  });
  test('H3 invalid history gives correction error', () {
    expect(
      () => estimateLunch(history([450, -1, 750]), 1, DateTime(2026, 2)),
      throwsFormatException,
    );
  });
  test('H4 rounds down one third and up two thirds', () {
    expect(
      estimateLunch(history([100, 100, 101]), 1, DateTime(2026, 2))!.mean,
      100,
    );
    expect(
      estimateLunch(history([100, 101, 101]), 1, DateTime(2026, 2))!.mean,
      101,
    );
  });
  test('H5 expensive outlier exposes poor mean prediction', () {
    final e = estimateLunch(history([500, 2000, 500]), 1, DateTime(2026, 2))!;
    expect(e.mean, 1000);
    expect(e.baseline, 500);
  });
  test('Exclude future and reference purchases', () {
    expect(
      estimateLunch(history([450, 600, 750]), 1, DateTime(2026, 1, 3)),
      isNull,
    );
  });
  test('Exclude another meal and use three latest rows', () {
    final logs = history([100, 200, 300, 400]);
    expect(estimateLunch(logs, 2, DateTime(2026, 2)), isNull);
    expect(estimateLunch(logs, 1, DateTime(2026, 2))!.mean, 300);
  });
  test('Same-time ties use descending stable row ID', () {
    final rows = history([100, 200, 300, 400])
        .map(
          (l) => PurchaseLog(
            id: l.id,
            mealId: 1,
            actualPriceMinor: l.actualPriceMinor,
            purchasedAt: DateTime(2026, 1),
            saveToken: l.saveToken,
          ),
        )
        .toList();
    expect(estimateLunch(rows, 1, DateTime(2026, 2))!.baseline, 400);
  });
}
