import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';
import 'package:mobile/adapters/transport/driven/providers/transport_reservations_provider.dart';
import 'package:provider/provider.dart';

class TransportLocationSearchScreen extends StatefulWidget {
  const TransportLocationSearchScreen({super.key});

  @override
  State<TransportLocationSearchScreen> createState() => _TransportLocationSearchScreenState();
}

class _TransportLocationSearchScreenState extends State<TransportLocationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedLocation;

  // Datos simulados de ubicaciones
  final List<Map<String, String>> _locations = [
    {
      'name': 'Servicio de Urgencia Hospital Clínico Universidad',
      'address': 'Concepción, Chile',
    },
    {
      'name': 'Centro Médico Andes Salud Talca',
      'address': 'Talca, Chile',
    },
    {
      'name': 'Centro Médico Inmunomedica Talca',
      'address': 'Talca, Chile',
    },
  ];

  List<Map<String, String>> get _filteredLocations {
    if (_searchQuery.isEmpty) {
      return _locations;
    }
    return _locations.where((location) =>
        location['name']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        location['address']!.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  void _onLocationSelected(Map<String, String> location) {
    setState(() {
      _selectedLocation = '${location['name']} - ${location['address']}';
    });

    final provider = Provider.of<TransportReservationsProvider>(context, listen: false);
    provider.selectedLocation = location['name'];
    context.push('/transport/time-selection', extra: {'isOutbound': true});
  }

  void _searchMap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Búsqueda en mapa no implementada aún.')),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.light ? AppThemes.black_300 : AppThemes.black_900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: "Buscar campo clinico",
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: theme.brightness == Brightness.light ? AppThemes.black_700 : AppThemes.black_400),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _filteredLocations.isEmpty
                  ? const Center(child: Text('No se encontraron resultados'))
                  : ListView.builder(
                      itemCount: _filteredLocations.length,
                      itemBuilder: (context, index) {
                        final location = _filteredLocations[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: cs.outlineVariant),
                            boxShadow: [
                              BoxShadow(
                                color: AppThemes.black_1300.withValues(alpha: 0.1),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () => _onLocationSelected(location),
                            borderRadius: BorderRadius.circular(12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: AppThemes.primary_600,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(location['name']!, style: text.titleSmall),
                                      Text(location['address']!, style: text.bodySmall),
                                    ],
                                  ),
                                ),
                                if (_selectedLocation == '${location['name']} - ${location['address']}')
                                  const Icon(Icons.check, color: Colors.green),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _searchMap,
        label: const Text("Buscar en mapa"),
        icon: const Icon(Icons.map),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
