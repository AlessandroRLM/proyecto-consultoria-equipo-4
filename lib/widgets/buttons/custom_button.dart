import 'package:flutter/material.dart';
import '../utils/theme.dart';

enum ButtonSize { xs, sm, md, lg }

enum ButtonStatus { normal, pressed, disabled }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonSize size;
  final ButtonStatus status;
  final IconData? icon;
  final bool iconRight;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.size = ButtonSize.md,
    this.status = ButtonStatus.normal,
    this.icon,
    this.iconRight = false,
  }) : super(key: key);

  double getFontSize(ButtonSize size) {
    switch (size) {
      case ButtonSize.xs:
        return 14; // 12 + 2
      case ButtonSize.sm:
        return 16; // 14 + 2
      case ButtonSize.md:
        return 18; // 16 + 2
      case ButtonSize.lg:
        return 20; // 18 + 2
    }
  }

  EdgeInsets getPadding(ButtonSize size) {
    switch (size) {
      case ButtonSize.xs:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case ButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case ButtonSize.md:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 14);
      case ButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 18);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = status == ButtonStatus.disabled;
    final isPressed = status == ButtonStatus.pressed;

    final backgroundColor = isPressed
        ? Colors.white
        : isDisabled
        ? AppThemes.black_500
        : AppThemes.primary_600;

    final foregroundColor = isPressed
        ? AppThemes.primary_600
        : isDisabled
        ? AppThemes.black_700
        : AppThemes.black_100;

    final borderSide = isPressed
        ? BorderSide(color: AppThemes.primary_600, width: 2)
        : BorderSide.none;

    // Aquí definimos el borderRadius según el tamaño
    final borderRadius = (size == ButtonSize.xs || size == ButtonSize.sm)
        ? BorderRadius.circular(6)
        : BorderRadius.circular(12);

    return Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: getPadding(size),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: borderSide,
          ),
          minimumSize: const Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: isDisabled ? null : onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null && !iconRight)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(icon, size: getFontSize(size)),
              ),
            Text(text, style: TextStyle(fontSize: getFontSize(size))),
            if (icon != null && iconRight)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(icon, size: getFontSize(size)),
              ),
          ],
        ),
      ),
    );
  }
}
