import 'package:flutter/material.dart';

import '../domain/money.dart';
import '../models/meal.dart';
import '../models/purchase_log.dart';
import '../state/app_store.dart';
import '../widgets/shared.dart';
import 'meal_editor.dart';
import 'purchase_editor.dart';

class HomeScreen extends StatefulWidget {
  final AppStore store;
  const HomeScreen({required this.store, super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tab = 0;
  String search = '', cuisine = 'All';
  bool favorites = false;
  DateTimeRange? period;
  int? historyMeal;
  Future<void> editMeal([Meal? m]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MealEditor(store: widget.store, meal: m),
      ),
    );
  }

  Future<void> purchase({Meal? meal, PurchaseLog? log}) async {
    if (widget.store.meals.isEmpty) {
      feedback(context, 'Add a meal first.');
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PurchaseEditor(store: widget.store, mealId: meal?.id, log: log),
      ),
    );
  }

  Future<void> removeMeal(Meal m) async {
    try {
      final count = await widget.store.repository.linkedCount(m.id!);
      if (!mounted) return;
      if (count > 0) {
        feedback(
          context,
          '${m.mealName} has $count purchase(s). Delete or move them in History first.',
        );
        return;
      }
      if (!await confirm(
        context,
        'Delete meal?',
        'Delete ${m.mealName}? This cannot be undone.',
      )) {
        return;
      }
      await widget.store.repository.deleteMeal(m.id!);
      await widget.store.refresh();
    } catch (e) {
      if (mounted) feedback(context, 'Meal could not be deleted. $e');
    }
  }

  Future<void> favorite(Meal m) async {
    try {
      await widget.store.repository.updateMeal(m.withFavorite(!m.favorite));
      await widget.store.refresh();
    } catch (e) {
      if (mounted) feedback(context, 'Favorite was not saved. $e');
    }
  }

  Widget catalog() {
    final meals = widget.store.meals
        .where(
          (m) =>
              (!favorites || m.favorite) &&
              (cuisine == 'All' || m.cuisine == cuisine) &&
              '${m.mealName} ${m.venue}'.toLowerCase().contains(
                search.toLowerCase(),
              ),
        )
        .toList();
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good food. Clear spending.',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your lunch budget: ${money(widget.store.budget)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'A personal offline notebook. Starter venues and prices are fictional examples.',
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search meals or venue notes',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (v) => setState(() => search = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: cuisine,
                  decoration: const InputDecoration(
                    labelText: 'Cuisine filter',
                  ),
                  items: [
                    for (final v in ['All', ...cuisines])
                      DropdownMenuItem(value: v, child: Text(v)),
                  ],
                  onChanged: (v) => setState(() => cuisine = v!),
                ),
                const SizedBox(height: 12),
                FilterChip(
                  label: const Text('Favorites only'),
                  selected: favorites,
                  onSelected: (v) => setState(() => favorites = v),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => editMeal(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add meal'),
                ),
              ],
            ),
          ),
        ),
        if (meals.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyView(
              'No meals found',
              'Add a meal or clear your filters.',
              action: TextButton(
                onPressed: () => setState(() {
                  cuisine = 'All';
                  favorites = false;
                  search = '';
                }),
                child: const Text('Clear filters'),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList.builder(
              itemCount: meals.length,
              itemBuilder: (c, i) {
                final m = meals[i];
                return Column(
                  children: [
                    GestureDetector(
                      onHorizontalDragEnd: (_) => editMeal(m),
                      child: MealCard(
                        meal: m,
                        budget: widget.store.budget,
                        onView: () => purchase(meal: m),
                        onEdit: () => editMeal(m),
                        onFavorite: () => favorite(m),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => removeMeal(m),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete meal'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  List<PurchaseLog> get visibleLogs => widget.store.purchases
      .where(
        (l) =>
            (historyMeal == null || l.mealId == historyMeal) &&
            (period == null ||
                (!l.purchasedAt.isBefore(period!.start) &&
                    l.purchasedAt.isBefore(
                      period!.end.add(const Duration(days: 1)),
                    ))),
      )
      .toList();
  Future<void> deleteLog(PurchaseLog l) async {
    if (!await confirm(
      context,
      'Delete purchase?',
      'Remove this ${money(l.actualPriceMinor)} receipt? Totals and Lunch Lens will refresh.',
    )) {
      return;
    }
    try {
      await widget.store.repository.deletePurchase(l.id!);
      await widget.store.refresh();
    } catch (e) {
      if (mounted) feedback(context, 'Purchase could not be deleted. $e');
    }
  }

  Future<void> inspectLog(PurchaseLog l) async {
    await showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(widget.store.meal(l.mealId)?.mealName ?? 'Meal'),
        content: Text(
          'Receipt #${l.id}\n${money(l.actualPriceMinor)}\n${localDate(l.purchasedAt)} ${TimeOfDay.fromDateTime(l.purchasedAt).format(c)}\n${l.note.isEmpty ? 'No note' : l.note}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget history() {
    final logs = visibleLogs;
    final total = logs.fold<int>(0, (s, l) => s + l.actualPriceMinor);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Purchase history',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text('Your receipts, corrected whenever needed.'),
        const SizedBox(height: 20),
        DropdownButtonFormField<int>(
          initialValue: historyMeal ?? -1,
          decoration: const InputDecoration(labelText: 'Meal filter'),
          items: [
            const DropdownMenuItem(value: -1, child: Text('All meals')),
            for (final m in widget.store.meals)
              DropdownMenuItem(value: m.id, child: Text(m.mealName)),
          ],
          onChanged: (v) => setState(() => historyMeal = v == -1 ? null : v),
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
                if (range != null && mounted) setState(() => period = range);
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
              onPressed: () => purchase(),
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
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                Text(
                  '${logs.length} receipts • selected meal and date filters',
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
        for (final l in logs)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => inspectLog(l),
                    onLongPress: () => purchase(log: l),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.store.meal(l.mealId)?.mealName ??
                                      'Meal',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  '${localDate(l.purchasedAt)} • Receipt #${l.id}',
                                ),
                              ],
                            ),
                          ),
                          Text(
                            money(l.actualPriceMinor),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (l.note.isNotEmpty) Text(l.note),
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton(
                        onPressed: () => inspectLog(l),
                        child: const Text('View receipt'),
                      ),
                      TextButton(
                        onPressed: () => purchase(log: l),
                        child: const Text('Edit purchase'),
                      ),
                      TextButton(
                        onPressed: () => deleteLog(l),
                        child: const Text('Delete purchase'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget settings() => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text('Make it yours', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 8),
      const Text('Preferences stay on this device.'),
      const SizedBox(height: 24),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Default lunch budget',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                money(widget.store.budget),
                style: Theme.of(context).textTheme.displaySmall,
              ),
              _BudgetSlider(store: widget.store),
              const Text(
                'USD 0–30, in 50-cent steps. Existing receipts are unchanged.',
              ),
            ],
          ),
        ),
      ),
      SwitchListTile(
        title: const Text('Dark mode'),
        subtitle: const Text('Saved display preference'),
        value: widget.store.dark,
        onChanged: (v) async {
          try {
            await widget.store.saveDark(v);
          } catch (e) {
            if (mounted) feedback(context, e);
          }
        },
      ),
      const Divider(),
      const ListTile(
        leading: Icon(Icons.lock_outline),
        title: Text('Offline by design'),
        subtitle: Text(
          'Meals and purchases use SQLite. Preferences use on-device storage. No account, live listings or cloud inference.',
        ),
      ),
      const ListTile(
        title: Text('AjxOm • Budget Bites'),
        subtitle: Text(
          'A personal planning estimate is not a guaranteed venue price.',
        ),
      ),
    ],
  );
  @override
  Widget build(BuildContext c) => ListenableBuilder(
    listenable: widget.store,
    builder: (c, _) {
      final s = widget.store;
      return Scaffold(
        appBar: AppBar(
          title: const Text('Budget Bites'),
          actions: [
            IconButton(
              tooltip: 'Refresh notebook',
              onPressed: s.busy ? null : s.load,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: s.busy && !s.loaded
            ? const Center(child: CircularProgressIndicator())
            : s.error != null
            ? EmptyView(
                'Notebook unavailable',
                s.error!,
                action: FilledButton(
                  onPressed: s.load,
                  child: const Text('Retry'),
                ),
              )
            : Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: [catalog, history, settings][tab](),
                ),
              ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (v) => setState(() => tab = v),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.restaurant_menu),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long),
              label: 'History',
            ),
            NavigationDestination(icon: Icon(Icons.tune), label: 'Settings'),
          ],
        ),
      );
    },
  );
}

class _BudgetSlider extends StatefulWidget {
  final AppStore store;
  const _BudgetSlider({required this.store});
  @override
  State<_BudgetSlider> createState() => _BudgetSliderState();
}

class _BudgetSliderState extends State<_BudgetSlider> {
  double? draft;
  bool saving = false;
  @override
  Widget build(BuildContext c) => Column(
    children: [
      Text(
        'Selected ${money((draft ?? widget.store.budget.toDouble()).round())}',
      ),
      Slider(
        value: draft ?? widget.store.budget.toDouble(),
        min: 0,
        max: 3000,
        divisions: 60,
        label: money((draft ?? widget.store.budget.toDouble()).round()),
        onChanged: saving ? null : (v) => setState(() => draft = v),
        onChangeEnd: (v) async {
          setState(() => saving = true);
          try {
            await widget.store.saveBudget(v.round());
            if (c.mounted) feedback(c, 'Budget saved locally.');
          } catch (e) {
            if (c.mounted) {
              feedback(c, 'Budget not saved. Adjust the slider to retry. $e');
            }
          } finally {
            if (mounted) {
              setState(() {
                saving = false;
                draft = null;
              });
            }
          }
        },
      ),
      if (saving) const Text('Saving preference...'),
    ],
  );
}
