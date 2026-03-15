import 'package:flutter/material.dart';
import '../theme/white_spaces.dart';
import '../utils.dart';

class CustomFilledButton extends StatelessWidget {

  const CustomFilledButton({
    super.key,
    required this.label,
    required this.onPressed,
  });
  final void Function() onPressed;

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(WhiteSpaces.buttonBorderRadius),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Color(0xff333333)],
        ),
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(WhiteSpaces.buttonBorderRadius),
          ),
        ),
        child: Text(
          label,
          style: context.textTheme.bodyLarge?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
