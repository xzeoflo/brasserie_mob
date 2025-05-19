import 'package:flutter/material.dart';

class CategoryFilter extends StatelessWidget {
  final List categories;
  final int? selectedCategoryId;
  final Function(int?) onChanged;

  const CategoryFilter({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DropdownButton<int?>(
        hint: const Text('Filtrer par catégorie'),
        value: selectedCategoryId,
        onChanged: (int? value) {
          onChanged(
            value,
          ); // Si value est null, on enlève le filtre de catégorie
        },
        items: [
          const DropdownMenuItem<int?>(value: null, child: Text('Tout')),
          // Affichage des catégories
          ...categories.map<DropdownMenuItem<int>>((category) {
            return DropdownMenuItem<int>(
              value: category['id'],
              child: Text(category['type']),
            );
          }),
        ],
      ),
    );
  }
}
