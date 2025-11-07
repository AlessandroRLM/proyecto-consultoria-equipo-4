import 'package:flutter/material.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';

class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;

  const ImageCarousel({super.key, required this.imageUrls, this.height = 200});

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _errorPlaceholder(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? AppThemes.black_1000 : Colors.grey.shade200,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 40,
            color: isDark ? AppThemes.black_600 : Colors.black54,
          ),
          const SizedBox(height: 6),
          Text(
            'Imagen no disponible',
            style: text.bodySmall?.copyWith(
              color: isDark ? AppThemes.black_600 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls.isEmpty ? const <String>[] : widget.imageUrls;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color pillBg = isDark
        ? AppThemes.black_1100
        : AppThemes.black_100; // fondo contenedor
    final Color pillShadow = isDark
        ? Colors.black.withOpacity(0.30)
        : Colors.black.withOpacity(0.08);
    final Color dotActive = isDark
        ? AppThemes.black_100
        : AppThemes.black_800; // activo
    final Color dotInactive = isDark
        ? AppThemes.black_700
        : AppThemes.black_600; // inactivo

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: widget.height,
          width: double.infinity,
          child: PageView.builder(
            controller: _controller,
            itemCount: urls.isEmpty ? 1 : urls.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              if (urls.isEmpty) return _errorPlaceholder(context);
              return Image.network(
                urls[index],
                fit: BoxFit.cover,
                width: double.infinity,
                loadingBuilder: (c, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: Colors.grey.shade100,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  );
                },
                errorBuilder: (c, _, __) => _errorPlaceholder(c),
              );
            },
          ),
        ),

        // Indicadores
        Positioned(
          bottom: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
            decoration: BoxDecoration(
              color: pillBg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: pillShadow,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate((urls.isEmpty ? 1 : urls.length), (
                index,
              ) {
                final bool isActive = index == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? dotActive : dotInactive,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
