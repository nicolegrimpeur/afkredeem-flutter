import 'package:afk_redeem/data/consts.dart';
import 'package:afk_redeem/data/services/afk_redeem_api.dart';
import 'package:flutter/material.dart';

import 'package:afk_redeem/ui/appearance_manager.dart';
import 'package:afk_redeem/ui/image_manager.dart';
import 'package:url_launcher/url_launcher.dart';

Future<AlertDialog> aboutDialog(
    BuildContext context, AfkRedeemApi afkRedeemApi) async {
  return AlertDialog(
    title: Text('About'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("About text"),
        SizedBox(
          height: 40.0,
        ),
        Text(
          'Old Player',
          style:
              TextStyle(color: AppearanceManager().color.main, fontSize: 14.0),
        ),
        SizedBox(
          height: 5.0,
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Dru**ed',
                style: TextStyle(fontSize: 14.0),
              ),
              Container(
                child: ImageManager().get('dragon'),
                height: 25.0,
                width: 25.0,
              ),
              Text(
                'Dragons',
                style: TextStyle(fontSize: 14.0),
              )
            ]),
      ],
    ),
  );
}
