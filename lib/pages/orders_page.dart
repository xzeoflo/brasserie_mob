import 'package:flutter/material.dart';
import 'package:brasserie_mob/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:brasserie_mob/pages/order_detail_page.dart';
import 'package:brasserie_mob/components/header.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List orders = [];
  bool isLoading = true;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _checkConnectionAndLoad();
  }

  Future<void> _checkConnectionAndLoad() async {
    final user = Supabase.instance.client.auth.currentUser;
    setState(() {
      isConnected = user != null;
    });

    if (isConnected) {
      await _loadOrders();
    } else {
      setState(() {
        isLoading = false;
        orders = [];
      });
    }
  }

  Future<void> _loadOrders() async {
    setState(() {
      isLoading = true;
    });

    final fetchedOrders = await SupabaseService.getUserOrders();
    setState(() {
      orders = fetchedOrders;
      isLoading = false;
    });
  }

  Future<void> _deleteOrder(int orderId) async {
    final success = await SupabaseService.deleteOrder(orderId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commande supprimée')),
      );
      _loadOrders();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la suppression')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      body: SafeArea(
        child: Column(
          children: [
            const Header(title: 'Mes Commandes'),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : !isConnected
                      ? const Center(
                          child: Text(
                            'Veuillez vous connecter pour voir vos commandes.',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : orders.isEmpty
                          ? const Center(child: Text('Aucune commande trouvée'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: orders.length,
                              itemBuilder: (context, index) {
                                final order = orders[index];
                                return Card(
                                  color: const Color(0xFFD2B48C), // style produit
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  elevation: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Commande #${order['id']}',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF8B4513),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Date : ${order['order_date']}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        Text(
                                          'Montant : ${order['total_amount']} €',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        Text(
                                          'Statut : ${order['status']}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () => _deleteOrder(order['id']),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.arrow_forward, color: Colors.green),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        OrderDetailPage(orderId: order['id']),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
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
