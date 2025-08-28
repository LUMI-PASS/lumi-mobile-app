import 'package:dio/dio.dart';
import 'package:flexobo/common/gen/strings.dart';
import 'package:injectable/injectable.dart';

import 'display.dart';
import 'display_message.dart';
import 'display_type.dart';

@Singleton(as: Display)
class DisplayImpl extends Display {
  void Function(DisplayMessage message)? _onDisplay;

  void _display(DisplayType type, String description, [String? title]) =>
      _onDisplay?.call(
        DisplayMessage(
          type,
          description,
          title,
        ),
      );

  @override
  void error(Object description, [String? title]) {
    if (description is DioException) {
      if (description.type == DioExceptionType.connectionError) {
        _display(
          DisplayType.error,
          Strings.checkInternetConnection,
          title,
        );
      } else if (description.type == DioExceptionType.receiveTimeout ||
          description.type == DioExceptionType.sendTimeout ||
          description.type == DioExceptionType.connectionTimeout) {
        _display(
          DisplayType.error,
          Strings.serverNotRespondingOrTimeout,
          title,
        );
      } else if (description.response?.statusCode == 500 ||
          description.response?.statusCode == 502) {
        _display(
          DisplayType.error,
          Strings.serverErrorTryLater,
          title,
        );
      } else {
        _display(
            DisplayType.error,
            "${Strings.unknownError} : ${description.response?.data['message']}",
            title);
      }
    } else {
      _display(DisplayType.error, description.toString(), title);
    }
  }

  @override
  void warning(String description, [String? title]) => _display(
        DisplayType.warning,
        description,
        title,
      );

  @override
  void info(String description, [String? title]) => _display(
        DisplayType.info,
        description,
        title,
      );

  @override
  void success(String description, [String? title]) => _display(
        DisplayType.success,
        description,
        title,
      );

  @override
  void setOnDisplayListener(void Function(DisplayMessage message) onDisplay) {
    _onDisplay = onDisplay;
  }
}
