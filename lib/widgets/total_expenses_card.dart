import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TotalExpensesCard extends StatelessWidget {
  final double total;

  const TotalExpensesCard({super.key, required this.total});

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: 'Rs ',
      decimalDigits: amount == amount.roundToDouble() ? 0 : 2,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: theme.colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Expenses',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatCurrency(total),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
