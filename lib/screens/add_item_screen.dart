import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/grocery_item.dart';
import '../services/api_service.dart';
import '../services/grocery_provider.dart';

class AddItemScreen extends StatefulWidget {
  final GroceryItem? itemToEdit;

  const AddItemScreen({
    super.key,
    this.itemToEdit,
  });

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemController = TextEditingController();
  final _quantityController = TextEditingController();
  final _costController = TextEditingController();
  final _boughtByController = TextEditingController();

  bool _isSaving = false;

  bool get _isEditMode => widget.itemToEdit != null;

  @override
  void initState() {
    super.initState();

    final item = widget.itemToEdit;
    if (item != null) {
      _itemController.text = item.item;
      _quantityController.text = item.quantity.toString();
      _costController.text = item.cost == item.cost.roundToDouble()
          ? item.cost.toInt().toString()
          : item.cost.toString();
      _boughtByController.text = item.boughtBy;
    }
  }

  @override
  void dispose() {
    _itemController.dispose();
    _quantityController.dispose();
    _costController.dispose();
    _boughtByController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final provider = context.read<GroceryProvider>();
      final payloadItem = _itemController.text.trim();
      final payloadQuantity = int.parse(_quantityController.text.trim());
      final payloadCost = double.parse(_costController.text.trim());
      final payloadBoughtBy = _boughtByController.text.trim();

      if (_isEditMode) {
        final originalItem = widget.itemToEdit!;
        final rowIndex = widget.itemToEdit?.rowIndex;

        await provider.updateItem(
          rowIndex: rowIndex,
          originalItem: originalItem,
          item: payloadItem,
          quantity: payloadQuantity,
          cost: payloadCost,
          boughtBy: payloadBoughtBy,
        );
      } else {
        await provider.addItem(
          item: payloadItem,
          quantity: payloadQuantity,
          cost: payloadCost,
          boughtBy: payloadBoughtBy,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode
                ? 'Item updated successfully'
                : 'Item added successfully',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode
                ? 'Failed to update item. Please try again.'
                : 'Failed to add item. Please try again.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Item' : 'Add Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _itemController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Item name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Quantity is required';
                  }
                  final quantity = int.tryParse(value.trim());
                  if (quantity == null || quantity <= 0) {
                    return 'Quantity must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(
                  labelText: 'Cost',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Cost is required';
                  }
                  final cost = double.tryParse(value.trim());
                  if (cost == null || cost <= 0) {
                    return 'Cost must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _boughtByController,
                decoration: const InputDecoration(
                  labelText: 'Bought By',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Bought by is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditMode ? 'Save Changes' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
