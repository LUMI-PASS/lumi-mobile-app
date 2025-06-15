import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:isar/isar.dart';

class ChessException implements Exception {
  ChessException();

  factory ChessException.fromIsarException(IsarError isarError) {
    return UnknownChessException(isarError.message);
  }

  factory ChessException.fromDioErrorResponseData(
    Map<String, dynamic> responseData,
  ) {
    // Example for exception types coming from API
    final description = responseData['desc'] ?? responseData["message"];
    switch (description) {
      case 'Invalid credentials':
        return InvalidCredentialsChessException();
      case 'Not logged in':
        return UnauthorizedChessException();
      default:
        return UnknownChessException();
    }
  }

  factory ChessException.fromDioException(DioException dioException) {
    final response = dioException.response;
    if (dioException.error is SocketException) {
      return NoInternetConnectionChessException();
    }
    if (response == null) return UnknownChessException();

    switch (response.statusCode) {
      case 401:
        return UnauthorizedChessException();
      case 404:
        return NotFoundChessException();
      case 409:
        try {
          return ChessException.fromDioErrorResponseData(
            jsonDecode(response.data.toString()) as Map<String, dynamic>,
          );
        } on Exception {
          return UnknownChessException();
        }

      default:
        return UnknownChessException();
    }
  }
}

class NoInternetConnectionChessException extends ChessException {
  NoInternetConnectionChessException();
}

class UnauthorizedChessException extends ChessException {
  UnauthorizedChessException();
}

class NotFoundChessException extends ChessException {
  NotFoundChessException();
}

class InvalidCredentialsChessException extends ChessException {
  InvalidCredentialsChessException();
}

class UnknownChessException extends ChessException {
  final String? message;

  UnknownChessException([this.message]);

  @override
  String toString() {
    return message ?? 'An unknown error occurred';
  }
}
