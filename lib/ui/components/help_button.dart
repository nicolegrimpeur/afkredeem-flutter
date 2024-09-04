import 'package:flutter/material.dart';

import 'package:afk_redeem/ui/appearance_manager.dart';
import 'package:afk_redeem/ui/components/carousel_dialog.dart';

Widget helpButton({required Function() onPressed}) {
  return IconButton(
      iconSize: 25.0,
      onPressed: onPressed,
      icon: Icon(Icons.help,
          color: AppearanceManager().color.main.withOpacity(0.2))
  );
}

Widget carouselDialogHelpButton(
    {required BuildContext context, required List<Widget> carouselItems}) {
  return helpButton(onPressed: () {
    showDialog<String>(
      context: context,
      builder: (_) => carouselDialog(context, carouselItems),
    );
  });
}
