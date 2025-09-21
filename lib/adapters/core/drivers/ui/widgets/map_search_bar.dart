import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MapSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSearching;
  final Function(String) onChanged;
  final VoidCallback onClear;

  const MapSearchBar({
    super.key,
    required this.controller,
    required this.isSearching,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Botón de volver
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          const SizedBox(width: 8.0),
          // Campo de búsqueda
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              height: 48,
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Buscar campo clínico',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: isSearching
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: onClear,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12.0),
                ),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}