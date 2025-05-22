import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:brasserie_mob/components/header.dart';
import 'package:brasserie_mob/components/product_card.dart';
import 'package:brasserie_mob/pages/cart_page.dart';
import 'package:brasserie_mob/pages/orders_page.dart';
import 'package:brasserie_mob/pages/product_detail_page.dart';
import 'package:brasserie_mob/pages/products_page.dart';
import 'package:brasserie_mob/services/cart_service.dart';
import 'package:brasserie_mob/services/supabase_service.dart';
import 'package:brasserie_mob/services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> products = [];
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadLatestProducts();
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

  Future<void> _loadLatestProducts() async {
    final fetchedProducts = await SupabaseService.getLatestProducts();
    if (mounted) {
      setState(() {
        products = List<Map<String, dynamic>>.from(fetchedProducts);
      });
    }
  }

  Future<void> _loadUserName() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        userName = null;
      });
      return;
    }

    final response = await Supabase.instance.client
        .from('users')
        .select('first_name')
        .eq('id', user.id)
        .maybeSingle();

    if (mounted) {
      final firstName = response?['first_name'] as String?;
      setState(() {
        if (firstName != null && firstName.trim().isNotEmpty) {
          userName = firstName;
        } else {
          userName = user.email;
        }
      });
    }
  }

  void _onLogout() async {
    await AuthService().signOut();
    if (mounted) {
      setState(() {
        userName = null;
        _selectedIndex = 0;
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Déconnecté avec succès')),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const ProductsPage();
      case 2:
        return const CartPage();
      case 3:
        return const OrdersPage();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        Header(
          title: 'Accueil',
          userName: userName,
          onLogout: _onLogout,
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: products.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenue à la Brasserie Mob !',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Découvrez nos produits artisanaux. Naviguez à travers notre collection de bières, ajoutez-les à votre panier et passez vos commandes.",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Les derniers produits disponibles :',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              } else {
                final product = products[index - 1];
                return ProductCard(
                  product: product,
                  onView: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailPage(
                          product: product,
                          onAddToCart: () {
                            CartService().addProduct(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Produit ajouté au panier')),
                            );
                            setState(() {});
                          },
                        ),
                      ),
                    );
                  },
                  onAddToCart: () {
                    CartService().addProduct(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Produit ajouté au panier')),
                    );
                    setState(() {});
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      body: SafeArea(child: _buildPage(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF8B4513),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.green.shade200,
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Produits'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Panier'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Commandes'),
        ],
      ),
    );
  }
}
