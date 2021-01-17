/// Set up api related stuff to be used later on
/// thoroughout API calls
///
/// Though for a specific use case these can also be
/// overriden in API call functions
class ApiConfig {
  /// base url for the project
  static String baseUrl = "";

  /// header for the project
  static Map<String, String> header;

  /// duration for timeout request
  static Duration responseTimeOut = Duration(seconds: 10);
}
