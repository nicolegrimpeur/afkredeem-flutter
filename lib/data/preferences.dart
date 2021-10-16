import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info/package_info.dart';

import 'package:afk_redeem/data/consts.dart';
import 'package:afk_redeem/data/redemption_code.dart';
import 'package:afk_redeem/data/user_message.dart';
import 'package:afk_redeem/data/json_reader.dart';

class Preferences {
  static Preferences? _singleton;
  factory Preferences() {
    return _singleton!;
  }

  static const String _kIsHypogean = 'isHypogean';
  static const String _kUserID = 'userID';
  static const String _kShowAds = 'showAds';
  static const String _kWasDisclosureApproved = 'wasDisclosureApproved';
  static const String _kWasFirstConnectionSuccessful =
      'wasFirstConnectionSuccessful';
  static const String _kWasManualRedeemMessageShown =
      'wasManualRedeemMessageShown';
  static const String _kForceChristmasTheme = 'forceChristmasTheme';
  static const String _kAppInStoreVersion = 'appInStoreVersion';
  static const String _kRedeemApiVersion = 'redeemApiVersion';
  static const String _kAppInStoreApiVersionSupport =
      'appInStoreApiVersionSupport';
  static const String _kChristmasThemeStartDate = 'christmasThemeStartDate';
  static const String _kChristmasThemeEndDate = 'christmasThemeEndDate';
  static const String _kAppMessageShown = 'appMessageShown';
  static const String _kRedemptionCodes = 'redemptionCodes';

  SharedPreferences _prefs;
  PackageInfo _packageInfo;

  bool _isHypogean;
  String _userID;
  bool _showAds;
  bool _wasDisclosureApproved;
  bool _wasFirstConnectionSuccessful;
  bool _wasManualRedeemMessageShown;
  bool _forceChristmasTheme;
  int _appInStoreVersion;
  int _redeemApiVersion;
  int _appInStoreApiVersionSupport;
  DateTime _christmasThemeStartDate;
  DateTime _christmasThemeEndDate;

  List<RedemptionCode> redemptionCodes;
  Map<String, RedemptionCode> redemptionCodesMap;

  bool get isHypogean => _isHypogean;
  String get userID => _userID;
  bool get showAds => _showAds;
  bool get wasDisclosureApproved => _wasDisclosureApproved;
  bool get wasFirstConnectionSuccessful => _wasFirstConnectionSuccessful;
  bool get wasManualRedeemMessageShown => _wasManualRedeemMessageShown;
  bool get forceChristmasTheme => _forceChristmasTheme;
  int get appInStoreVersion => _appInStoreVersion;
  int get redeemApiVersion => _redeemApiVersion;
  int get appInStoreApiVersionSupport => _appInStoreApiVersionSupport;
  DateTime get christmasThemeStartDate => _christmasThemeStartDate;
  DateTime get christmasThemeEndDate => _christmasThemeEndDate;

  set userID(String value) {
    _userID = value;
    _prefs.setString(_kUserID, value);
  }

  set isHypogean(bool value) {
    _forceChristmasTheme = false;
    _isHypogean = value;
    _prefs.setBool(_kIsHypogean, value);
  }

  set showAds(bool value) {
    _showAds = value;
    _prefs.setBool(_kShowAds, value);
  }

  set wasDisclosureApproved(bool value) {
    _wasDisclosureApproved = value;
    _prefs.setBool(_kWasDisclosureApproved, value);
  }

  set wasFirstConnectionSuccessful(bool value) {
    _wasFirstConnectionSuccessful = value;
    _prefs.setBool(_kWasFirstConnectionSuccessful, value);
  }

  set wasManualRedeemMessageShown(bool value) {
    _wasManualRedeemMessageShown = value;
    _prefs.setBool(_kWasManualRedeemMessageShown, value);
  }

  set forceChristmasTheme(bool value) {
    _forceChristmasTheme = value;
    _prefs.setBool(_kForceChristmasTheme, value);
  }

  set appInStoreVersion(int value) {
    _appInStoreVersion = value;
    _prefs.setInt(_kAppInStoreVersion, value);
  }

  set redeemApiVersion(int value) {
    _redeemApiVersion = value;
    _prefs.setInt(_kRedeemApiVersion, value);
  }

  set appInStoreApiVersionSupport(int value) {
    _appInStoreApiVersionSupport = value;
    _prefs.setInt(_kAppInStoreApiVersionSupport, value);
  }

  set christmasThemeStartDate(DateTime value) {
    _christmasThemeStartDate = value;
    _prefs.setString(
        _kChristmasThemeStartDate, DateFormat('yyyy-MM-dd').format(value));
  }

  set christmasThemeEndDate(DateTime value) {
    _christmasThemeEndDate = value;
    _prefs.setString(
        _kChristmasThemeEndDate, DateFormat('yyyy-MM-dd').format(value));
  }

  bool wasAppMessageShown(int messageId) {
    return _prefs.getBool('$_kAppMessageShown-$messageId') ?? false;
  }

  void setAppMessageShown(int messageId) {
    _prefs.setBool('$_kAppMessageShown-$messageId', true);
  }

  static Future<Preferences> create() async {
    if (_singleton != null) {
      return _singleton!;
    }
    var sharedPreferences = SharedPreferences.getInstance();
    var packageInfo = PackageInfo.fromPlatform();
    _singleton =
        Preferences._create(await sharedPreferences, await packageInfo);
    return _singleton!;
  }

