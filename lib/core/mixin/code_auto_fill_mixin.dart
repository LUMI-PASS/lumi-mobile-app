import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:sms_autofill/sms_autofill.dart';

mixin CodeAutoFillMixin {
  final SmsAutoFill _autoFill = SmsAutoFill();

  @protected
  Future<String> get getAppSignature => _autoFill.getAppSignature;

  @protected
  Stream<String> get codeUpdates => _autoFill.code;

  @protected
  Future<void> listenForCode({String? smsCodeRegexPattern}) async {
    String signature = await _autoFill.getAppSignature;

    // Store the signature in SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_signature', signature);

    return smsCodeRegexPattern == null
        ? _autoFill.listenForCode()
        : _autoFill.listenForCode(smsCodeRegexPattern: smsCodeRegexPattern);
  }

  @protected
  Future<void> unregisterListener() {
    return _autoFill.unregisterListener();
  }
}
