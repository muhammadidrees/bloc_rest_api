part of 'cubits.dart';

class RequestCubit<T extends ResultModel> extends Cubit<RequestState<T>> {
  RequestCubit({@required this.model}) : super(RequestState<T>.empty());
  final T model;

  void emitCurrentState() {
    emit(state);
  }

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
    emit(RequestState<T>.loading());
    await GereralResponseRepository()
        .get(handle: handle, baseUrl: baseUrl, header: header)
        .then((value) {
      var apiResponse = model.fromJson(value);

      emit(RequestState<T>.success(apiResponse));
    }).catchError((error) {
      emit(RequestState<T>.failure(error.toString()));
    });
  }

  void postRequest({
    @required String handle,
    String baseUrl,
    Map<String, String> header,
    String body,
  }) async {
    emit(RequestState<T>.loading());
    await GereralResponseRepository()
        .post(handle: handle, baseUrl: baseUrl, header: header, body: body)
        .then((value) {
      var apiResponse = model.fromJson(value);

      emit(RequestState<T>.success(apiResponse));
    }).catchError((error) {
      emit(RequestState<T>.failure(error.toString()));
    });
  }
}
