part of 'cubits.dart';

class HydratedRequestCubit<T> extends RequestCubit<T> with HydratedMixin {
  HydratedRequestCubit({
    @required T Function(dynamic json) fromMap,
    @required this.toMap,
    http.Client httpClient,
  })  : assert(fromMap != null, 'FromMap function cannot be null'),
        assert(toMap != null, 'toMap function cannot be null'),
        super(
          fromMap: fromMap,
          httpClient: httpClient,
        ) {
    hydrate();
  }

  /// A function that converts the given [T] type model
  /// [json] map
  final Map<String, dynamic> Function(T model) toMap;

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
