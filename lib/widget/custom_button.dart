// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double? width;
  final double height;
  final bool isLoading;
  final double fontSize;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.width,
    this.height = 50,
    this.isLoading = false,
    this.fontSize = 18,
    this.backgroundColor,
    this.textColor,
  });

  factory CustomButton.secondary(
    BuildContext context, {
    required VoidCallback onPressed,
    required String text,
    double? width,
    double height = 50,
    bool isLoading = false,
  }) {
    return CustomButton(
      onPressed: onPressed,
      text: text,
      width: width,
      height: height,
      isLoading: isLoading,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      textColor: Theme.of(context).colorScheme.onSecondary,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              backgroundColor ?? Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Button border radius
          ),
        ),
        child: !isLoading
            ? Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: textColor ?? Theme.of(context).colorScheme.onPrimary,
                ),
              )
            : CircularProgressIndicator.adaptive(
                backgroundColor:
                    textColor ?? Theme.of(context).colorScheme.onPrimary,
              ),
      ),
    );
  }
}
