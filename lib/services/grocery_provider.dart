import 'package:flutter/foundation.dart';

import '../models/grocery_item.dart';
import 'api_service.dart';

class GroceryProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<GroceryItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<GroceryItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalExpenses =>
      _items.fold(0.0, (sum, item) => sum + item.cost);

  Future<void> fetchItems() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _apiService.fetchItems();
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshItems() => fetchItems();

  Future<bool> addItem({
    required String item,
    required int quantity,
    required double cost,
    required String boughtBy,
  }) async {
    try {
      final success = await _apiService.addItem(
        item: item,
        quantity: quantity,
        cost: cost,
        boughtBy: boughtBy,
      );

      if (success) {
        await fetchItems();
      }

      return success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> updateItem({
    int? rowIndex,
    required GroceryItem originalItem,
    required String item,
    required int quantity,
    required double cost,
    required String boughtBy,
  }) async {
    try {
      final success = await _apiService.updateItem(
        rowIndex: rowIndex,
        originalTimestamp: originalItem.timestamp,
        originalItem: originalItem.item,
        originalQuantity: originalItem.quantity,
        originalCost: originalItem.cost,
        originalBoughtBy: originalItem.boughtBy,
        item: item,
        quantity: quantity,
        cost: cost,
        boughtBy: boughtBy,
      );

      if (success) {
        await fetchItems();
      }

      return success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      rethrow;
    }
  }
}
