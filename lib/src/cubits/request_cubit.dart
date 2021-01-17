part of 'cubits.dart';

class RequestCubit<T extends ResultModel> extends Cubit<RequestState> {
  RequestCubit({@required this.model}) : super(RequestState.empty());
  final T model;

  /// Emits current state of bloc
  void emitCurrentState() {
    emit(state);
  }

  /// Empties out the bloc and emits the empty state
  void emptyCubit() {
    emit(RequestState.empty());
  }

  void updateModel(T model) {
    emit(RequestState.success(model));
  }

  void getRequest({
    @required String handle,
    String baseUrl,
    Map<String, String> header,
  }) async {
    emit(RequestState.loading());
    await GereralResponseRepository()
        .get(handle: handle, baseUrl: baseUrl, header: header)
        .then((value) {
      var apiResponse;
      if (value is List) {
        apiResponse = List<T>.from(value.map((x) => model.fromJson(x)));
      } else {
        apiResponse = model.fromJson(value);
      }
      emit(RequestState.success(apiResponse));
    }).catchError((error) {
      emit(RequestState.failure(error.toString()));
    });
  }

  void postRequest({
    @required String handle,
    String baseUrl,
    Map<String, String> header,
    String body,
  }) async {
    emit(RequestState.loading());
    await GereralResponseRepository()
        .post(handle: handle, baseUrl: baseUrl, header: header, body: body)
        .then((value) {
      var apiResponse;
      if (value is List) {
        apiResponse = List<T>.from(value.map((x) => model.fromJson(x)));
      } else {
        apiResponse = model.fromJson(value);
      }

      emit(RequestState.success(apiResponse));
    }).catchError((error) {
      emit(RequestState.failure(error.toString()));
    });
  }
}
