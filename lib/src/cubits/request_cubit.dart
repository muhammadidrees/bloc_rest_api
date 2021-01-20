part of 'cubits.dart';

class RequestCubit<T> extends Cubit<RequestState<T>> {
  RequestCubit(
    this.fromMap, {
    HttpClient httpClient,
  })  : this.httpClient = httpClient ?? http.Client(),
        assert(fromMap != null, "FromMap function cannot be null"),
        super(RequestState<T>.empty());

  /// for testing
  final http.Client httpClient;

  /// A function that converts the given [json] map to
  /// [T] type model
  final T Function(dynamic json) fromMap;

  /// Emits current state of bloc
  void emitCurrentState() {
    emit(state);
  }

  /// Empties out the bloc and emits the empty state
  void emptyCubit() {
    emit(RequestState<T>.empty());
  }

  /// Emits the success state with the given model
  void updateModel(T model) {
    emit(RequestState<T>.success(model));
  }

  /// A general function to control bloc with any given
  /// [requestFuntion] that returns a future of type [T]
  ///
  /// To emit an error state you can use `throw` inside your
  /// future function
  void request(Future<T> requestFunction()) async {
    emit(RequestState<T>.loading());

    await requestFunction().then((value) {
      T apiResponse = fromMap(value);
      emit(RequestState.success(apiResponse));
    }).catchError((error) {
      emit(RequestState<T>.failure(error.toString()));
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
    await GereralRepository()
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
  Future<void> close() {
    httpClient.close();
    return super.close();
  }
}
