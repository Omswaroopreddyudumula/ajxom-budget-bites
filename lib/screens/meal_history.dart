import 'package:flutter/material.dart';

import '../domain/money.dart';
import '../models/purchase_log.dart';
import '../state/app_store.dart';
import '../widgets/shared.dart';

/// Integrates A.J. Orea's Card/ListTile History page with the shared receipt data.
/// The parent owns navigation and destructive actions; this screen owns filters.
class MealHistory extends StatefulWidget {
  final AppStore store;
  final VoidCallback onAdd;
  final ValueChanged<PurchaseLog> onView, onEdit, onDelete;
  const MealHistory({
    required this.store,
    required this.onAdd,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });
  @override
  State<MealHistory> createState() => _MealHistoryState();
}

class _MealHistoryState extends State<MealHistory> {
  DateTimeRange? period;
  int? mealId;
  List<PurchaseLog> get filtered => widget.store.purchases.where((log) {
    final end = period == null
        ? null
        : DateTime(period!.end.year, period!.end.month, period!.end.day + 1);
    return (mealId == null || log.mealId == mealId) &&
        (period == null ||
            (!log.purchasedAt.isBefore(period!.start) &&
                log.purchasedAt.isBefore(end!)));
  }).toList();
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      // A catalog change must not leave a dropdown pointing at a deleted parent.
      final selected = widget.store.meals.any((meal) => meal.id == mealId)
          ? mealId
          : null;
      if (selected != mealId) mealId = selected;
      final logs = filtered;
      final total = logs.fold<int>(0, (sum, log) => sum + log.actualPriceMinor);
      return ListView.builder(
        key: const PageStorageKey('purchase-history'),
        padding: const EdgeInsets.all(20),
        itemCount: logs.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Purchase history',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Text('Your receipts, corrected whenever needed.'),
                const SizedBox(height: 20),
                DropdownButtonFormField<int>(
                  key: ValueKey(selected),
                  initialValue: selected ?? -1,
                  decoration: const InputDecoration(labelText: 'Meal filter'),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem(value: -1, child: Text('All meals')),
                    for (final meal in widget.store.meals)
                      DropdownMenuItem(
                        value: meal.id,
                        child: Text(meal.mealName),
                      ),
                  ],
                  onChanged: (value) =>
                      setState(() => mealId = value == -1 ? null : value),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        final range = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                          initialDateRange: period,
                        );
                        if (range != null && mounted) {
                          setState(() => period = range);
                        }
                      },
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        period == null
                            ? 'All dates'
                            : '${localDate(period!.start)} to ${localDate(period!.end)}',
                      ),
                    ),
                    if (period != null)
                      TextButton(
                        onPressed: () => setState(() => period = null),
                        child: const Text('Clear dates'),
                      ),
                    FilledButton.icon(
                      onPressed: widget.onAdd,
                      icon: const Icon(Icons.add),
                      label: const Text('Add purchase'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total spending',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          money(total),
                          key: const Key('history-total'),
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        Text(
                          '${logs.length} ${logs.length == 1 ? 'receipt' : 'receipts'} • selected meal and date filters',
                        ),
                      ],
                    ),
                  ),
                ),
                if (logs.isEmpty)
                  const EmptyView(
                    'No purchases yet',
                    'Record a purchase or change the filters.',
                  ),
              ],
            );
          }
          final log = logs[index - 1];
          final meal = widget.store.meal(log.mealId);
          final name = meal?.mealName ?? 'Missing meal';
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    isThreeLine: true,
                    leading: CircleAvatar(
                      child: Text(
                        name.isEmpty
                            ? '?'
                            : name.characters.first.toUpperCase(),
                      ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${meal?.venue ?? 'Unavailable venue'}\n${localDate(log.purchasedAt)} • Receipt #${log.id}',
                    ),
                    onTap: () => widget.onView(log),
                    onLongPress: () => widget.onEdit(log),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      money(log.actualPriceMinor),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (log.note.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Text(log.note),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Wrap(
                      spacing: 8,
                      children: [
                        TextButton(
                          onPressed: () => widget.onView(log),
                          child: const Text('View receipt'),
                        ),
                        TextButton(
                          onPressed: () => widget.onEdit(log),
                          child: const Text('Edit purchase'),
                        ),
                        TextButton.icon(
                          onPressed: () => widget.onDelete(log),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Delete purchase'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
