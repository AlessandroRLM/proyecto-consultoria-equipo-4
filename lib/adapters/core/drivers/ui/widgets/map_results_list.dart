import 'package:flutter/material.dart';
import 'package:mobile/adapters/core/driven/app_themes.dart';
import 'package:mobile/domain/core/campus.dart';

class MapResultsList extends StatelessWidget {
  final List<Campus> campusList;
  final Function(Campus) onCampusSelected;

  const MapResultsList({
    super.key,
    required this.campusList,
    required this.onCampusSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(64.0, 0, 8.0, 0),
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
      constraints: const BoxConstraints(maxHeight: 220),
      child: campusList.isEmpty
          ? const ListTile(
              title: Text('No se encontraron resultados'),
              leading: Icon(Icons.info_outline),
            )
          : ListView.separated(
              shrinkWrap: true,
              itemCount: campusList.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final campus = campusList[index];
                return ListTile(
                  title: Text(campus.name),
                  subtitle: Text('${campus.commune}, ${campus.city}'),
                  leading: const Icon(
                    Icons.local_hospital,
                    color: AppThemes.primary_600,
                  ),
                  onTap: () => onCampusSelected(campus),
                );
              },
            ),
    );
  }
}