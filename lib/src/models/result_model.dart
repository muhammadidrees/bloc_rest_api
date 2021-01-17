part of 'models.dart';

/// A model class need to extend the result model class
abstract class ResultModel {
  /// Converts model to json
  @required
  ResultModel fromJson(Map<String, dynamic> json);

  /// Converts json to model
  @required
  Map<String, dynamic> toJson();
}

mixin ResultMixin {
  /// Converts model to json
  @required
  ResultModel fromJson(Map<String, dynamic> json);

  /// Converts json to model
  @required
  Map<String, dynamic> toJson();
}
