import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

import 'package:afk_redeem/data/consts.dart';
import 'package:afk_redeem/data/preferences.dart';
import 'package:afk_redeem/data/redemption_code.dart';
import 'package:afk_redeem/data/user_message.dart';
import 'package:afk_redeem/data/json_reader.dart';
import 'package:afk_redeem/data/error_reporter.dart';
import 'package:afk_redeem/data/account_redeem_summary.dart';

enum AccountRedeemStrategy {
  mainAccount,
  allAccounts,
  select,
}

class FrequencyException implements Exception {}

class RedeemHandlers {
  Function() redeemRunningHandler;
  Function(double, int, String) progressHandler;
  Function(List<AccountInfo> accounts) accountSelectionHandler;
  RedeemSummaryFunction redeemCompletedHandler;
  UserErrorHandler userErrorHandler;

  RedeemHandlers({
    required this.redeemRunningHandler,
    required this.progressHandler,
    required this.accountSelectionHandler,
    required this.redeemCompletedHandler,
    required this.userErrorHandler,
  });
}

class CodeRedeemer {
  String uid;
  AccountRedeemStrategy accountRedeemStrategy;
  String verificationCode;
  Set<RedemptionCode> redemptionCodes;
  RedeemHandlers handlers;
  int userAccounts = 0;
  int codesRedeemed = 0;
  double progress = 0;
  Dio _dio = Dio();
  CookieJar _cookieJar = CookieJar();
  late JsonReader accountsJsonReader;

  CodeRedeemer({
    required this.uid,
    required this.accountRedeemStrategy,
    required this.verificationCode,
    required this.redemptionCodes,
    required this.handlers,
  }) {
    _dio.interceptors.add(CookieManager(_cookieJar));
    _dio.options.connectTimeout = kConnectTimeoutMilli;
    _dio.options.receiveTimeout = kReceiveTimeoutMilli;
  }

  Future<void> redeem() async {
    handlers.redeemRunningHandler();
    try {
      await _redeem();
    } on DioException catch (ex) {
      handlers.userErrorHandler(UserMessage.connectionFailed);
      if (shouldReportDioError(ex)) {
        ErrorReporter.report(
            ex, 'Connection failed to ${kLinks.lilithRedeemHost}');
      }
    } on JsonReaderException catch (ex) {
      handlers.userErrorHandler(UserMessage.parseError);
      ex.report();
    } on FrequencyException catch (ex) {
      handlers.userErrorHandler(UserMessage.redeemFrequencyError);
      ErrorReporter.report(ex,
          'Redeem frequency error on connection to ${kLinks.lilithRedeemHost}');
    } catch (ex) {
      handlers.userErrorHandler(UserMessage.parseError);
      ErrorReporter.report(ex,
          'Unknown parse error on connection to ${kLinks.lilithRedeemHost}');
    }
  }

  Future<void> _redeem() async {
    // verify code
    String postData = '''
    {
        "game": "afk",
        "uid": $uid,
        "code": "$verificationCode"
    }
    ''';
    Response response =
        await _sendRequest(kUris.verifyCodeUri, postData: postData);
    JsonReader jsonReader = JsonReader(
      context:
          'Redeemer reading response from ${kLinks.lilithRedeemHost}${kUris.verifyCodeUri}',
      json: response.data as Map<String, dynamic>,
    );

    String info = jsonReader.read('info');
    if (info == 'ok') {
      await _requestAccountsAndRedeem();
    } else if (info == 'err_wrong_code') {
      handlers.userErrorHandler(UserMessage.verificationFailed);
    } else {
      handlers.userErrorHandler(UserMessage.parseError);
      throw JsonReaderException(
          'Unknown ${kUris.verifyCodeUri} \'info\' value \'$info\'');
    }
  }

  Future<void> _requestAccountsAndRedeem() async {
    String postData = '''
    {
        "game": "afk",
        "uid": $uid
    }
    ''';
    Response response = await _sendRequest(kUris.usersUri, postData: postData);
    accountsJsonReader = JsonReader(
      context:
          'Redeemer reading response from ${kLinks.lilithRedeemHost}${kUris.usersUri}',
      json: response.data as Map<String, dynamic>,
    );

    await _redeemForAccount();
  }

  bool _shouldRedeemForUser(AccountInfo account, AccountInfo? selectedAccount) {
    return accountRedeemStrategy == AccountRedeemStrategy.allAccounts ||
        (accountRedeemStrategy == AccountRedeemStrategy.mainAccount &&
            account.isMain) ||
        (accountRedeemStrategy == AccountRedeemStrategy.select &&
            selectedAccount != null &&
            selectedAccount.uid == account.uid);
  }

  Future<void> redeemForAccount(AccountInfo selectedAccount) async {
    handlers.redeemRunningHandler();
    await _redeemForAccount(selectedAccount: selectedAccount);
  }

