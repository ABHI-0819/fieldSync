import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

/// Use this for print data in console.
void debugLog(String message, {String name = '',StackTrace? stackTrace}) {
  if (kDebugMode) {
    developer.log(message,name: name,stackTrace: stackTrace);
  }
}