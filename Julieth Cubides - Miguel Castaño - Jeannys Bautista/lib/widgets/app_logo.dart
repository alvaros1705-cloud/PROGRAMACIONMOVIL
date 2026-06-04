import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// App logo loaded from assets/images/logo.png.
class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Icon(
          Icons.people_alt_rounded,
          size: size * 0.8,
          color: AppColors.darkGreen,
        ),
      ),
    );
  }
}
