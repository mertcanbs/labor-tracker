import 'package:flutter/material.dart';

class MWTextFormField extends StatelessWidget {
  final String labelText;
  final IconData? suffixIcon;
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final String? errorMessage;
  final EdgeInsets scrollPadding;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;
  final bool obscureText;

  const MWTextFormField({
    Key? key,
    required this.labelText,
    required this.controller,
    required this.focusNode,
    this.suffixIcon,
    this.textInputAction = TextInputAction.done,
    this.errorMessage,
    this.scrollPadding = const EdgeInsets.fromLTRB(20, 20, 20, 60),
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        focusNode: focusNode,
        scrollPadding: scrollPadding,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        onChanged: onChanged,
        validator: validator,
        onFieldSubmitted: onFieldSubmitted,
        decoration: InputDecoration(
          errorText: errorMessage,
          helperText: ' ',
          labelText: labelText,
          suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
        ),
      ),
    );
  }
}
