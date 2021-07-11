import 'dart:convert';

import 'package:bloc_rest_api/bloc_rest_api.dart';
import 'package:bloc_rest_api/src/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:bloc_test/bloc_test.dart';
import 'package:path_provider/path_provider.dart';

import '../models/models.dart';
import '../usage_test.mocks.dart';

void main() {
  late http.Client client;
  late HydratedRequestCubit<PostModel> cubit;

  setUpAll(() async {
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: kIsWeb
          ? HydratedStorage.webStorageDirectory
          : await getTemporaryDirectory(),
    );
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

  group('hydrated cubit get request test', () {
    blocTest(
      'emits [loading, success] on successful request',
      build: () => cubit,
      act: (RequestCubit<PostModel> bloc) {
        when(client
                .get(Uri.parse('https://jsonplaceholder.typicode.com/posts/1')))
            .thenAnswer(
                (_) async => http.Response(PostModel.singlePostResponse, 200));

        return bloc.getRequest(
          baseUrl: 'https://jsonplaceholder.typicode.com/',
          handle: 'posts/1',
          enableLogs: true,
        );
      },
      expect: () => [
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
      act: (RequestCubit<PostModel> bloc) {
        when(client
                .get(Uri.parse('https://jsonplaceholder.typicode.com/posts/1')))
            .thenAnswer((_) async => http.Response('BadRequestException', 400));

        return bloc.getRequest(
          baseUrl: 'https://jsonplaceholder.typicode.com/',
          handle: 'posts/1',
          enableLogs: true,
        );
      },
      expect: () => [
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
      seed: () => RequestState<PostModel>(
        status: RequestStatus.success,
        model: PostModel.fromJson(
          jsonDecode(PostModel.singlePostResponse),
        ),
      ),
      act: (RequestCubit<PostModel> bloc) {
        return bloc.emptyCubit();
      },
      expect: () => [
        RequestState<PostModel>(
          status: RequestStatus.empty,
        ),
      ],
    );

    blocTest(
      'updates model manually by calling updateModel',
      build: () => cubit,
      seed: () => RequestState<PostModel>(
        status: RequestStatus.success,
        model: PostModel.fromJson(
          jsonDecode(PostModel.singlePostResponse),
        ),
      ),
      act: (RequestCubit<PostModel> bloc) {
        return bloc.updateModel(
          PostModel(userId: 2, id: 2),
        );
      },
      expect: () => [
        RequestState<PostModel>(
          status: RequestStatus.success,
          model: PostModel(userId: 2, id: 2),
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
      act: (RequestCubit<PostModel> bloc) {
        when(client
                .get(Uri.parse('https://jsonplaceholder.typicode.com/posts/1')))
            .thenAnswer((_) async => http.Response('BadRequestException', 400));

        return bloc.getRequest(
          baseUrl: 'https://jsonplaceholder.typicode.com/',
          handle: 'posts/1',
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
