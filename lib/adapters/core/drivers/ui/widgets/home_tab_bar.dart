import 'package:flutter/material.dart';
import 'package:mobile/adapters/core/drivers/ui/widgets/custom_tab_item.dart';

class HomeTabBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const HomeTabBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8.0,
      children: [
        CustomTabItem(currentIndex: currentIndex, onTap: onTap, index: 0, icon: Icons.credit_card_outlined, label: 'Credencial'),
        CustomTabItem(currentIndex: currentIndex, onTap: onTap, index: 1, icon: Icons.airport_shuttle_outlined, label: 'Transporte'),
        CustomTabItem(currentIndex: currentIndex, onTap: onTap, index: 2, icon: Icons.hotel_outlined, label: 'Alojamiento'),
      ],
    );
  }
}
