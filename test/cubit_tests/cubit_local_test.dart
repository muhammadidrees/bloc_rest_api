import 'dart:convert';

import 'package:bloc_rest_api/bloc_rest_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

import '../models/models.dart';

void main() {
  RequestCubit<PostModel> cubit;

  setUp(() {
    cubit = RequestCubit<PostModel>(
      fromMap: (json) => PostModel.fromJson(json),
    );
  });

  group('cubit local request test', () {
    blocTest(
      'emits [loading, success] on successful request',
      build: () => cubit,
      act: (bloc) {
        return bloc.localRequest(
          PostModel.singlePostResponse,
          enableLogs: true,
        );
      },
      expect: () => [
        RequestState<PostModel>(status: RequestStatus.loading),
        RequestState<PostModel>(
          status: RequestStatus.success,
          model: PostModel.fromJson(
            jsonDecode(PostModel.singlePostResponse),
          ),
        ),
      ],
    );

    blocTest(
      'emits [loading, failure] on request fail',
      build: () => cubit,
      act: (bloc) {
        return bloc.localRequest(
          "{'bad': 1}",
          enableLogs: true,
        );
      },
      expect: () => [
        RequestState<PostModel>(status: RequestStatus.loading),
        RequestState<PostModel>(
          status: RequestStatus.failure,
          errorMessage: FormatException().toString(),
        ),
      ],
    );

    blocTest(
      'format exception on type change in json',
      build: () => cubit,
      act: (bloc) {
        return bloc.localRequest(
          '{"userId" : "1n"}',
          enableLogs: true,
        );
      },
      expect: () => [
        RequestState<PostModel>(status: RequestStatus.loading),
        RequestState<PostModel>(
          status: RequestStatus.failure,
        ),
      ],
    );

    blocTest(
      'on failure retain data of previous success',
      build: () => cubit,
      seed: () => RequestState<PostModel>(
        status: RequestStatus.success,
        model: PostModel(userId: 1, id: 1),
      ),
      act: (bloc) {
        return bloc.localRequest(
          "{'bad': 1}",
          enableLogs: true,
        );
      },
      expect: () => [
        RequestState<PostModel>(
          status: RequestStatus.loading,
          model: PostModel(userId: 1, id: 1),
        ),
        RequestState<PostModel>(
          status: RequestStatus.failure,
          model: PostModel(userId: 1, id: 1),
        ),
      ],
    );
  });
}
