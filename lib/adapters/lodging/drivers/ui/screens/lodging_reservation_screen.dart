// lodging_reservation_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';
import 'package:mobile/adapters/lodging/driven/providers/lodging_availability_provider.dart';
import 'package:mobile/adapters/lodging/drivers/ui/screens/lodging_map_screen.dart';

class LodgingReservationScreen extends StatefulWidget {
  const LodgingReservationScreen({super.key});
  @override
  State<LodgingReservationScreen> createState() =>
      _LodgingReservationScreenState();
}

class _LodgingReservationScreenState extends State<LodgingReservationScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<int> _visible = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilter);
  }

  void _applyFilter() {
    final q = _searchController.text.trim().toLowerCase();
    final items = context.read<LodgingAvailabilityProvider>().items;
    setState(() {
      if (q.isEmpty) {
        _visible = List<int>.generate(items.length, (i) => i);
      } else {
        _visible = [];
        for (int i = 0; i < items.length; i++) {
          final it = items[i];
          if (it.clinicName.toLowerCase().contains(q) ||
              it.residenceName.toLowerCase().contains(q) ||
              it.city.toLowerCase().contains(q) ||
              it.address.toLowerCase().contains(q)) {
            _visible.add(i);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final p = context.watch<LodgingAvailabilityProvider>();
    final items = p.items;

    if (_visible.isEmpty &&
        items.isNotEmpty &&
        _searchController.text.isEmpty) {
      _visible = List<int>.generate(items.length, (i) => i);
    }

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 4),
                Text("Reservar", style: text.titleLarge),
              ],
            ),
          ),

          // 🔹 Buscador
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppThemes.black_400, // foundation black 4
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Buscar campo clínico",
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.search,
                    color: AppThemes.black_800,
                  ), // black 5
                ),
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: () {
                if (p.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (p.error != null) {
                  return Center(
                    child: Text(
                      'Error: ${p.error}',
                      style: text.bodyMedium?.copyWith(color: cs.error),
                    ),
                  );
                }
                if (items.isEmpty || _visible.isEmpty) {
                  return const Center(child: Text('Sin resultados'));
                }
                return ListView.builder(
                  itemCount: _visible.length,
                  itemBuilder: (_, i) {
                    final it = items[_visible[i]];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cs.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: cs.shadow.withOpacity(0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_hospital,
                            color: AppThemes.primary_600,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(it.clinicName, style: text.titleSmall),
                                if (it.city.isNotEmpty)
                                  Text(it.city, style: text.bodySmall),
                                Text(it.address, style: text.bodySmall),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const LodgingMapScreen()));
        },
        label: const Text("Buscar en mapa"),
        icon: const Icon(Icons.map),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
