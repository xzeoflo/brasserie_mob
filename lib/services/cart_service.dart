import 'supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  void addProduct(Map<String, dynamic> product) {
    final existing = _items.indexWhere((item) => item['id'] == product['id']);
    if (existing != -1) {
      _items[existing]['quantity'] += 1;
    } else {
      _items.add({...product, 'quantity': 1});
    }
  }

  void removeProduct(int productId) {
    _items.removeWhere((item) => item['id'] == productId);
  }

  void clearCart() {
    _items.clear();
  }

  Future<void> checkout(String userId) async {
    final SupabaseClient client = SupabaseService.client;

    final total = _items.fold<double>(
      0,
      (sum, item) => sum + (item['price'] as num) * item['quantity'],
    );

    final orderResponse = await client.from('orders').insert({
      'order_date': DateTime.now().toIso8601String(),
      'customer_id': userId,
      'total_amount': total,
      'status': 'pending',
    }).select().single();

    final orderId = orderResponse['id'];

    for (var item in _items) {
      await client.from('order_items').insert({
        'order_id': orderId,
        'product_id': item['id'],
        'quantity': item['quantity'],
      });
    }

    clearCart();
  }
}
