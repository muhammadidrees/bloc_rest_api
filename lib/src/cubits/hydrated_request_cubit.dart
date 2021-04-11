part of 'cubits.dart';

class HydratedRequestCubit<T> extends Cubit<RequestState<T>>
    with HydratedMixin {
  HydratedRequestCubit({
    @required this.fromMap,
    @required this.toMap,
    http.Client httpClient,
  })  : this.httpClient = httpClient ?? http.Client(),
        assert(fromMap != null, "FromMap function cannot be null"),
        assert(toMap != null, "toMap function cannot be null"),
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
  Future<void> getRequest({
    @required String handle,
    String baseUrl,
    Map<String, String> header,
    T Function(dynamic json) fromMap,
  }) async {
    assert((fromMap != null || this.fromMap != null),
        "fromMap function cannot be null!!! Either provide the fromMap function directly in this function or use the optional fromMap function while initializing the bloc");
    request(
      GereralRepository()
          .get(
            httpClient,
            handle: handle,
            baseUrl: baseUrl,
            header: header,
          )
          .then(
            (value) => fromMap?.call(value) ?? this.fromMap.call(value),
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
  void postRequest({
    @required String handle,
    String baseUrl,
    Map<String, String> header,
    String body,
    T Function(dynamic json) fromMap,
  }) async {
    assert((fromMap != null || this.fromMap != null),
        "fromMap function cannot be null!!! Either provide the fromMap function directly in this function or use the optional fromMap function while initializing the bloc");
    request(
      GereralRepository()
          .post(
            httpClient,
            handle: handle,
            baseUrl: baseUrl,
            header: header,
            body: body,
          )
          .then(
            (value) => fromMap?.call(value) ?? this.fromMap.call(value),
          ),
    );
  }

  @override
  RequestState<T> fromJson(Map<String, dynamic> json) => RequestState<T>._(
        status: json["status"] == null
            ? null
            : enumFromString(json["status"].toString()),
        model: json["model"] == null ? null : fromMap(json["model"]),
      );

  @override
  Map<String, dynamic> toJson(RequestState<T> state) => {
        "status": state?.status?.toString() ?? RequestState<T>.empty(),
        "model": state?.model == null ? null : toMap(state.model),
      };

  @override
  Future<void> close() {
    httpClient.close();
    return super.close();
  }
}
