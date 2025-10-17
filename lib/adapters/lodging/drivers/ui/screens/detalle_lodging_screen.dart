import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:mobile/adapters/core/driven/app_themes.dart';
import 'package:mobile/adapters/lodging/drivers/ui/widgets/image_carousel.dart';
import 'package:mobile/adapters/lodging/drivers/ui/widgets/section_title.dart';
import 'package:mobile/adapters/lodging/drivers/ui/widgets/service_item.dart';
import 'package:provider/provider.dart';
import 'package:mobile/adapters/lodging/driven/providers/lodging_provider.dart';
import 'package:mobile/domain/models/lodging/residencia_model.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mobile/service_locator.dart';
import 'package:mobile/adapters/core/driven/mapbox_service.dart';

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
    final mapService = serviceLocator<MapboxService>();
    mapService.dispose();
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

    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (residencia == null) {
      return const Scaffold(
        body: Center(child: Text('Residencia no encontrada')),
      );
    }

    // Fallback de imágenes si la residencia viene sin fotos.
    final images = (residencia!.images.isEmpty)
        ? const ['https://picsum.photos/seed/fallback/900/500']
        : residencia!.images.map((e) => e.url).toList();

    // Fallback de servicios si viene vacío.
    final services = (residencia!.availableServices.isEmpty)
        ? const <String>[]
        : residencia!.availableServices;

    const hPad = 16.0;
    const spacing = 12.0;
    final w = MediaQuery.of(context).size.width;
    final itemWidth = (w - (hPad * 2) - spacing) / 2;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: ui.Size.fromHeight(0), //  Sin barra superior
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
                        color: Colors.white,
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
                  indent: 16, // margen desde el borde izquierdo
                  endIndent: 16, // margen desde el borde derecho
                ),
              ),
              // Mapa Mapbox integrado
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: SectionTitle('Mapa'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 200,
                  child: MapWidget(
                    styleUri: MapboxService.mapStyles[0],
                    cameraOptions: CameraOptions(
                      center: Point(
                        coordinates: Position(
                          residencia!.longitude,
                          residencia!.latitude,
                        ),
                      ),
                      zoom: 14.0,
                    ),
                    onMapCreated: (mapboxMap) async {
                      final mapService = serviceLocator<MapboxService>();
                      mapService.initialize(mapboxMap);
                      await mapService.addResidenceMarker(
                        latitude: residencia!.latitude,
                        longitude: residencia!.longitude,
                      );
                    },
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
