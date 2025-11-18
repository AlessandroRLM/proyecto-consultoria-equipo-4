import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:mobile/adapters/core/driven/app_themes.dart';
import 'package:mobile/adapters/lodging/drivers/ui/widgets/image_carousel.dart';
import 'package:mobile/adapters/lodging/drivers/ui/widgets/section_title.dart';
import 'package:mobile/adapters/lodging/drivers/ui/widgets/service_item.dart';
import 'package:provider/provider.dart';
import 'package:mobile/adapters/lodging/driven/providers/lodging_provider.dart';
import 'package:mobile/domain/models/lodging/residencia_model.dart';
import 'package:mobile/service_locator.dart';
import 'package:mobile/ports/core/driven/for_managing_map.dart';
import 'package:mobile/domain/core/user_location.dart';

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
      final provider = context.read<LodgingProvider>();
      try {
        final data = await provider.fetchResidenceDetail(widget.homeId);
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
    // Limpieza del servicio de mapa
    if (serviceLocator.isRegistered<ForManagingMap>()) {
      serviceLocator<ForManagingMap>().dispose();
    }
    super.dispose();
  }

  // --- Normalizador y mapeo flexible de servicios --- //
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
      return const Scaffold(
        body: Center(child: Text('Residencia no encontrada')),
      );
    }

    // Servicio de mapa desde el service locator
    final mapService = serviceLocator<ForManagingMap>();

    // Estilos disponibles desde el servicio
    final styles = mapService.getAvailableStyles();
    String? styleUri;
    if (styles.isNotEmpty) {
      if (styles.length >= 2) {
        styleUri = isDark ? styles[1] : styles[0];
      } else {
        styleUri = styles.first;
      }
    }

    //  Fallback de imágenes si no vienen URLs
    final images = residencia!.images.isEmpty
        ? const <String>[]
        : residencia!.images.map((e) => e.url).toList();

    //  Fallback de servicios si viene vacío
    final services = (residencia!.availableServices.isEmpty)
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imagen con botón back
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
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              Icons.arrow_back,
                              size: 22,
                              color: isDark
                                  ? AppThemes.black_100
                                  : AppThemes.black_800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Título + dirección
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
                        color: text.bodyMedium?.color?.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Divider(
                height: 10,
                thickness: 1,
                indent: 16,
                endIndent: 16,
              ),

              // Administrador
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
                      'Administrador de Residencia',
                      style: text.bodySmall?.copyWith(
                        color: text.bodySmall?.color?.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 10,
                thickness: 1,
                indent: 16,
                endIndent: 16,
              ),

              const SizedBox(height: 5),

              // Servicios disponibles
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: SectionTitle('Servicios Disponibles'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: hPad),
                child: Wrap(
                  spacing: spacing,
                  runSpacing: 10,
                  children: _buildServiceItems(itemWidth, services),
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Divider(
                  height: 10,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                ),
              ),

              // Mapa usando ForManagingMap
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: SectionTitle('Mapa'),
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
                        // Inicializamos el mapa
                        mapService.initialize(mapInstance);

                        // Centramos en la residencia
                        await mapService.centerOnLocation(
                          UserLocation(
                            latitude: residencia!.latitude,
                            longitude: residencia!.longitude,
                            timestamp: DateTime.now(),
                          ),
                        );

                        // Agregamos un marcador en la residencia (sin usar residencia!.id)
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

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
