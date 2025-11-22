import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:chess_traps/generated/assets.dart';
import 'package:chess_traps/utils.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final asset = context.isLight
        ? AppAssets.appLightLogoWithTextSvg
        : AppAssets.appDarkLogoWithTextSvg;

    return SvgPicture.asset(
      asset,
      height: 40,
      alignment: AlignmentGeometry.centerLeft,
      fit: BoxFit.cover,
    );
  }
}
