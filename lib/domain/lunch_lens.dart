import '../models/purchase_log.dart';

class LunchEstimate {
  final int mean, baseline;
  final List<PurchaseLog> inputs;
  const LunchEstimate(this.mean, this.baseline, this.inputs);
}

/// Rule-based estimator, not a trained model. Never reads future/reference rows.
LunchEstimate? estimateLunch(
  List<PurchaseLog> logs,
  int mealId,
  DateTime before,
) {
  final earlier =
      logs
          .where((l) => l.mealId == mealId && l.purchasedAt.isBefore(before))
          .toList()
        ..sort((a, b) {
          final date = b.purchasedAt.compareTo(a.purchasedAt);
          return date != 0 ? date : (b.id ?? 0).compareTo(a.id ?? 0);
        });
  if (earlier.any((l) => l.actualPriceMinor < 0)) {
    throw const FormatException('Correct invalid purchase amounts in History.');
  }
  if (earlier.length < 3) return null;
  final inputs = earlier.take(3).toList();
  // With three integer inputs the fractional part is 0, 1/3 or 2/3.
  final sum = inputs.fold<int>(0, (s, l) => s + l.actualPriceMinor);
  return LunchEstimate((sum + 1) ~/ 3, inputs.first.actualPriceMinor, inputs);
}
