import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.green : AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppColors.green.withOpacity(0.35)
                        : Colors.black.withOpacity(0.07),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Icon(
                icon,
                color: isSelected ? AppColors.white : AppColors.green,
                size: 26,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
                color: isSelected ? AppColors.green : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}