import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

const kRedeemApiVersion = 1;

const kConnectTimeoutMilli = Duration(seconds: 5);
const kReceiveTimeoutMilli = Duration(seconds: 3);

const kMinPasteManualRedemptionCodeLength = 5;
const kMaxPasteManualRedemptionCodeLength = 15;

const kDefaultAppInStoreVersion = 1;
const kDefaultRedeemFrequencyLimit = 5000;
const kDefaultRedeemApiVersion = 1;
const kDefaultAppInStoreApiVersionSupport = 1;

const String kAfkArenaStorePackage = 'com.lilithgame.hgame.gp';
const List<String> kAdsKeywords = [
  'AFK Arena',
  'mobile games',
  'gaming',
  'rpg'
];

const int kManualRedeemApiBrutusMessageId = 1;

// mixin wins over class cause it prevents the compiler from complaining about naming conventions
mixin kLinks {
  // static const bool _emulateLilithRedeem = true;
  static const bool _emulateLilithRedeem = false;
  // static const bool _emulateAfkRedeemApi = true;
  static const bool _emulateAfkRedeemApi = false;

  // static const bool _toggleEmulatedRedeemResponses = true;
  static const bool _toggleEmulatedRedeemResponses = false;

  static const String iosEmulator = 'http://127.0.0.1/';
  static const String androidEmulator = 'http://10.0.2.2/';

  static const String _lilithRedeem = 'https://cdkey.lilith.com/';
  static const String lilithReferer = 'https://cdkey.lilith.com/afk-global';

  static const String buyMeCoffee = 'https://buymeacoffee.com/afkredeem';

  static const String afkRedeem = 'https://afkredeem.com/';
  static const String githubProject =
      'https://github.com/afkredeem/afkredeem-flutter';
  static const String issuesGithubProject = githubProject + '/issues';

  static const _androidStoreLink =
      'https://play.google.com/store/apps/details?id=com.afkredeem';
  static const _iosStoreLink = 'https://www.apple.com/app-store/';
  static final storeLink = Platform.isIOS ? _iosStoreLink : _androidStoreLink;

  static final String lilithRedeemHost = kReleaseMode || !_emulateLilithRedeem
      ? _lilithRedeem
      : Platform.isAndroid
          ? androidEmulator
          : Platform.isIOS
              ? iosEmulator
              : _lilithRedeem;

  static final String afkRedeemApiHost = kReleaseMode || !_emulateAfkRedeemApi
      ? afkRedeem
      : Platform.isAndroid
          ? androidEmulator
          : Platform.isIOS
              ? iosEmulator
              : afkRedeem;

  static final afkRedeemApiUrl = afkRedeemApiHost + kUris.afkRedeemApi;

  static const bool toggleEmulatedRedeemResponses =
      _toggleEmulatedRedeemResponses && !kReleaseMode;
}

mixin kUris {
  static const String verifyCodeUri = 'api/verify-afk-code';
  static const String usersUri = 'api/users';
  static const String consumeUri = 'api/cd-key/consume';

  static const String afkRedeemApi = 'api.json';
}

mixin kContact {
  static const String email = 'afkredeem@gmail.com';
}

bool shouldReportDioError(DioException ex) {
  // report if not timeout & not ssl handshake error (CERTIFICATE_VERIFY_FAILED)
  // since can occur for the first time (especially for new afkredeem.com domain)
  // in private limited networks (work, school, etc.)
  return ex.type != DioExceptionType.connectionTimeout && !(ex is HandshakeException);
}
