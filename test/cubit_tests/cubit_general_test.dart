import 'dart:convert';

import 'package:bloc_rest_api/bloc_rest_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:bloc_test/bloc_test.dart';

import '../models/models.dart';

// Create a MockClient using the Mock class provided by the Mockito package.
// Create new instances of this class in each test.
class MockClient extends Mock implements http.Client {}

void main() {
  RequestCubit<PostModel> cubit;

  setUp(() {
    cubit = RequestCubit<PostModel>(
      fromMap: (json) => PostModel.fromJson(json),
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('cubit get request test', () {
    blocTest(
      'emits [empty] when emptyCubit() is called',
      build: () => cubit,
      seed: () => RequestState<PostModel>(
        status: RequestStatus.success,
        model: PostModel.fromJson(
          jsonDecode(PostModel.singlePostResponse),
        ),
      ),
      act: (bloc) {
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
      act: (bloc) {
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
  });
}
