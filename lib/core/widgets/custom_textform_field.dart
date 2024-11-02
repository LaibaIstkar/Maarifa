import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final bool obscureText;
  final int? maxLength; // Added maxLength parameter

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.obscureText = false,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      maxLength: maxLength, // Added maxLength
      style: const TextStyle(
        fontFamily: 'Poppins',
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black26, fontFamily: 'Poppins'),
        filled: true,
        fillColor: AppColors.primaryColorPlatinum,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
      ),
    );
  }
}
