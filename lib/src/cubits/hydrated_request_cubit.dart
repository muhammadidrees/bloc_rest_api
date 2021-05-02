part of 'cubits.dart';

class HydratedRequestCubit<T> extends Cubit<RequestState<T>>
    with HydratedMixin {
  HydratedRequestCubit({
    @required this.fromMap,
    @required this.toMap,
    http.Client httpClient,
  })  : httpClient = httpClient ?? http.Client(),
        assert(fromMap != null, 'FromMap function cannot be null'),
        assert(toMap != null, 'toMap function cannot be null'),
        super(RequestState<T>.empty()) {
    hydrate();
  }

  /// A function that converts the given [json] map to
  /// [T] type model
  final T Function(dynamic json) fromMap;

  /// A function that converts the given [T] type model
  /// [json] map
  final Map<String, dynamic> Function(T model) toMap;

  /// for testing
  final http.Client httpClient;

  /// emits the current state of cubit
  void emitCurrentState() {
    emit(state);
  }

  /// emptys the cubit
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
  /// Same thing applies for the [header] parameter
  ///
  /// The [fromMap] function is used the convert the response json to
  /// model [T] this can either be provided during bloc initialization
  /// in the provider or can be specified in this function. In case
  /// it is given in both places the function one is given presidence.
  ///
  /// Use the [enableLog] flag to show logs for the request in debug
  /// console
  Future<void> getRequest(
      {@required String handle,
      String baseUrl,
      Map<String, String> header,
      T Function(dynamic json) fromMap,
      bool enableLogs}) async {
    assert((fromMap != null || this.fromMap != null),
        'fromMap function cannot be null!!! Either provide the fromMap function directly in this function or use the optional fromMap function while initializing the bloc');
    request(
      GereralRepository()
          .get(
            httpClient,
            handle: handle,
            baseUrl: baseUrl,
            header: header,
            enableLogs: enableLogs,
          )
          .then(
            (value) => toModel(fromMap, value),
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
  /// Same thing applies for the [header] parameter
  ///
  /// The [fromMap] function is used the convert the response json to
  /// model [T] this can either be provided during bloc initialization
  /// in the provider or can be specified in this function. In case
  /// it is given in both places the function one is given presidence.
  ///
  /// Use the [enableLog] flag to show logs for the request in debug
  /// console
  void postRequest({
    @required String handle,
    String baseUrl,
    Map<String, String> header,
    String body,
    T Function(dynamic json) fromMap,
    bool enableLogs,
  }) async {
    assert((fromMap != null || this.fromMap != null),
        'fromMap function cannot be null!!! Either provide the fromMap function directly in this function or use the optional fromMap function while initializing the bloc');
    request(
      GereralRepository()
          .post(
            httpClient,
            handle: handle,
            baseUrl: baseUrl,
            header: header,
            body: body,
            enableLogs: enableLogs,
          )
          .then(
            (value) => toModel(fromMap, value),
          ),
    );
  }

  /// This function converts th given [json] to model [T] using the
  /// funtion [fromMap] and returns the model
  ///
  /// In case of conversation failure it throws [FormatException]
  T toModel(T Function(dynamic json) fromMap, Map<String, dynamic> json) {
    T result;
    try {
      result = fromMap?.call(json) ?? this.fromMap.call(json);
    } catch (e) {
      throw FormatException(e.toString(), result);
    }
    return result;
  }

  @override
  RequestState<T> fromJson(Map<String, dynamic> json) => RequestState<T>._(
        status: json['status'] == null
            ? null
            : enumFromString(json['status'].toString()),
        model: json['model'] == null ? null : fromMap(json['model']),
      );

  @override
  Map<String, dynamic> toJson(RequestState<T> state) => {
        'status': state?.status?.toString() ?? RequestState<T>.empty(),
        'model': state?.model == null ? null : toMap(state.model),
      };

  @override
  Future<void> close() {
    httpClient.close();
    return super.close();
  }
}
