import 'dart:io';

import 'package:bloc_rest_api/bloc_rest_api.dart';
import 'package:bloc_rest_api/src/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

// Create a MockClient using the Mock class provided by the Mockito package.
// Create new instances of this class in each test.
class MockClient extends Mock implements http.Client {}

void main() {
  group('get request', () {
    final client = MockClient();
    final repository = GereralRepository();

    group('basic functionality', () {
      test(
        'returns json Map if the http call completes successfully',
        () async {
          when(
            client.get('https://jsonplaceholder.typicode.com/posts/1'),
          ).thenAnswer(
            (_) async => http.Response('{"title": "Test"}', 200),
          );

          expect(
            await repository.get(
              client,
              handle: 'posts/1',
              baseUrl: 'https://jsonplaceholder.typicode.com/',
              enableLogs: true,
            ),
            isA<Map<String, dynamic>>(),
          );
        },
      );

      test(
        'throws an FetchDataException if the http call completes with an error',
        () {
          when(
            client.get('https://jsonplaceholder.typicode.com/posts/1'),
          ).thenAnswer(
            (_) async => http.Response('Not Found', 404),
          );

          expect(
            repository.get(
              client,
              handle: 'posts/1',
              baseUrl: 'https://jsonplaceholder.typicode.com/',
            ),
            throwsA(isA<FetchDataException>()),
          );
        },
      );
    });

    group('status code exceptions test', () {
      test(
        'throws an BadRequestException if the http call completes with status code 500',
        () {
          when(
            client.get('https://jsonplaceholder.typicode.com/posts/1'),
          ).thenAnswer(
            (_) async => http.Response('BadRequestException', 400),
          );

          expect(
            repository.get(
              client,
              handle: 'posts/1',
              baseUrl: 'https://jsonplaceholder.typicode.com/',
            ),
            throwsA(isA<BadRequestException>()),
          );
        },
      );

      test(
        'throws an UnauthorisedException if the http call completes with status code 401',
        () {
          when(
            client.get('https://jsonplaceholder.typicode.com/posts/1'),
          ).thenAnswer(
            (_) async => http.Response('Unauthorized', 401),
          );

          expect(
            repository.get(
              client,
              handle: 'posts/1',
              baseUrl: 'https://jsonplaceholder.typicode.com/',
            ),
            throwsA(isA<UnauthorisedException>()),
          );
        },
      );

      test(
        'throws an UnauthorisedException if the http call completes with status code 403',
        () {
          when(
            client.get('https://jsonplaceholder.typicode.com/posts/1'),
          ).thenAnswer(
            (_) async => http.Response('Unauthorized', 403),
          );

          expect(
            repository.get(
              client,
              handle: 'posts/1',
              baseUrl: 'https://jsonplaceholder.typicode.com/',
            ),
            throwsA(isA<UnauthorisedException>()),
          );
        },
      );

      test(
        'throws an UnauthorisedException if the http call completes with status code 500',
        () {
          when(
            client.get('https://jsonplaceholder.typicode.com/posts/1'),
          ).thenAnswer(
            (_) async => http.Response('Server Error', 500),
          );

          expect(
            repository.get(
              client,
              handle: 'posts/1',
              baseUrl: 'https://jsonplaceholder.typicode.com/',
            ),
            throwsA(isA<FetchDataException>()),
          );
        },
      );
    });

    group('Timeout check', () {
      test(
        'pass if the http call returns before the given timeout time',
        () async {
          when(
            client.get('https://jsonplaceholder.typicode.com/posts/1'),
          ).thenAnswer(
            (_) async {
              await Future.delayed(const Duration(milliseconds: 200), () {});
              return http.Response('{"title": "Test"}', 200);
            },
          );

          expect(
            await repository.get(
              client,
              handle: 'posts/1',
              baseUrl: 'https://jsonplaceholder.typicode.com/',
              timeOut: Duration(seconds: 1),
            ),
            isA<Map<String, dynamic>>(),
          );
        },
      );
      test(
        'throws an TimeOutException if the http call timesout by the given timeout time',
        () {
          when(
            client.get('https://jsonplaceholder.typicode.com/posts/1'),
          ).thenAnswer(
            (_) async {
              await Future.delayed(const Duration(milliseconds: 400), () {});
              return http.Response('{"title": "Test"}', 200);
            },
          );

          expect(
            repository.get(
              client,
              handle: 'posts/1',
              baseUrl: 'https://jsonplaceholder.typicode.com/',
              timeOut: Duration(milliseconds: 300),
            ),
            throwsA(isA<TimeOutExceptionC>()),
          );
        },
      );
    });

    group('Socket Exception / No Internet', () {
      test(
        'throws an UnauthorisedException if the http call completes with status code 500',
        () {
          when(
            client.get('https://jsonplaceholder.typicode.com/posts/1'),
          ).thenThrow(SocketException('No internet connection'));

          expect(
            repository.get(
              client,
              handle: 'posts/1',
              baseUrl: 'https://jsonplaceholder.typicode.com/',
            ),
            throwsA(isA<FetchDataException>()),
          );
        },
      );
    });
  });
}
