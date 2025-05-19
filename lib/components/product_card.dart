import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final Map product;
  final VoidCallback onView;
  final VoidCallback? onAddToCart;
  final VoidCallback? onRemoveFromCart;

  const ProductCard({
    required this.product,
    required this.onView,
    this.onAddToCart,
    this.onRemoveFromCart,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFD2B48C),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product['image_url'] != null)
              Image.network(
                product['image_url'],
                height: 150,
                width: 100,
                fit: BoxFit.cover,
              ),
            const SizedBox(width: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double maxButtonWidth = constraints.maxWidth * 0.45;
                  maxButtonWidth = maxButtonWidth < 100 ? 100 : maxButtonWidth;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'] ?? 'Sans nom',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Type : ${product['type'] ?? 'Inconnu'}'),
                      Text('Prix : ${product['price'] ?? '0'} €'),
                      Text('Alcool : ${product['level'] ?? '-'} %'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          SizedBox(
                            width: maxButtonWidth,
                            child: TextButton(
                              onPressed: onView,
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.green,
                              ),
                              child: const Text('Voir'),
                            ),
                          ),
                          if (onAddToCart != null)
                            SizedBox(
                              width: maxButtonWidth,
                              child: ElevatedButton(
                                onPressed: onAddToCart,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Ajouter'),
                              ),
                            ),
                        ],
                      ),
                      if (onRemoveFromCart != null) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: maxButtonWidth,
                          child: ElevatedButton(
                            onPressed: onRemoveFromCart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Supprimer'),
                          ),
                        ),
                      ],
                    ],
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
