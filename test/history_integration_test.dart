import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_bites/models/meal.dart';
import 'package:budget_bites/models/purchase_log.dart';
import 'package:budget_bites/screens/meal_history.dart';
import 'package:budget_bites/state/app_store.dart';
import 'package:budget_bites/data/meal_database.dart';

void main() {
  AppStore fixture() {
    final store = AppStore(MealDatabase());
    store.meals = [
      const Meal(
        id: 1,
        mealName: 'Wrap',
        venue: 'Local cafe',
        entreePrice: 450,
      ),
      const Meal(id: 2, mealName: 'Bowl', venue: 'Library', entreePrice: 600),
    ];
    store.purchases = [
      PurchaseLog(
        id: 11,
        mealId: 1,
        actualPriceMinor: 450,
        purchasedAt: DateTime(2026, 1, 1),
        saveToken: 'one',
      ),
      PurchaseLog(
        id: 12,
        mealId: 2,
        actualPriceMinor: 600,
        purchasedAt: DateTime(2026, 1, 2),
        saveToken: 'two',
      ),
    ];
    return store;
  }

  testWidgets(
    'AJ History displays receipts and aggregate rather than catalog prices',
    (t) async {
      await t.binding.setSurfaceSize(const Size(800, 1500));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final store = fixture();
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MealHistory(
              store: store,
              onAdd: () {},
              onView: (_) {},
              onEdit: (_) {},
              onDelete: (_) {},
            ),
          ),
        ),
      );
      expect(
        find.text('2026-01-01 • Receipt #11', findRichText: true),
        findsNothing,
      );
      expect(find.textContaining('Receipt #11'), findsOneWidget);
      expect(find.text('\$10.50'), findsOneWidget);
      await t.tap(find.text('All meals'));
      await t.pumpAndSettle();
      await t.tap(find.text('Wrap').last);
      await t.pumpAndSettle();
      expect(find.textContaining('Receipt #12'), findsNothing);
      expect(
        t.widget<Text>(find.byKey(const Key('history-total'))).data,
        '\$4.50',
      );
    },
  );
  testWidgets('History actions pass the exact child row, not its parent', (
    t,
  ) async {
    await t.binding.setSurfaceSize(const Size(800, 1500));
    addTearDown(() => t.binding.setSurfaceSize(null));
    PurchaseLog? edited, removed, viewed;
    var added = false;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MealHistory(
            store: fixture(),
            onAdd: () => added = true,
            onView: (v) => viewed = v,
            onEdit: (v) => edited = v,
            onDelete: (v) => removed = v,
          ),
        ),
      ),
    );
    await t.tap(find.text('Edit purchase').first);
    expect(edited!.id, 11);
    expect(edited!.mealId, 1);
    await t.tap(find.text('View receipt').first);
    expect(viewed!.id, 11);
    await t.tap(find.text('Delete purchase').first);
    expect(removed!.id, 11);
    await t.tap(find.text('Add purchase'));
    expect(added, isTrue);
  });
  testWidgets(
    'Narrow History with enlarged text stays scrollable without overflow',
    (t) async {
      await t.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => t.binding.setSurfaceSize(null));
      await t.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 640),
              textScaler: TextScaler.linear(1.6),
            ),
            child: Scaffold(
              body: MealHistory(
                store: fixture(),
                onAdd: () {},
                onView: (_) {},
                onEdit: (_) {},
                onDelete: (_) {},
              ),
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      await t.scrollUntilVisible(
        find.byKey(const ValueKey('delete-purchase-11')),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(t.takeException(), isNull);
    },
  );
}
