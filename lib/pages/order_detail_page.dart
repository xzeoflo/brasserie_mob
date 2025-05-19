import 'package:flutter/material.dart';
import 'package:brasserie_mob/services/supabase_service.dart';
import 'package:flutter/services.dart';

class OrderDetailPage extends StatefulWidget {
  final int orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  List orderItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrderItems();
  }

  Future<void> _loadOrderItems() async {
    final items = await SupabaseService.getOrderItems(widget.orderId);
    setState(() {
      orderItems = items;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B4513), // marron
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: Text('Détails commande #${widget.orderId}'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : orderItems.isEmpty
                ? const Center(child: Text('Aucun produit dans cette commande'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orderItems.length,
                    itemBuilder: (context, index) {
                      final item = orderItems[index];
                      final product = item['products'];
                      return Card(
                        color: const Color(0xFFD2B48C),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 3,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          title: Text(
                            product['name'] ?? 'Sans nom',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF8B4513),
                            ),
                          ),
                          subtitle: Text('Quantité : ${item['quantity']}'),
                          trailing: Text(
                            '${(product['price'] as num).toStringAsFixed(2)} €',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
