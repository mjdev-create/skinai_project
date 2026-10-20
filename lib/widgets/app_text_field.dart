import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final bool obscureText;
  final TextEditingController? controller; // NEW for Activity 9
  final String? Function(String?)? validator; // NEW for Activity 9

  const AppTextField({
    super.key,
    required this.label,
    this.obscureText = false,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        validator: validator,
        obscureText: obscureText,
        decoration: InputDecoration(labelText: label),
      );
}