  Preferences._create(this._prefs, this._packageInfo)
      : _isHypogean = _prefs.getBool(_kIsHypogean) ?? true,
        _userID = _prefs.getString(_kUserID) ?? '',
        _showAds = _prefs.getBool(_kShowAds) ?? false,
        _wasDisclosureApproved =
            _prefs.getBool(_kWasDisclosureApproved) ?? false,
        _wasFirstConnectionSuccessful =
            _prefs.getBool(_kWasFirstConnectionSuccessful) ?? false,
        _wasManualRedeemMessageShown =
            _prefs.getBool(_kWasManualRedeemMessageShown) ?? false,
        _forceChristmasTheme = _prefs.getBool(_kForceChristmasTheme) ?? false,
        _appInStoreVersion =
            _prefs.getInt(_kAppInStoreVersion) ?? kDefaultAppInStoreVersion,
        _redeemApiVersion =
            _prefs.getInt(_kRedeemApiVersion) ?? kDefaultRedeemApiVersion,
        _appInStoreApiVersionSupport =
            _prefs.getInt(_kAppInStoreApiVersionSupport) ??
                kDefaultAppInStoreApiVersionSupport,
        _christmasThemeStartDate = DateTime.parse(
            _prefs.getString(_kChristmasThemeStartDate) ?? '2222-01-01'),
        _christmasThemeEndDate = DateTime.parse(
            _prefs.getString(_kChristmasThemeEndDate) ?? '2222-01-01'),
        redemptionCodes =
            _codesFromJsonString(_prefs.getString(_kRedemptionCodes)),
        redemptionCodesMap = {} {
    if (wasAppMessageShown(kManualRedeemApiBrutusMessageId)) {
      // old user has seen manual redeem message when it was an api brutus message
      wasManualRedeemMessageShown = true;
    }
    // can't rely on member redemptionCodes in initialization
    redemptionCodesMap = {for (var rc in redemptionCodes) rc.code: rc};
    // sort by isActive & date
    redemptionCodes.sort();

    // set successful first connection for existing users (already have codes)
    if (redemptionCodes.isNotEmpty) {
      wasFirstConnectionSuccessful = true;
    }
  }

  void updateConfigData({
    required Map<String, dynamic> configData,
    required UserErrorHandler userErrorHandler,
    required Function() applyThemeHandler,
  }) {
    JsonReader jsonReader = JsonReader(
      context: 'Preferences::updateConfigData',
      json: configData,
    );
    showAds = jsonReader.read('showAds');
    redeemApiVersion = jsonReader.read('redeemApiVersion');
    if (Platform.isAndroid) {
      appInStoreVersion = jsonReader.read('androidStoreAppVersion');
      appInStoreApiVersionSupport =
          jsonReader.read('androidAppApiVersionSupport');
    } else if (Platform.isIOS) {
      appInStoreVersion = jsonReader.read('iosStoreAppVersion');
      appInStoreApiVersionSupport = jsonReader.read('iosAppApiVersionSupport');
    } else {
      throw Exception('Unsupported platform for api version config data');
    }
    bool wasChristmasTime = isChristmasTime;
    christmasThemeStartDate =
        DateTime.parse(jsonReader.read('christmasThemeStartDate'));
    christmasThemeEndDate =
        DateTime.parse(jsonReader.read('christmasThemeEndDate'));
    if (wasChristmasTime != isChristmasTime) {
      applyThemeHandler(); // christmas changed
    }
  }

  bool get isAppUpgradable {
    return appInStoreVersion > int.parse(_packageInfo.buildNumber);
  }

  bool get isRedeemApiVersionSupported {
    return redeemApiVersion <= kRedeemApiVersion;
  }

  bool get isRedeemApiVersionUpgradable {
    return redeemApiVersion <= appInStoreApiVersionSupport;
  }

  bool get isChristmasTime {
    return forceChristmasTheme ||
        DateTime.now().isAfter(_christmasThemeStartDate) &&
            DateTime.now().isBefore(_christmasThemeEndDate);
  }

  void updateRedeemedCodes(List<RedemptionCode> redeemed) {
    for (RedemptionCode redeemedCode in redeemed) {
      redemptionCodesMap[redeemedCode.code]?.wasRedeemed = true;
    }
    _prefs.setString('redemptionCodes', _codesToJsonString(redemptionCodes));
  }

  void updateCodesFromExternalSource({
    required List<dynamic> newCodesJson,
    required UserErrorHandler? userErrorHandler,
  }) {
    wasFirstConnectionSuccessful = true;
    List<RedemptionCode> newCodes =
        _codesFromJson(newCodesJson, userErrorHandler: userErrorHandler);
    for (RedemptionCode newRC in newCodes) {
      if (redemptionCodesMap.containsKey(newRC.code)) {
        redemptionCodesMap[newRC.code]!.updateFromExternalSource(newRC);
      } else {
        redemptionCodes.add(newRC);
        redemptionCodesMap[newRC.code] = newRC;
      }
    }
    // sort by isActive & date
    redemptionCodes.sort();
    _prefs.setString(_kRedemptionCodes, _codesToJsonString(redemptionCodes));
  }

  static List<RedemptionCode> _codesFromJsonString(String? codesJsonString) {
    return codesJsonString == null
        ? []
        : _codesFromJson(json.decode(codesJsonString));
  }

  static List<RedemptionCode> _codesFromJson(List<dynamic> jsonCodes,
      {UserErrorHandler? userErrorHandler}) {
    List<RedemptionCode> codes = [];
    JsonReader jsonReader = JsonReader(
      context: 'Reading redemption codes json',
    );
    for (dynamic codeJson in jsonCodes) {
      jsonReader.json = codeJson;
      codes.add(RedemptionCode.fromJson(jsonReader));
    }
    return codes;
  }

  static String _codesToJsonString(List<RedemptionCode> redemptionCodes) {
    return jsonEncode(redemptionCodes);
  }
}
