part of 'cubits.dart';

enum RequestStatus { empty, loading, success, failure }

RequestStatus enumFromString(String input) {
  switch (input) {
    case "RequestStatus.empty":
      return RequestStatus.empty;

    case "RequestStatus.loading":
      return RequestStatus.loading;

    case "RequestStatus.success":
      return RequestStatus.success;

    case "RequestStatus.failure":
      return RequestStatus.failure;

    default:
      return RequestStatus.empty;
  }
}

@immutable
class RequestState<T> extends Equatable {
  const RequestState._({
    this.status = RequestStatus.empty,
    this.model,
    this.errorMessage,
  });

  const RequestState.empty() : this._();

  const RequestState.loading() : this._(status: RequestStatus.loading);

  const RequestState.success(dynamic result)
      : this._(status: RequestStatus.success, model: result);

  const RequestState.failure(String error)
      : this._(
          status: RequestStatus.failure,
          errorMessage: error,
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
  String toString() => status.toString();
}
