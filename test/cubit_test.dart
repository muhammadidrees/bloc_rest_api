import 'dart:convert';

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
  group('cubit get request test', () {
    // test(
    //   'NEWER WAY BUT LONG-WINDED emits [WeatherLoading, WeatherLoaded] when successful',
    //   () {
    //     when(mockWeatherRepository.fetchWeather(any))
    //         .thenAnswer((_) async => weather);
    //     final bloc = WeatherBloc(mockWeatherRepository);
    //     bloc.add(GetWeather('London'));

    //     emitsExactly(bloc, [
    //       WeatherInitial(),
    //       WeatherLoading(),
    //       WeatherLoaded(weather),
    //     ]);
    //   },
    // );
    final client = MockClient();

    when(client.get('https://jsonplaceholder.typicode.com/posts/1')).thenAnswer(
        (_) async => http.Response(PostModel.singlePostResponse, 200));

    final cubit = RequestCubit<PostModel>(
      fromMap: (json) => PostModel.fromJson(json),
      httpClient: client,
    );

    // blocTest(
    //   'emits [] when nothing is added',
    //   build: () => cubit,
    //   expect: [],
    // );

    blocTest(
      'emits [1] when CounterEvent.increment is added',
      build: () => cubit,
      act: (bloc) => bloc.getRequest(
        baseUrl: 'https://jsonplaceholder.typicode.com/',
        handle: 'posts/1',
        enableLogs: true,
      ),
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

    //   test('throws an exception if the http call completes with an error', () {
    //     final client = MockClient();
    //     final repository = GereralRepository();

    //     // Use Mockito to return an unsuccessful response when it calls the
    //     // provided http.Client.
    //     when(client.get('https://jsonplaceholder.typicode.com/posts/1'))
    //         .thenAnswer((_) async => http.Response('Not Found', 404));

    //     expect(
    //         repository.get(
    //           client,
    //           handle: 'posts/1',
    //           baseUrl: 'https://jsonplaceholder.typicode.com/',
    //         ),
    //         throwsException);
    //   });
  });
}
