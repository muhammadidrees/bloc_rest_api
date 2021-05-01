import 'package:bloc_rest_api/bloc_rest_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

// Create a MockClient using the Mock class provided by the Mockito package.
// Create new instances of this class in each test.
class MockClient extends Mock implements http.Client {}

void main() {
  group('getPost', () {
    test('returns a Post if the http call completes successfully', () async {
      final client = MockClient();
      final repository = GereralRepository();

      when(client.get('https://jsonplaceholder.typicode.com/posts/1'))
          .thenAnswer((_) async => http.Response("{'title': 'Test'}", 200));

      expect(
          await repository.get(
            client,
            handle: 'posts/1',
            baseUrl: 'https://jsonplaceholder.typicode.com/',
          ),
          isA<dynamic>());
    });

    test('throws an exception if the http call completes with an error', () {
      final client = MockClient();
      final repository = GereralRepository();

      // Use Mockito to return an unsuccessful response when it calls the
      // provided http.Client.
      when(client.get('https://jsonplaceholder.typicode.com/posts/1'))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(
          repository.get(
            client,
            handle: 'posts/1',
            baseUrl: 'https://jsonplaceholder.typicode.com/',
          ),
          throwsException);
    });
  });

  group('postPost', () {
    test('returns a Post if the http call completes successfully', () async {
      final client = MockClient();
      final repository = GereralRepository();

      when(client.post('https://jsonplaceholder.typicode.com/posts/1'))
          .thenAnswer((_) async => http.Response("{'title': 'Test'}", 200));

      expect(
          await repository.post(
            client,
            handle: 'posts/1',
            baseUrl: 'https://jsonplaceholder.typicode.com/',
          ),
          isA<dynamic>());
    });

    test('throws an exception if the http call completes with an error', () {
      final client = MockClient();
      final repository = GereralRepository();

      // Use Mockito to return an unsuccessful response when it calls the
      // provided http.Client.
      when(client.post('https://jsonplaceholder.typicode.com/posts/1'))
          .thenAnswer((_) async => http.Response('Unauthorized', 401));

      expect(
          repository.post(
            client,
            handle: 'posts/1',
            baseUrl: 'https://jsonplaceholder.typicode.com/',
          ),
          throwsException);
    });
  });
}
