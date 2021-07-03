import 'dart:convert';

import 'package:bloc_rest_api/bloc_rest_api.dart';
import 'package:bloc_rest_api/src/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:bloc_test/bloc_test.dart';

import '../models/models.dart';

// Create a MockClient using the Mock class provided by the Mockito package.
// Create new instances of this class in each test.
class MockClient extends Mock implements http.Client {}

void main() {
  http.Client client;
  HydratedRequestCubit<PostModel> cubit;

  setUpAll(() async {
    HydratedBloc.storage = await HydratedStorage.build();
  });

  tearDownAll(() {
    HydratedBloc.storage.clear();
  });

  setUp(() {
    client = MockClient();
    cubit = HydratedRequestCubit<PostModel>(
      fromMap: (json) => PostModel.fromJson(json),
      toMap: (model) => model.toJson(),
      httpClient: client,
    );
  });

  tearDown(() {
    client.close();
    cubit.close();
  });

  group('assertion checks', () {
    test('throws an assertion error when toMap is null', () {
      expect(
        () => HydratedRequestCubit<PostModel>(
          fromMap: (json) => PostModel.fromJson(json),
          toMap: null,
          httpClient: client,
        ),
        throwsAssertionError,
      );
    });

    test('throws an assertion error when fromMap is null', () {
      expect(
        () => HydratedRequestCubit<PostModel>(
          fromMap: null,
          toMap: (model) => model.toJson(),
          httpClient: client,
        ),
        throwsAssertionError,
      );
    });
  });

  group('hydrated cubit get request test', () {
    blocTest(
      'emits [loading, success] on successful request',
      build: () => cubit,
      act: (bloc) {
        when(client.get('https://jsonplaceholder.typicode.com/posts/1'))
            .thenAnswer(
                (_) async => http.Response(PostModel.singlePostResponse, 200));

        return bloc.getRequest(
          baseUrl: 'https://jsonplaceholder.typicode.com/',
          handle: 'posts/1',
          enableLogs: true,
        );
      },
      expect: [
        RequestState<PostModel>(
          status: RequestStatus.loading,
        ),
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
        when(client.get('https://jsonplaceholder.typicode.com/posts/1'))
            .thenAnswer((_) async => http.Response('BadRequestException', 400));

        return bloc.getRequest(
          baseUrl: 'https://jsonplaceholder.typicode.com/',
          handle: 'posts/1',
          enableLogs: true,
        );
      },
      expect: [
        RequestState<PostModel>(
          status: RequestStatus.loading,
          model: PostModel.fromJson(
            jsonDecode(PostModel.singlePostResponse),
          ),
        ),
        RequestState<PostModel>(
          status: RequestStatus.failure,
          errorMessage: BadRequestException('BadRequestException').toString(),
          model: PostModel.fromJson(
            jsonDecode(PostModel.singlePostResponse),
          ),
        ),
      ],
    );

    blocTest(
      'emits [empty] when emptyCubit() is called',
      build: () => cubit,
      seed: RequestState<PostModel>(
        status: RequestStatus.success,
        model: PostModel.fromJson(
          jsonDecode(PostModel.singlePostResponse),
        ),
      ),
      act: (bloc) {
        return bloc.emptyCubit();
      },
      expect: [
        RequestState<PostModel>(
          status: RequestStatus.empty,
        ),
      ],
    );

    blocTest(
      'updates model manually by calling updateModel',
      build: () => cubit,
      seed: RequestState<PostModel>(
        status: RequestStatus.success,
        model: PostModel.fromJson(
          jsonDecode(PostModel.singlePostResponse),
        ),
      ),
      act: (bloc) {
        return bloc.updateModel(
          PostModel(userId: 2, id: 2),
        );
      },
      expect: [
        RequestState<PostModel>(
          status: RequestStatus.success,
          model: PostModel(userId: 2, id: 2),
        ),
      ],
    );

    blocTest(
      'on failure retain data of previous success',
      build: () => cubit,
      seed: RequestState<PostModel>(
        status: RequestStatus.success,
        model: PostModel(userId: 1, id: 1),
      ),
      act: (bloc) {
        when(client.get('https://jsonplaceholder.typicode.com/posts/1'))
            .thenAnswer((_) async => http.Response('BadRequestException', 400));

        return bloc.getRequest(
          baseUrl: 'https://jsonplaceholder.typicode.com/',
          handle: 'posts/1',
          enableLogs: true,
        );
      },
      expect: [
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
