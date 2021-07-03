part of 'cubits.dart';

enum RequestStatus { empty, loading, success, failure }

RequestStatus enumFromString(String input) {
  switch (input) {
    case 'RequestStatus.empty':
      return RequestStatus.empty;

    case 'RequestStatus.loading':
      return RequestStatus.loading;

    case 'RequestStatus.success':
      return RequestStatus.success;

    case 'RequestStatus.failure':
      return RequestStatus.failure;

    default:
      return RequestStatus.empty;
  }
}

@immutable
class RequestState<T> extends Equatable {
  const RequestState({
    this.status = RequestStatus.empty,
    this.model,
    this.errorMessage,
  });

  const RequestState._({
    this.status = RequestStatus.empty,
    this.model,
    this.errorMessage,
  });

  const RequestState.empty() : this._();

  /// This methods helps in persisting the data i.e. [model]
  /// that has once entered the bloc state.
  RequestState<T> copyWith({
    @required RequestStatus status,
    T model,
    String errorMessage,
  }) =>
      RequestState<T>(
        status: status,
        model: model ?? this.model,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  /// The status of the current state
  /// can be either [RequestStatus.empty],
  /// [RequestStatus.loading], [RequestStatus.success]
  /// or [RequestStatus.failure]
  final RequestStatus status;

  /// This is the model of type [T] to be
  /// preserved by the bloc state.
  final T model;

  /// This contains the error message caught by
  /// request function
  final String errorMessage;

  @override
  List<Object> get props => [status, model];

  @override
  String toString() => '${status.toString()} -- ${model.toString()}';
}
