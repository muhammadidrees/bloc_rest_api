import 'package:bloc_rest_api/bloc_rest_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('local', () {
    final repository = GereralRepository();

    test('returns a json if the coversion is done  call completes successfully',
        () async {
      expect(
          await repository.local(
            '{"title": "Test"}',
            enableLogs: true,
          ),
          isA<Map<String, dynamic>>());
    });

    test('throws an exception if the http call completes with an error', () {
      expect(
        repository.local(
          '{"title": "Test"Nice',
        ),
        throwsException,
      );
    });
  });
}
