import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../generated/assets.dart';
import '../utils.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final String asset = context.isLight
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