  Future<void> _redeemForAccount({AccountInfo? selectedAccount}) async {
    List<AccountInfo> accountsForSelection = [];
    List<Future<AccountRedeemSummary>> accountRedeemSummaries = [];
    if ((accountsJsonReader.read('info') ?? 'not-ok') == 'ok') {
      List<dynamic> users =
          accountsJsonReader.readFrom(accountsJsonReader.read('data'), 'users');
      userAccounts = users.length;
      for (Map<String, dynamic> user in users) {
        AccountInfo account = AccountInfo(
          accountsJsonReader.readFrom(user, 'uid'),
          accountsJsonReader.readFrom(user, 'name'),
          accountsJsonReader.readFrom(user, 'svr_id'),
          accountsJsonReader.readFrom(user, 'is_main'),
        );
        if (accountRedeemStrategy == AccountRedeemStrategy.select &&
            selectedAccount == null) {
          accountsForSelection.add(account);
        } else if (_shouldRedeemForUser(account, selectedAccount)) {
          // apparently AFK Arena will measure each account separately when
          // limiting frequency (responding with info=err_freq_limit) so we can
          // parallelize consuming for each account (and sleep inside per account)
          accountRedeemSummaries.add(_consumeForAccount(account));
        }
      }
    }
    if (accountsForSelection.isNotEmpty) {
      handlers.accountSelectionHandler(accountsForSelection);
      return;
    }
    if (accountRedeemSummaries.isEmpty) {
      handlers.userErrorHandler(UserMessage.parseError);
      ErrorReporter.report(Exception('Redeem Failed'),
          'empty accountRedeemSummaries list for ${kUris.usersUri} response: ${accountsJsonReader.json}');
      return;
    }
    handlers.redeemCompletedHandler(await Future.wait(accountRedeemSummaries));
  }

  Future<AccountRedeemSummary> _consumeForAccount(AccountInfo account) async {
    AccountRedeemSummary accountRedeemSummary = AccountRedeemSummary(account);

    int counter = 0;
    await Future.forEach(redemptionCodes,
        (RedemptionCode redemptionCode) async {
      counter++;
      Map<String, dynamic>? queryParams;
      if (kLinks.toggleEmulatedRedeemResponses) {
        queryParams = {'toggle-responses': null}; // mock server option
      }
      String postData = '''
      {
          "cdkey": "${redemptionCode.code}",
          "game": "afk",
          "type": "cdkey_web",
          "uid": ${account.uid}
      }
      ''';
      Response response = await _sendRequest(kUris.consumeUri,
          postData: postData, queryParameters: queryParams);
      _handleCodeRedeemedProgress();
      JsonReader jsonReader = JsonReader(
        context:
            'Redeemer reading response from ${kLinks.lilithRedeemHost}${kUris.consumeUri} with code=${redemptionCode.code}',
        json: response.data as Map<String, dynamic>,
      );
      String info = jsonReader.read('info');
      switch (info) {
        case 'ok':
          accountRedeemSummary.redeemedCodes.add(redemptionCode);
          break;
        case 'err_cdkey_already_used':
        case 'err_cdkey_batch_error':
          accountRedeemSummary.usedCodes.add(redemptionCode);
          break;
        case 'err_cdkey_record_not_found':
          accountRedeemSummary.notFoundCodes.add(redemptionCode);
          break;
        case 'err_cdkey_expired':
          if (redemptionCode.isExpired) {
            accountRedeemSummary.knownExpiredCodes.add(redemptionCode);
          } else {
            accountRedeemSummary.expiredCodes.add(redemptionCode);
          }
          break;
        case 'err_freq_limit':
          throw FrequencyException();
        default:
          throw JsonReaderException(
              'Unknown ${kUris.consumeUri} \'info\' value \'$info\'');
      }
      if (counter != redemptionCodes.length) {
        // sleep if not last (to avoid AFK Arena backoff timer causing info=err_freq_limit)
        await Future.delayed(
            Duration(milliseconds: Preferences().redeemFrequencyLimitMilli));
      }
    });

    return accountRedeemSummary;
  }

  Future<Response> _sendRequest(String uri,
      {String? postData, Map<String, dynamic>? queryParameters}) async {
    Response response = await _dio.post(
      '${kLinks.lilithRedeemHost}$uri',
      data: postData,
      queryParameters: queryParameters,
      options: Options(
        followRedirects: false,
        validateStatus: (status) {
          return true;
        },
        headers: {
          'sec-ch-ua':
              '" Not;A Brand";v="99", "Google Chrome";v="91", "Chromium";v="91"',
          'accept': 'application/json',
          'sec-ch-ua-mobile': '?0',
          'user-agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36',
          'content-type': 'application/json',
          'origin': kLinks.lilithRedeemHost
              .substring(0, kLinks.lilithRedeemHost.length - 1),
          'sec-fetch-site': 'same-origin',
          'sec-fetch-mode': 'cors',
          'sec-fetch-dest': 'empty',
          'referer': kLinks.lilithReferer,
          'accept-encoding': 'gzip, deflate, br',
          'accept-language': 'en-US,en;q=0.9',
        },
      ),
    );
    return response;
  }

  void _handleCodeRedeemedProgress() {
    codesRedeemed++;
    int codesRedeemedCrossAccounts = 0;
    String codesRedeemedMessage = '';
    if (userAccounts != 0) {
      codesRedeemedCrossAccounts = (codesRedeemed / userAccounts).round();
      progress =
          (100 * codesRedeemedCrossAccounts / redemptionCodes.length).roundToDouble();
      if (codesRedeemed % userAccounts == 0 && progress != 100) {
        codesRedeemedMessage = '⏳ Redeem frequency limit';
      }
    }
    handlers.progressHandler(
        progress, codesRedeemedCrossAccounts, codesRedeemedMessage);
  }
}
