import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:mobile/adapters/core/driven/app_themes.dart';
import 'package:mobile/adapters/lodging/drivers/ui/widgets/image_carousel.dart';
import 'package:mobile/adapters/lodging/drivers/ui/widgets/section_title.dart';
import 'package:mobile/adapters/lodging/drivers/ui/widgets/service_item.dart';
import 'package:mobile/domain/models/lodging/residencia_model.dart';
import 'package:mobile/service_locator.dart';
import 'package:mobile/ports/core/driven/for_managing_map.dart';
import 'package:mobile/domain/core/user_location.dart';
import 'package:mobile/ports/lodging/driven/for_querying_lodging.dart';
import 'package:go_router/go_router.dart';

class HomeAlojamientoScreen extends StatefulWidget {
  final int homeId;
  const HomeAlojamientoScreen({super.key, required this.homeId});

  @override
  State<HomeAlojamientoScreen> createState() => _HomeAlojamientoScreenState();
}

class _HomeAlojamientoScreenState extends State<HomeAlojamientoScreen> {
  ResidenciaModel? residencia;
  bool loading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final lodgingService = serviceLocator<ForQueryingLodging>();

      try {
        final data = await lodgingService.getResidenceById(widget.homeId);

        if (!mounted) return;
        setState(() {
          residencia = data;
          loading = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() => loading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar residencia: $e')),
        );
      }
    });
  }

  @override
  void dispose() {
    if (serviceLocator.isRegistered<ForManagingMap>()) {
      serviceLocator<ForManagingMap>().dispose();
    }
    super.dispose();
  }

  String _norm(String s) => s.toLowerCase().trim();

  MapEntry<IconData, String> _mapService(String raw) {
    final k = _norm(raw);

    if (['television', 'tv', 't.v.', 'televisión'].contains(k)) {
      return const MapEntry(Icons.tv, 'Televisión');
    }
    if (['wifi', 'wi-fi', 'internet'].contains(k)) {
      return const MapEntry(Icons.wifi, 'Wifi');
    }
    if (['hot water', 'agua caliente', 'water heater'].contains(k)) {
      return const MapEntry(Icons.water_drop, 'Agua Caliente');
    }
    if (['heating', 'calefaccion', 'calefacción', 'heater'].contains(k)) {
      return const MapEntry(Icons.local_fire_department, 'Calefacción');
    }
    if (['laundry', 'lavanderia', 'lavandería'].contains(k)) {
      return const MapEntry(Icons.local_laundry_service, 'Lavandería');
    }
    if (['dining room', 'comedor', 'meal room'].contains(k)) {
      return const MapEntry(Icons.restaurant, 'Comedor');
    }

    return MapEntry(Icons.check_circle_outline, raw);
  }

  List<Widget> _buildServiceItems(double itemWidth, List<String> services) {
    return services.map((raw) {
      final entry = _mapService(raw);
      return SizedBox(
        width: itemWidth,
        child: ServiceItem(icon: entry.key, label: entry.value),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (residencia == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Residencia no encontrada"),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go('/lodging'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    final mapService = serviceLocator<ForManagingMap>();

    final styles = mapService.getAvailableStyles();
    String? styleUri;

    if (styles.isNotEmpty) {
      if (styles.length >= 2) {
        styleUri = isDark ? styles[1] : styles[0];
      } else {
        styleUri = styles.first;
      }
    }

    final images = residencia!.images.isEmpty
        ? const <String>[]
        : residencia!.images.map((e) => e.url).toList();

    final services = residencia!.availableServices.isEmpty
        ? const <String>[]
        : residencia!.availableServices;

    const hPad = 16.0;
    const spacing = 12.0;

    final w = MediaQuery.of(context).size.width;
    final itemWidth = (w - (hPad * 2) - spacing) / 2;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: ui.Size.fromHeight(0),
        child: AppBar(elevation: 0, backgroundColor: Colors.transparent),
      ),
      backgroundColor: cs.surface,

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Alojamiento confirmado")),
              );
              context.go('/lodging');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 3,
            ),
            child: const Text(
              "Confirmar Reserva",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 220,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ImageCarousel(imageUrls: images, height: 220),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Material(
                        color: isDark
                            ? AppThemes.black_1100
                            : AppThemes.black_100,
                        borderRadius: BorderRadius.circular(10),
                        elevation: 1.5,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => Navigator.pop(context),
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(Icons.arrow_back, size: 22),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      residencia!.residenceName,
                      style: text.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 19,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      residencia!.address,
                      style: text.bodySmall?.copyWith(
                        color: text.bodySmall?.color?.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Divider(indent: 16, endIndent: 16),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      residencia!.residenceManager,
                      style: text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 15.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "Administrador de Residencia",
                      style: text.bodySmall?.copyWith(
                        color: text.bodySmall?.color?.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(indent: 16, endIndent: 16),

              const SizedBox(height: 10),

              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: SectionTitle("Servicios Disponibles"),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: hPad),
                child: Wrap(
                  spacing: spacing,
                  runSpacing: 10,
                  children: _buildServiceItems(itemWidth, services),
                ),
              ),

              const SizedBox(height: 10),
              const Divider(indent: 16, endIndent: 16),

              const Padding(
                padding: EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: SectionTitle("Mapa"),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 200,
                    child: mapService.buildMapWidget(
                      styleUri: styleUri,
                      initialZoom: 14.0,
                      initialLatitude: residencia!.latitude,
                      initialLongitude: residencia!.longitude,
                      onMapCreated: (mapInstance) async {
                        mapService.initialize(mapInstance);

                        await mapService.centerOnLocation(
                          UserLocation(
                            latitude: residencia!.latitude,
                            longitude: residencia!.longitude,
                            timestamp: DateTime.now(),
                          ),
                        );

                        await mapService.addMarker(
                          latitude: residencia!.latitude,
                          longitude: residencia!.longitude,
                          label: residencia!.residenceName,
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
