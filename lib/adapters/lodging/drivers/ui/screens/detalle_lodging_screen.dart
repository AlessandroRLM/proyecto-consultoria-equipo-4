import 'package:flutter/material.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';
import 'package:mobile/adapters/lodging/drivers/ui/widgets/image_carousel.dart';
import 'package:mobile/adapters/lodging/drivers/ui/widgets/section_title.dart';
import 'package:mobile/adapters/lodging/drivers/ui/widgets/service_item.dart';
import 'package:provider/provider.dart';
import 'package:mobile/adapters/core/driven/header_provider.dart';

class HomeAlojamientoScreen extends StatefulWidget {
  const HomeAlojamientoScreen({super.key});

  @override
  State<HomeAlojamientoScreen> createState() => _HomeAlojamientoScreenState();
}

class _HomeAlojamientoScreenState extends State<HomeAlojamientoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HeaderProvider>().set(showChips: false);
    });
  }

  @override
  void dispose() {
    context.read<HeaderProvider>().reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    const images = [
      'https://picsum.photos/seed/lodge1/900/500',
      'https://picsum.photos/seed/lodge2/900/500',
      'https://picsum.photos/seed/lodge3/900/500',
    ];

    const hPad = 16.0;
    const spacing = 12.0;
    final w = MediaQuery.of(context).size.width;
    final itemWidth = (w - (hPad * 2) - spacing) / 2;

    return Scaffold(
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

              // Espaciado proporcional post imagen
              const SizedBox(height: 20),

              // Título + dirección
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Los Cipreses Residence',
                      style: text.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 19,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '1234 Evergreen Avenue, Santiago, Chile',
                      style: text.bodySmall?.copyWith(
                        color: text.bodyMedium?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Divider(height: 10),

              // Administrador
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Beatriz Salazar',
                      style: text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 15.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Administrador de Residencia',
                      style: text.bodySmall?.copyWith(
                        color: text.bodySmall?.color?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 10),
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
                  children: [
                    SizedBox(
                      width: itemWidth,
                      child: const ServiceItem(
                        icon: Icons.tv,
                        label: 'Televisión',
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: const ServiceItem(icon: Icons.wifi, label: 'Wifi'),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: const ServiceItem(
                        icon: Icons.water_drop,
                        label: 'Agua Caliente',
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: const ServiceItem(
                        icon: Icons.ac_unit,
                        label: 'Aire Acondicionado',
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: const ServiceItem(
                        icon: Icons.local_laundry_service,
                        label: 'Lavandería',
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: const ServiceItem(
                        icon: Icons.restaurant,
                        label: 'Comedor',
                      ),
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Divider(height: 10),
              ),

              // Mapa
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: SectionTitle('Mapa'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Center(
                    child: Text(
                      'Integrar mapa (Mapbox)',
                      style: text.bodySmall?.copyWith(
                        color: AppThemes.primary_600,
                        fontWeight: FontWeight.w600,
                      ),
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
