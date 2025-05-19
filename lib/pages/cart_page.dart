import 'package:flutter/material.dart';
import 'package:brasserie_mob/pages/product_detail_page.dart';
import 'package:brasserie_mob/services/cart_service.dart';
import 'package:brasserie_mob/components/header.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService _cartService = CartService();
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final cartItems = _cartService.items;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      body: SafeArea(
        child: Column(
          children: [
            const Header(title: 'Mon Panier'),
            Expanded(
              child: cartItems.isEmpty
                  ? const Center(child: Text("Votre panier est vide."))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final product = cartItems[index];
                        return Card(
                          color: const Color(0xFFD2B48C),
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (product['image_url'] != null)
                                  Image.network(
                                    product['image_url'],
                                    height: 100,
                                    width: 80,
                                    fit: BoxFit.cover,
                                  ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'] ?? 'Sans nom',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                          'Type : ${product['type'] ?? 'Inconnu'}'),
                                      Text(
                                          'Prix : ${product['price'] ?? '0'} €'),
                                      Text(
                                          'Alcool : ${product['level'] ?? '-'} %'),
                                      const SizedBox(height: 8),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Contrôle de quantité
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.remove),
                                                onPressed: () {
                                                  setState(() {
                                                    if (product['quantity'] >
                                                        1) {
                                                      product['quantity'] -= 1;
                                                    } else {
                                                      _cartService.removeProduct(
                                                          product['id']);
                                                    }
                                                  });
                                                },
                                              ),
                                              Text('${product['quantity']}'),
                                              IconButton(
                                                icon: const Icon(Icons.add),
                                                onPressed: () {
                                                  setState(() {
                                                    product['quantity'] += 1;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProductDetailPage(
                                                        product: product,
                                                        onAddToCart: () {
                                                          _cartService
                                                              .addProduct(
                                                                  product);
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  'Produit ajouté au panier'),
                                                            ),
                                                          );
                                                          setState(() {});
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                },
                                                style:
                                                    ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                ),
                                                child: const Text('Voir'),
                                              ),
                                              const SizedBox(height: 8),
                                              ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _cartService.removeProduct(
                                                        product['id']);
                                                  });
                                                },
                                                style:
                                                    ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                ),
                                                child: const Text('Supprimer'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (cartItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () async {
                    final userId = _client.auth.currentUser?.id;

                    if (userId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vous devez être connecté.'),
                        ),
                      );
                      return;
                    }

                    final messenger = ScaffoldMessenger.of(context);

                    await _cartService.checkout(userId);

                    if (!mounted) return;

                    setState(() {}); // Rafraîchir la liste

                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Commande validée !'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  ),
                  child: const Text(
                    'Valider la commande',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
