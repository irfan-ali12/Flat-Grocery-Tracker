import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/grocery_provider.dart';

void main() {
  runApp(const FlatGroceryTrackerApp());
}

class FlatGroceryTrackerApp extends StatelessWidget {
  const FlatGroceryTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF2E7D32);
    const backgroundColor = Color(0xFFF6FAF5);

    return ChangeNotifierProvider(
      create: (_) => GroceryProvider(),
      child: MaterialApp(
        title: 'Flat Grocery Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: backgroundColor,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          cardTheme: const CardThemeData(
            elevation: 0,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            extendedPadding: EdgeInsets.symmetric(horizontal: 20),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
