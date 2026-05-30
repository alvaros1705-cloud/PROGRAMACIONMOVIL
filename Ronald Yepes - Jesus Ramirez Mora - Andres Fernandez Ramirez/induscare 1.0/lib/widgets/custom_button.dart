import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return OutlinedButton(
        onPressed: onPressed,
        child: Text(label),
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
