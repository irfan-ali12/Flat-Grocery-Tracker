import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flat_grocery_tracker/main.dart';
import 'package:flat_grocery_tracker/services/grocery_provider.dart';

void main() {
  testWidgets('Home screen shows app title', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => GroceryProvider(),
        child: const FlatGroceryTrackerApp(),
      ),
    );

    expect(find.text('Flat Grocery Tracker'), findsOneWidget);
  });
}
