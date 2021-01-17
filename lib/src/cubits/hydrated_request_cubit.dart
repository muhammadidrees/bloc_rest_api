part of 'cubits.dart';

class HydratedRequestCubit<T extends ResultModel> extends Cubit<RequestState>
    with HydratedMixin {
  HydratedRequestCubit({@required this.model, http.Client httpClient})
      : this.httpClient = httpClient ?? http.Client(),
        super(RequestState.empty()) {
    hydrate();
  }

  final T model;
  final http.Client httpClient;

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
        .get(
      httpClient,
      handle: handle,
      baseUrl: baseUrl,
      header: header,
    )
        .then((value) {
      var apiResponse = model.fromJson(value);

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
    GereralResponseRepository()
        .post(
      httpClient,
      handle: handle,
      baseUrl: baseUrl,
      header: header,
      body: body,
    )
        .then((value) {
      var apiResponse = model.fromJson(value);

      emit(RequestState.success(apiResponse));
    }).catchError((error) {
      emit(RequestState.failure(error.toString()));
    });
  }

  @override
  RequestState fromJson(Map<String, dynamic> json) => RequestState._(
        status: json["status"] == null
            ? null
            : enumFromString(json["status"].toString()),
        model: json["model"] == null ? null : model.fromJson(json["model"]),
      );

  @override
  Map<String, dynamic> toJson(RequestState state) => {
        "status": state?.status?.toString() ?? RequestState.empty(),
        "model": state?.model?.toJson() ?? null,
      };

  @override
  Future<void> close() {
    httpClient.close();
    return super.close();
  }
}
