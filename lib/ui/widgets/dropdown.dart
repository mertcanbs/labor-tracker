import 'package:flutter/material.dart';

class MWDropdownFormField<T> extends StatelessWidget {
  const MWDropdownFormField({
    Key? key,
    required this.hint,
    required this.items,
    this.value,
    this.onChanged,
    this.validator,
    this.errorMessage,
    this.labelText,
    this.suffixIcon,
  }) : super(key: key);

  final Widget hint;
  final T? value;
  final Function(T?)? onChanged;
  final List<DropdownMenuItem<T>> items;
  final String? Function(T?)? validator;
  final String? errorMessage;
  final String? labelText;
  final IconData? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<T>(
          hint: hint,
          value: value,
          onChanged: onChanged,
          items: items,
          validator: validator,
          decoration: InputDecoration(
            errorText: errorMessage,
            helperText: ' ',
            labelText: labelText,
            suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
          ),
        ),
      ),
    );
  }
}
