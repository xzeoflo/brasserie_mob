import 'package:flutter/foundation.dart'; // pour debugPrint
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final client = Supabase.instance.client;

  // Récupérer les catégories
  static Future<List<Map<String, dynamic>>> getCategories() async {
    final res = await client.from('categories').select();
    return List<Map<String, dynamic>>.from(res);
  }

  // Récupérer les derniers produits
  static Future<List<Map<String, dynamic>>> getLatestProducts() async {
    final res = await client
        .from('products')
        .select('*, categories(type)')
        .order('id', ascending: false)
        .limit(5);

    return res.map((product) {
      final p = Map<String, dynamic>.from(product as Map);
      p['type'] = (p['categories'] as Map?)?['type'] ?? 'Inconnu';
      return p;
    }).toList();
  }

  // Récupérer les produits filtrés par recherche et catégorie
  static Future<List<Map<String, dynamic>>> getFilteredProducts(String query, int? categoryId) async {
    final queryBuilder = client.from('products').select('*, categories(type)');

    if (query.isNotEmpty) {
      queryBuilder.ilike('name', '%$query%');
    }
    if (categoryId != null) {
      queryBuilder.eq('category_id', categoryId);
    }

    final res = await queryBuilder;

    return res.map((product) {
      final p = Map<String, dynamic>.from(product as Map);
      p['type'] = (p['categories'] as Map?)?['type'] ?? 'Inconnu';
      return p;
    }).toList();
  }

  // --- COMMANDES ---

  // Récupérer les commandes de l'utilisateur connecté
  static Future<List<Map<String, dynamic>>> getUserOrders() async {
    final user = client.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await client
          .from('orders')
          .select()
          .eq('customer_id', user.id);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('Erreur getUserOrders: $e');
      return [];
    }
  }

  // Supprimer une commande par ID
  static Future<bool> deleteOrder(int orderId) async {
    try {
      final response = await client
          .from('orders')
          .delete()
          .eq('id', orderId);

      return response != null;
    } catch (e) {
      debugPrint('Erreur deleteOrder: $e');
      return false;
    }
  }

  // Récupérer les items d'une commande, avec infos produits (nom, prix)
  static Future<List<Map<String, dynamic>>> getOrderItems(int orderId) async {
    try {
      final response = await client
          .from('order_items')
          .select('quantity, product_id, products(name, price)')
          .eq('order_id', orderId);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      debugPrint('Erreur getOrderItems: $e');
      return [];
    }
  }
}
