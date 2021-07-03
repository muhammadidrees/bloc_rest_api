import 'package:bloc_rest_api/bloc_rest_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:bloc_test/bloc_test.dart';

import 'models/models.dart';

// Create a MockClient using the Mock class provided by the Mockito package.
// Create new instances of this class in each test.
class MockClient extends Mock implements http.Client {}

void main() {
  group(
    'check fromMap assertion',
    () {
      final client = MockClient();

      when(client.get('https://jsonplaceholder.typicode.com/posts/1'))
          .thenAnswer(
        (_) async => http.Response(
          PostModel.singlePostResponse,
          200,
        ),
      );

      final cubitWithFromMap = RequestCubit<PostModel>(
        fromMap: (json) => PostModel.fromJson(json),
        httpClient: client,
      );

      final cubitWithoutFromMap = RequestCubit<PostModel>(
        httpClient: client,
      );

      blocTest(
        'pass if fromMap is passed with cubit instead of function',
        build: () => cubitWithFromMap,
        act: (bloc) => bloc.getRequest(
          baseUrl: 'https://jsonplaceholder.typicode.com/',
          handle: 'posts/1',
        ),
      );

      blocTest(
        'pass if fromMap is passed with the function instead with cubit',
        build: () => cubitWithoutFromMap,
        act: (bloc) => bloc.getRequest(
          baseUrl: 'https://jsonplaceholder.typicode.com/',
          handle: 'posts/1',
          fromMap: (json) => PostModel.fromJson(json),
        ),
      );

      blocTest(
        'expect assertion if fromMap is neither passed with the function not with cubit',
        build: () => cubitWithoutFromMap,
        act: (bloc) => expect(
          bloc.getRequest(
            baseUrl: 'https://jsonplaceholder.typicode.com/',
            handle: 'posts/1',
          ),
          throwsAssertionError,
        ),
      );
    },
  );

  group(
    'check baseUrl assertion',
    () {
      final client = MockClient();

      when(client.get('https://jsonplaceholder.typicode.com/posts/1'))
          .thenAnswer(
        (_) async => http.Response(
          PostModel.singlePostResponse,
          200,
        ),
      );

      final cubit = RequestCubit<PostModel>(
        fromMap: (json) => PostModel.fromJson(json),
        httpClient: client,
      );

      blocTest(
        'pass if baseUrl is given with request function',
        build: () => cubit,
        act: (bloc) => bloc.getRequest(
          baseUrl: 'https://jsonplaceholder.typicode.com/',
          handle: 'posts/1',
        ),
      );

      blocTest(
        'expect assertion if baseUrl is neither given in config nor with request function',
        build: () => cubit,
        act: (bloc) => expect(
          bloc.getRequest(
            handle: 'posts/1',
          ),
          throwsAssertionError,
        ),
      );

      blocTest(
        'pass if baseUrl is given in config',
        build: () {
          ApiConfig.baseUrl = 'https://jsonplaceholder.typicode.com/';

          return cubit;
        },
        act: (bloc) => bloc.getRequest(
          handle: 'posts/1',
        ),
      );
    },
  );
}
