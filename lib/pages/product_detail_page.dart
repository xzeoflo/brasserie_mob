import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProductDetailPage extends StatelessWidget {
  final Map product;
  final VoidCallback onAddToCart;

  const ProductDetailPage({
    required this.product,
    required this.onAddToCart,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // beige clair
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B4513), // marron
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const Text('Détails du produit'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product['image_url'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product['image_url'],
                  height: size.height * 0.35,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            Text(
              product['name'] ?? 'Sans nom',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B4513),
              ),
            ),
            const SizedBox(height: 10),
            Text('Type : ${product['type'] ?? 'Inconnu'}', style: const TextStyle(fontSize: 18)),
            Text('Prix : ${product['price'] ?? '0'} €', style: const TextStyle(fontSize: 18)),
            Text('Degré d\'alcool : ${product['level'] ?? '-'} %', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAddToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Ajouter au panier', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
