part of 'models.dart';

/// Exception model for internet related exceptions
class CustomException implements Exception {
  final _message;
  final _prefix;

  CustomException([this._message, this._prefix]);

  @override
  String toString() {
    return '$_prefix$_message';
  }
}

class FetchDataException extends CustomException {
  FetchDataException(
      [String message = 'Please check your internet and try again later.'])
      : super(message, '');
}

class BadRequestException extends CustomException {
  BadRequestException([String message]) : super(message, 'Invalid Request: ');
}

class UnauthorisedException extends CustomException {
  UnauthorisedException([String message]) : super(message, 'Unauthorised: ');
}

class InvalidInputException extends CustomException {
  InvalidInputException([String message]) : super(message, 'Invalid Input: ');
}

class TimeOutExceptionC extends CustomException {
  TimeOutExceptionC(
      [String message =
          'Something went wrong, please check your internet and try again later.'])
      : super(message, '');
}
