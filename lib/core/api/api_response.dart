import 'package:json_annotation/json_annotation.dart';

import '../error/chess_exception.dart';

part 'api_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final T result;

  ApiResponse({
    required this.result,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    // reading error if API returns in format
    // result: "ERR"
    final error = json['error'];
    if (error != null) {
      throw ChessException.fromDioErrorResponseData(json);
    }
    return ApiResponse(result: fromJsonT(json));
  }
}
