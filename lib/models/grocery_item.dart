class GroceryItem {
  final int? rowIndex;
  final String timestamp;
  final String item;
  final int quantity;
  final double cost;
  final String boughtBy;

  const GroceryItem({
    this.rowIndex,
    required this.timestamp,
    required this.item,
    required this.quantity,
    required this.cost,
    required this.boughtBy,
  });

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      rowIndex: _parseNullableInt(json['rowIndex']),
      timestamp: json['timestamp']?.toString() ?? '',
      item: json['item']?.toString() ?? '',
      quantity: _parseInt(json['quantity']),
      cost: _parseDouble(json['cost']),
      boughtBy: json['boughtBy']?.toString() ?? '',
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
