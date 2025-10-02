import 'package:flutter/material.dart';
import 'package:mobile/adapters/core/drivers/ui/widgets/custom_tab_item.dart';
import 'package:mobile/ports/auth/driven/for_authenticating_user.dart';
import 'package:mobile/service_locator.dart';

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
    final authService = serviceLocator<ForAuthenticatingUser>();
    final serviceId = authService.currentUser?.servicesId;

    return Row(
      spacing: 8.0,
      children: [
        CustomTabItem(currentIndex: currentIndex, onTap: onTap, index: 0, icon: Icons.credit_card_outlined, label: 'Credencial'),
        
        if (serviceId == 1 || serviceId == 3)
          CustomTabItem(currentIndex: currentIndex, onTap: onTap, index: 1, icon: Icons.airport_shuttle_outlined, label: 'Transporte'),
        
        if (serviceId == 2 || serviceId == 3)
          CustomTabItem(currentIndex: currentIndex, onTap: onTap, index: 2, icon: Icons.hotel_outlined, label: 'Alojamiento'),
      ],
    );
  }
}
