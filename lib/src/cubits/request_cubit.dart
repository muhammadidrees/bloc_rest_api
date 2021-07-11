part of 'cubits.dart';

class RequestCubit<T> extends Cubit<RequestState<T>> {
  RequestCubit({
    this.fromMap,
    http.Client? httpClient,
  })  : httpClient = httpClient ?? http.Client(),
        super(RequestState<T>.empty());

  /// for testing
  final http.Client httpClient;

  /// A function that converts the given [json] map to
  /// [T] type model
  final T Function(dynamic json)? fromMap;

  /// Empties out the bloc and emits the empty state
  void emptyCubit() {
    emit(RequestState<T>.empty());
  }

  /// Emits the success state with the given model
  void updateModel(T model) {
    emit(
      state.copyWith(
        status: RequestStatus.success,
        model: model,
      ),
    );
  }

  /// A general function to control bloc with any given
  /// [requestFuntion] that returns a future of type [T]
  ///
  /// To emit an error state you can use `throw` inside your
  /// future function
  void request(Future<T> requestFunction) async {
    emit(
      state.copyWith(status: RequestStatus.loading),
    );
    await requestFunction.then((value) {
      emit(
        state.copyWith(
          status: RequestStatus.success,
          model: value,
        ),
      );
    }).catchError((error) {
      emit(
        state.copyWith(
          status: RequestStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    });
  }

  /// Used to initiate a [GET] request
  ///
  /// The [handle] is end point that will be attached to the [baseUrl]
  /// which either can be provided as a whole using the [ApiConfig]
  /// setting or can be overidden as it is given as an option parameter
  /// in the function.
  ///
  /// Same thing applies for the [header] and [timeOut] parameter
  ///
  /// The [fromMap] function is used the convert the response json to
  /// model [T] this can either be provided during bloc initialization
  /// in the provider or can be specified in this function. In case
  /// it is given in both places the function one is given presidence.
  ///
  /// Use the [enableLog] flag to show logs for the request in debug
  /// console
  Future<void> getRequest({
    required String handle,
    String? baseUrl,
    Map<String, String>? header,
    T Function(dynamic json)? fromMap,
    Duration? timeOut,
    bool? enableLogs,
  }) async {
    // check if fromMap function is provided
    assert((fromMap != null || this.fromMap != null),
        'fromMap function cannot be null!!! Either provide the fromMap function directly in this function or use the optional fromMap function while initializing the bloc');

    // check if url is provided
    assert(
        !(['', null].contains(baseUrl) &&
            ['', null].contains(ApiConfig.baseUrl)),
        'Both baseUrl and ApiConfig cannot be set as null at the same time');

    request(
      GereralRepository()
          .get(
            httpClient,
            handle: handle,
            baseUrl: baseUrl,
            header: header,
            timeOut: timeOut,
            enableLogs: enableLogs!,
          )
          .then(
            (value) => toModel(fromMap, value)!,
          ),
    );
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
  /// Same thing applies for the [header] and [timeOut] parameter
  ///
  /// The [fromMap] function is used the convert the response json to
  /// model [T] this can either be provided during bloc initialization
  /// in the provider or can be specified in this function. In case
  /// it is given in both places the function one is given presidence.
  ///
  /// Use the [enableLog] flag to show logs for the request in debug
  /// console
  Future<void> postRequest({
    required String handle,
    String? baseUrl,
    Map<String, String>? header,
    dynamic body,
    T Function(dynamic json)? fromMap,
    Duration? timeOut,
    bool? enableLogs,
  }) async {
    // check if fromMap function is provided
    assert((fromMap != null || this.fromMap != null),
        'fromMap function cannot be null!!! Either provide the fromMap function directly in this function or use the optional fromMap function while initializing the bloc');

    // check if url is provided
    assert(
        !(['', null].contains(baseUrl) &&
            ['', null].contains(ApiConfig.baseUrl)),
        'Both baseUrl and ApiConfig cannot be set as null at the same time');
    request(
      GereralRepository()
          .post(
            httpClient,
            handle: handle,
            baseUrl: baseUrl,
            header: header,
            body: body,
            timeOut: timeOut,
            enableLogs: enableLogs!,
          )
          .then(
            (value) => toModel(fromMap, value)!,
          ),
    );
  }

  /// Used to convert a locally provided [json] String to object [T]
  ///
  /// Use the [enableLog] flag to show logs for the request in debug
  /// console
  Future<void> localRequest(
    String json, {
    bool? enableLogs = false,
  }) async {
    // check if json is provided
    assert(!(['', null].contains(json)), 'JSON string is required!');

    request(
      GereralRepository()
          .local(
            json,
            enableLogs: enableLogs!,
          )
          .then(
            (value) => toModel(fromMap, value)!,
          ),
    );
  }

  /// This function converts th given [json] to model [T] using the
  /// funtion [fromMap] and returns the model
  ///
  /// In case of conversation failure it throws [FormatException]
  T? toModel(T Function(dynamic json)? fromMap, Map<String, dynamic>? json) {
    late T result;
    try {
      result = fromMap?.call(json) ?? this.fromMap!.call(json);
    } catch (e) {
      throw FormatException(e.toString());
    }
    return result;
  }

  @override
  Future<void> close() {
    httpClient.close();
    return super.close();
  }
}
