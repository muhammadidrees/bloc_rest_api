import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;

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
  Future<Map<String, dynamic>> get(
    http.Client client, {
    @required String handle,
    String baseUrl,
    Map<String, String> header,
    bool enableLogs = false,
  }) async {
    if (enableLogs) {
      developer.log(
        'Request URl: ${(baseUrl ?? ApiConfig.baseUrl) + handle}',
        name: 'package.bloc_rest_api.$handle',
      );
      developer.log(
        'Request Header: ${jsonEncode(header ?? ApiConfig.header)}}',
        name: 'package.bloc_rest_api.$handle',
      );
    }

    var rawResponse;
    var responseJson;
    try {
      rawResponse = await client
          .get(
            (baseUrl ?? ApiConfig.baseUrl) + handle,
            headers: header ?? ApiConfig.header,
          )
          ?.timeout(ApiConfig.responseTimeOut);
      responseJson = _response(rawResponse);
    } on SocketException {
      throw FetchDataException();
    } on TimeoutException {
      throw TimeOutExceptionC();
    } finally {
      if (enableLogs) {
        developer.log(
          'Request Response Status: ${rawResponse.statusCode}',
          name: 'package.bloc_rest_api.$handle',
        );
        developer.log(
          'Request Raw Response: ${rawResponse.body}',
          name: 'package.bloc_rest_api.$handle',
        );
      }
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
  Future<Map<String, dynamic>> post(
    http.Client client, {
    @required String handle,
    String body,
    String baseUrl,
    Map<String, String> header,
    bool enableLogs = false,
  }) async {
    if (enableLogs) {
      developer.log(
        'Request URl: ${(baseUrl ?? ApiConfig.baseUrl) + handle}',
        name: 'package.bloc_rest_api.$handle',
      );
      developer.log(
        'Request Header: ${jsonEncode(header ?? ApiConfig.header)}}',
        name: 'package.bloc_rest_api.$handle',
      );
      developer.log(
        'Request Body: ${jsonEncode(body)}}',
        name: 'package.bloc_rest_api.$handle',
      );
    }
    var rawResponse;
    var responseJson;
    try {
      rawResponse = await client
          .post((baseUrl ?? ApiConfig.baseUrl) + handle,
              body: body, headers: header ?? ApiConfig.header)
          .timeout(ApiConfig.responseTimeOut);
      responseJson = _response(rawResponse);
    } on SocketException {
      throw FetchDataException();
    } on TimeoutException {
      throw TimeOutExceptionC();
    } finally {
      if (enableLogs) {
        developer.log(
          'Request Response Status: ${rawResponse.statusCode}',
          name: 'package.bloc_rest_api.$handle',
        );
        developer.log(
          'Request Raw Response: $responseJson',
          name: 'package.bloc_rest_api.$handle',
        );
      }
    }
    return responseJson;
  }

  /// Used to convert a locally provided [json] String to json Map
  Future<Map<String, dynamic>> local(
    String json, {
    bool enableLogs = false,
  }) async {
    if (enableLogs) {
      developer.log(
        'JSON String: $json',
        name: 'package.bloc_rest_api.local',
      );
    }

    var rawResponse;
    try {
      rawResponse = jsonDecode(json);
    } catch (e) {
      throw Exception(e.toString());
    } finally {
      if (enableLogs) {
        developer.log(
          'Raw JSON: ${rawResponse}',
          name: 'package.bloc_rest_api.local',
        );
      }
    }
    return rawResponse;
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
            'Something went wrong, please try again later.\n\nStatus Code : ${response.statusCode}');
    }
  }
}
