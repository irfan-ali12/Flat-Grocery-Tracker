import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/grocery_provider.dart';
import '../models/grocery_item.dart';
import '../widgets/empty_state.dart';
import '../widgets/grocery_item_card.dart';
import '../widgets/total_expenses_card.dart';
import 'add_item_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroceryProvider>().fetchItems();
    });
  }

  Future<void> _navigateToAddItem() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddItemScreen()),
    );
  }

  Future<void> _navigateToEditItem(GroceryItem item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddItemScreen(itemToEdit: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flat Grocery Tracker'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddItem,
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
      body: Consumer<GroceryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.items.isEmpty) {
            return _ErrorView(
              message: provider.errorMessage!,
              onRetry: provider.fetchItems,
            );
          }

          return RefreshIndicator(
            onRefresh: provider.refreshItems,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: TotalExpensesCard(total: provider.totalExpenses),
                ),
                if (provider.isLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                if (provider.errorMessage != null && provider.items.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: MaterialBanner(
                        content: Text(provider.errorMessage!),
                        actions: [
                          TextButton(
                            onPressed: provider.fetchItems,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (provider.items.isEmpty && !provider.isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = provider.items[index];
                        return GroceryItemCard(
                          item: item,
                          onEdit: () => _navigateToEditItem(item),
                        );
                      },
                      childCount: provider.items.length,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 88)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
