import 'package:flutter/material.dart';
import 'package:chess_traps/theme/white_spaces.dart';
import 'package:chess_traps/utils.dart';

class CustomFilledButton extends StatelessWidget {
  final void Function() onPressed;

  const CustomFilledButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(WhiteSpaces.buttonBorderRadius),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          tileMode: TileMode.clamp,
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
