import 'dart:convert';

import 'package:bloc_rest_api/bloc_rest_api.dart';
import 'package:bloc_rest_api/src/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:bloc_test/bloc_test.dart';

import '../models/models.dart';

// Create a MockClient using the Mock class provided by the Mockito package.
// Create new instances of this class in each test.
class MockClient extends Mock implements http.Client {}

void main() {
  http.Client client;
  RequestCubit<PostModel> cubit;

  setUp(() {
    client = MockClient();
    cubit = RequestCubit<PostModel>(
      fromMap: (json) => PostModel.fromJson(json),
      httpClient: client,
    );
  });

  tearDown(() {
    client.close();
    cubit.close();
  });

  group('cubit post request test', () {
    blocTest(
      'emits [loading, success] on successful request',
      build: () => cubit,
      act: (bloc) {
        when(client.post(
          'https://jsonplaceholder.typicode.com/posts/1',
          body: {'post': 1},
        )).thenAnswer(
            (_) async => http.Response(PostModel.singlePostResponse, 200));

        return bloc.postRequest(
          baseUrl: 'https://jsonplaceholder.typicode.com/',
          handle: 'posts/1',
          body: {'post': 1},
          enableLogs: true,
        );
      },
      expect: [
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
        when(client.post(
          'https://jsonplaceholder.typicode.com/posts/1',
          body: {'post': 1},
        )).thenAnswer((_) async => http.Response('NotFound', 404));

        return bloc.postRequest(
          baseUrl: 'https://jsonplaceholder.typicode.com/',
          handle: 'posts/1',
          body: {'post': 1},
          enableLogs: true,
        );
      },
      expect: [
        RequestState<PostModel>(status: RequestStatus.loading),
        RequestState<PostModel>(
          status: RequestStatus.failure,
          errorMessage: FetchDataException('NotFound').toString(),
        ),
      ],
    );

    blocTest(
      'emits [loading, failure] on timeout fail',
      build: () => cubit,
      wait: Duration(milliseconds: 400),
      act: (bloc) {
        when(client.post(
          'https://jsonplaceholder.typicode.com/posts/1',
          body: {'post': 1},
        )).thenAnswer(
          (_) async {
            await Future.delayed(const Duration(milliseconds: 400), () {});
            return http.Response('{"title": "Test"}', 200);
          },
        );

        return bloc.postRequest(
          baseUrl: 'https://jsonplaceholder.typicode.com/',
          handle: 'posts/1',
          body: {'post': 1},
          enableLogs: true,
          timeOut: Duration(milliseconds: 300),
        );
      },
      expect: [
        RequestState<PostModel>(status: RequestStatus.loading),
        RequestState<PostModel>(
          status: RequestStatus.failure,
          errorMessage: TimeOutExceptionC().toString(),
        ),
      ],
    );

    blocTest(
      'emits [loading, success] when response within timeout',
      build: () => cubit,
      wait: Duration(milliseconds: 200),
      act: (bloc) {
        when(client.post('https://jsonplaceholder.typicode.com/posts/1'))
            .thenAnswer(
          (_) async {
            await Future.delayed(const Duration(milliseconds: 200), () {});
            return http.Response('{"title": "Test"}', 200);
          },
        );

        return bloc.postRequest(
          baseUrl: 'https://jsonplaceholder.typicode.com/',
          handle: 'posts/1',
          enableLogs: true,
          timeOut: Duration(milliseconds: 300),
        );
      },
      expect: [
        RequestState<PostModel>(status: RequestStatus.loading),
        RequestState<PostModel>(
          status: RequestStatus.failure,
          errorMessage: TimeOutExceptionC().toString(),
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
        when(client.post('https://jsonplaceholder.typicode.com/posts/1'))
            .thenAnswer((_) async => http.Response('BadRequestException', 400));

        return bloc.postRequest(
          baseUrl: 'https://jsonplaceholder.typicode.com/',
          handle: 'posts/1',
          body: {'post': 1},
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
