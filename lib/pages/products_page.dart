import 'package:flutter/material.dart';
import 'package:brasserie_mob/components/category_filter.dart';
import 'package:brasserie_mob/components/search_bar.dart';
import 'package:brasserie_mob/components/product_card.dart';
import 'package:brasserie_mob/services/supabase_service.dart';
import 'package:brasserie_mob/pages/product_detail_page.dart';
import 'package:brasserie_mob/components/header.dart';
import 'package:brasserie_mob/services/cart_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:brasserie_mob/services/auth_service.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List products = [];
  List categories = [];
  String searchQuery = '';
  int? selectedCategoryId;
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadFilteredProducts();
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
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final response = await Supabase.instance.client
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

  Future<void> _loadCategories() async {
    final fetchedCategories = await SupabaseService.getCategories();
    if (!mounted) return;
    setState(() {
      categories = fetchedCategories;
    });
  }

  Future<void> _loadFilteredProducts() async {
    final fetchedProducts = await SupabaseService.getFilteredProducts(
      searchQuery,
      selectedCategoryId,
    );
    if (!mounted) return;
    setState(() {
      products = fetchedProducts;
    });
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      body: SafeArea(
        child: Column(
          children: [
            Header(
              title: 'Produits',
              userName: userName,
              onLogout: _onLogout,
            ),
            SearchBarComponent(
              searchText: searchQuery,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
                _loadFilteredProducts();
              },
            ),
            CategoryFilter(
              categories: categories,
              selectedCategoryId: selectedCategoryId,
              onChanged: (id) {
                setState(() {
                  selectedCategoryId = id;
                });
                _loadFilteredProducts();
              },
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
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
                                const SnackBar(content: Text('Produit ajouté au panier')),
                              );
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
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
