import 'package:afk_redeem/data/consts.dart';
import 'package:afk_redeem/data/services/afk_redeem_api.dart';
import 'package:flutter/material.dart';

import 'package:afk_redeem/ui/appearance_manager.dart';
import 'package:afk_redeem/ui/image_manager.dart';


Future<AlertDialog> aboutDialog(
    BuildContext context, AfkRedeemApi afkRedeemApi) async {
  return AlertDialog(
    title: Text('About'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        new RichText(
            text: new TextSpan(
                children: [
                  new TextSpan(
                    text: 'AFK Redeem is a fan-app and is not affiliated  ',
                    style: AppearanceManager().textStyle,
                  ),
                  new TextSpan(
                    text: 'Lilith Games',
                    style: AppearanceManager().mainTextStyle,
                  ),
                  new TextSpan(
                    text: ' in any way.\n\nFor feature requests or in case of any bugs please refer to the ',
                    style: AppearanceManager().textStyle,
                  ),
                  new TextSpan(
                    text: 'issues section',
                    style: AppearanceManager().linkStyle,
                    recognizer: AppearanceManager().tapGestureRecognizer(
                        Uri.parse(kLinks.issuesGithubProject)),
                  ),
                  new TextSpan(
                    text: ' in the ',
                    style: AppearanceManager().textStyle,
                  ),
                  new TextSpan(
                    text: 'github project',
                    style: AppearanceManager().linkStyle,
                    recognizer: AppearanceManager().tapGestureRecognizer(
                        Uri.parse(kLinks.githubProject)),
                  ),
                  new TextSpan(
                    text: '.\n\n',
                    style: AppearanceManager().textStyle,
                  ),
                  new TextSpan(
                    text: 'If you\'re interested in creating or sharing AFK Arena related content, or in case of any other inquiry feel free to ',
                    style: AppearanceManager().textStyle,
                  ),
                  new TextSpan(
                    text: 'contact️',
                    style: AppearanceManager().linkStyle,
                    recognizer: AppearanceManager().tapGestureRecognizer(Uri(
                        scheme: 'mailto',
                        path: kContact.email,
                        queryParameters: {
                          'subject': 'CallOut user Profile',
                          'body': ''
                        },
                      )
                    ),

                  ),
                  new TextSpan(
                    text: '.',
                    style: AppearanceManager().textStyle,
                  ),
                ]
            )
        ),

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
