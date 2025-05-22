import 'package:flutter/material.dart';
import 'package:brasserie_mob/pages/product_detail_page.dart';
import 'package:brasserie_mob/services/cart_service.dart';
import 'package:brasserie_mob/components/header.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:brasserie_mob/services/auth_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService _cartService = CartService();
  final SupabaseClient _client = Supabase.instance.client;

  String? userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.session?.user != null) {
        _loadUserName();
      } else {
        setState(() {
          userName = null;
        });
      }
    });
  }

  Future<void> _loadUserName() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final response = await _client
        .from('users')
        .select('first_name')
        .eq('id', user.id)
        .maybeSingle();

    if (mounted) {
      setState(() {
        userName = response?['first_name'] ?? user.email;
      });
    }
  }

  void _onLogout() async {
    await AuthService().signOut();
    if (mounted) {
      setState(() {
        userName = null;
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Déconnecté avec succès')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = _cartService.items;

    int totalQuantity = cartItems.fold(
        0, (sum, item) => sum + (item['quantity'] as int? ?? 1));

    double totalPrice = cartItems.fold(0.0, (sum, item) {
      final price = (item['price'] as num?)?.toDouble() ?? 0.0;
      final qty = item['quantity'] as int? ?? 1;
      return sum + price * qty;
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      body: SafeArea(
        child: Column(
          children: [
            Header(
              title: 'Mon Panier',
              userName: userName,
              onLogout: _onLogout,
            ),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Total : $totalQuantity produits - ${totalPrice.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
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

                        setState(() {}); // Refresh cart

                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Commande validée !'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 24),
                      ),
                      child: const Text(
                        'Valider la commande',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
