import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

mixin ButtonStateMixin<T extends StatefulWidget> on State<T> {
  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;

  VoidCallback? onPressedAsyncFuncOrNull(AsyncCallback? asyncVoidCallback) {
    return asyncVoidCallback != null
        ? () => onPressedAsync(asyncVoidCallback)
        : null;
  }

  void onPressedAsync(AsyncCallback asyncVoidCallback) async {
    if (_isProcessing) {
      return;
    }

    _isProcessing = true;
    if (mounted) {
      setState(() {});
    }
    try {
      await asyncVoidCallback();
    } finally {
      _isProcessing = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  VoidCallback? onPressedFuncOrNull(VoidCallback? voidCallback) {
    return voidCallback != null ? () => onPressed(voidCallback) : null;
  }

  void onPressed(VoidCallback? onPressed) async {
    if (_isProcessing) {
      return;
    }

    _isProcessing = true;

    try {
      await Future(() => onPressed?.call());
    } finally {
      _isProcessing = false;
    }
  }
}
