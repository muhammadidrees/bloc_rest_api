part of 'cubits.dart';

class HydratedRequestCubit<T extends ResultModel> extends Cubit<RequestState<T>>
    with HydratedMixin {
  HydratedRequestCubit({@required this.model}) : super(RequestState.empty()) {
    hydrate();
  }

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
    emit(RequestState.loading());
    await GereralResponseRepository()
        .get(handle: handle, baseUrl: baseUrl, header: header)
        .then((value) {
      var apiResponse = model.fromJson(value);

      emit(RequestState<T>.success(apiResponse));
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
    emit(RequestState<T>.loading());
    GereralResponseRepository()
        .post(handle: handle, baseUrl: baseUrl, header: header, body: body)
        .then((value) {
      var apiResponse = model.fromJson(value);

      emit(RequestState<T>.success(apiResponse));
    }).catchError((error) {
      emit(RequestState.failure(error.toString()));
    });
  }

  @override
  RequestState<T> fromJson(Map<String, dynamic> json) => RequestState<T>._(
        status: json["status"] == null
            ? null
            : enumFromString(json["status"].toString()),
        model: json["model"] == null ? null : model.fromJson(json["model"]),
      );

  @override
  Map<String, dynamic> toJson(RequestState<T> state) => {
        "status": state?.status?.toString() ?? RequestState.empty(),
        "model": state?.model?.toJson() ?? null,
      };
}
