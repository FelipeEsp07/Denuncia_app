import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final TextStyle? textStyle; // Nuevo parámetro opcional para personalizar el texto

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.textStyle, // Inicializa el nuevo parámetro
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: const Color(0xFFD1D5DB),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 1),
            blurRadius: 2,
            color: Colors.black.withOpacity(0.3),
          ),
          BoxShadow(
            offset: const Offset(0, 1),
            blurRadius: 3,
            spreadRadius: 1,
            color: Colors.black.withOpacity(0.15),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(100),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Colors.white.withOpacity(0.08),
            ),
            child: Center(
              child: Text(
                text,
                style: textStyle ??
                    const TextStyle(
                      fontFamily: 'Verdana', // Fuente integrada
                      fontSize: 16, // Tamaño ajustado
                      fontWeight: FontWeight.w500, // Peso para un estilo elegante
                      color: Color.fromARGB(255, 0, 0, 0),
                      letterSpacing: 0.1,
                      height: 1.43,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}