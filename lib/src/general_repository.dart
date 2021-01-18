import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc_rest_api/src/api_config.dart';
import 'package:bloc_rest_api/src/models/models.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

/// General Repository to interact with any REST API
class GereralRepository {
  /// Used to initiate a [GET] request
  ///
  /// The [handle] is end point that will be attached to the [baseUrl]
  /// which either can be provided as a whole using the [ApiConfig]
  /// setting or can be overidden as it is given as an option parameter
  /// in the function.
  ///
  /// Same thing applies for the [header] parameter
  Future<dynamic> get(
    http.Client client, {
    @required String handle,
    String baseUrl,
    Map<String, String> header,
  }) async {
    // check if url is provided
    assert(
        !(["", null].contains(baseUrl) &&
            ["", null].contains(ApiConfig.baseUrl)),
        "Both baseUrl and ApiConfig cannot be set as null at the same time");

    var responseJson;
    try {
      final response = await client
          .get(
            (baseUrl ?? ApiConfig.baseUrl) + handle,
            headers: header ?? ApiConfig.header,
          )
          ?.timeout(ApiConfig.responseTimeOut);
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
  /// The [handle] is end point that will be attached to the [baseUrl]
  /// which either can be provided as a whole using the [ApiConfig]
  /// setting or can be overidden as it is given as an option parameter
  /// in the function.
  ///
  /// Same thing applies for the [header] parameter
  Future<dynamic> post(
    http.Client client, {
    @required String handle,
    String body,
    String baseUrl,
    Map<String, String> header,
  }) async {
    // check if url is provided
    assert(
        !(["", null].contains(baseUrl) &&
            ["", null].contains(ApiConfig.baseUrl)),
        "Both baseUrl and ApiConfig cannot be set as null at the same time");

    var responseJson;
    try {
      final response = await client
          .post((baseUrl ?? ApiConfig.baseUrl) + handle,
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
