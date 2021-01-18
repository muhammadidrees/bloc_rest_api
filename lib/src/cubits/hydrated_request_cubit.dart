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

  void emitCurrentState() {
    emit(state);
  }

  void emptyCubit() {
    emit(RequestState<T>.empty());
  }

  void updateModel(T model) {
    emit(RequestState<T>.success(model));
  }

  /// Used to initiate a [GET] request
  ///
  /// The [handle] is end point that will be attached to the [baseUrl]
  /// which either can be provided as a whole using the [ApiConfig]
  /// setting or can be overidden as it is given as an option parameter
  /// in the function.
  ///
  /// Same thing applies for the [header] parameter
  void getRequest({
    @required String handle,
    String baseUrl,
    Map<String, String> header,
  }) async {
    emit(RequestState<T>.loading());
    await GereralRepository()
        .get(
      httpClient,
      handle: handle,
      baseUrl: baseUrl,
      header: header,
    )
        .then((value) {
      T apiResponse = fromMap(value);
      emit(RequestState<T>.success(apiResponse));
    }).catchError((error) {
      emit(RequestState<T>.failure(error.toString()));
    });
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
  }) async {
    emit(RequestState<T>.loading());
    GereralRepository()
        .post(
      httpClient,
      handle: handle,
      baseUrl: baseUrl,
      header: header,
      body: body,
    )
        .then((value) {
      T apiResponse = fromMap(value);
      emit(RequestState<T>.success(apiResponse));
    }).catchError((error) {
      emit(RequestState<T>.failure(error.toString()));
    });
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
