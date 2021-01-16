import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'models/models.dart';

/// General Repository to interact with the API format
/// as provided by Mazhar Bhai
class GereralResponseRepository {
  /// Used to initiate a [GET] request
  ///
  /// The [endpoint] is end point that will be attached to the [baseUrl]
  /// which either can be provided as a whole using the [ApiConfig]
  /// setting or can be overidden as it is given as an option parameter
  /// in the function.
  ///
  /// Same thing applies for the [header] parameter
  Future<dynamic> get({
    @required String endpoint,
    String baseUrl,
    Map<String, String> header,
  }) async {
    // check if url is provided
    assert(
        ["", null].contains(baseUrl) || ["", null].contains(ApiConfig.baseUrl),
        "Both baseUrl and ApiConfig cannot be set as null");
    var responseJson;
    try {
      final response = await http
          .get(
            (baseUrl ?? ApiConfig.baseUrl) + endpoint,
            headers: header ?? ApiConfig.header,
          )
          .timeout(ApiConfig.responseTimeOut);
      responseJson = _response(response);
    } on SocketException {
      throw FetchDataException();
    } on TimeoutException {
      throw TimeOutExceptionC();
    }
    return responseJson;
  }

  /// Used to initiate a [POST] request
  ///
  /// Use the [body] parameter to send the json data to the service
  ///
  /// The [endpoint] is end point that will be attached to the [baseUrl]
  /// which either can be provided as a whole using the [ApiConfig]
  /// setting or can be overidden as it is given as an option parameter
  /// in the function.
  ///
  /// Same thing applies for the [header] parameter
  Future<dynamic> post({
    @required String endpoint,
    String body,
    String baseUrl,
    Map<String, String> header,
  }) async {
    // check if url is provided
    assert(
        ["", null].contains(baseUrl) || ["", null].contains(ApiConfig.baseUrl),
        "Both baseUrl and ApiConfig cannot be set as null");

    var responseJson;
    try {
      final response = await http
          .post((baseUrl ?? ApiConfig.baseUrl) + endpoint,
              body: body, headers: header ?? ApiConfig.header)
          .timeout(ApiConfig.responseTimeOut);
      responseJson = _response(response);
    } on SocketException {
      throw FetchDataException();
    } on TimeoutException {
      throw TimeOutExceptionC();
    }
    return responseJson;
  }

  /// gerenal HTTP code responses
  dynamic _response(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body.toString());
        // print(responseJson);
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
            "Something went wrong, please try again later.\n\nStatus Code : ${response.statusCode}");
    }
  }
}
