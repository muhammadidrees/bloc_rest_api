import 'dart:io';
import 'dart:developer' as developer;

import 'package:bloc_rest_api/src/general_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

part 'request_state.dart';
part 'request_cubit.dart';
part 'hydrated_request_cubit.dart';
