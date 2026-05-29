import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: _obscure,
        obscuringCharacter: '•',
        validator: widget.validator,
        onFieldSubmitted: widget.onFieldSubmitted,
        autocorrect: !widget.isPassword,
        textCapitalization: TextCapitalization.none,
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
          suffixIcon: widget.isPassword
              ? IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
