import 'package:flutter/material.dart';

class SearchBarComponent extends StatelessWidget {
  final String searchText;
  final ValueChanged<String> onChanged;

  const SearchBarComponent({
    super.key,
    required this.searchText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'Rechercher...',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onChanged: onChanged,
        controller: TextEditingController(text: searchText),
      ),
    );
  }
}
