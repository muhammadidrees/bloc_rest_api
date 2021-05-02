import 'dart:convert';

import 'package:bloc_rest_api/bloc_rest_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'models/models.dart';

void main() {
  // Specify the base url
  ApiConfig.baseUrl = "https://jsonplaceholder.typicode.com/";
  // Specify base header for response
  ApiConfig.header = {"Content-Type": "application/json"};
  runApp(App());
}

class App extends StatelessWidget {
  App({Key key}) : super(key: key);

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // for single model
        BlocProvider(
          create: (context) => RequestCubit<PostModel>(
            fromMap: (json) => PostModel.fromJson(json),
          ),
        ),
        BlocProvider(
          create: (context) => HydratedRequestCubit<PostModel>(
            fromMap: (json) => PostModel.fromJson(json),
            toMap: (model) => model.toJson(),
          ),
        ),
        // for list of posts simply update type and fromMap method
        BlocProvider(
          create: (context) => RequestCubit<List<PostModel>>(
            fromMap: (json) =>
                List<PostModel>.from(json.map((x) => PostModel.fromJson(x))),
          ),
        ),
      ],
      child: AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(title: 'Example App'),
    );
  }
}

class HomePage extends StatelessWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // context.read<RequestCubit<PostModel>>().request(fetchAlbum());
          context.read<RequestCubit<PostModel>>().getRequest(
                handle: 'posts/1',
              );
        },
        child: Icon(Icons.add),
      ),
      body: BlocConsumer<RequestCubit<PostModel>, RequestState<PostModel>>(
        listener: (context, state) {
          if (state.status == RequestStatus.failure) {
            Scaffold.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
        },
        builder: (context, state) {
          switch (state.status) {
            case RequestStatus.empty:
              return Center(child: Text("Press the button to get some data"));

            case RequestStatus.loading:
              return Center(child: CircularProgressIndicator());

            case RequestStatus.success:
            case RequestStatus.failure:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(state.model.toString()),
                ),
              );

            default:
              return Container();
          }
        },
      ),
    );
  }
}

Future<PostModel> fetchAlbum() async {
  final response =
      await http.get('https://jsonplaceholder.typicode.com/posts/1');

  if (response.statusCode == 200) {
    return PostModel.fromJson(jsonDecode(response.body));
  } else {
    // Any exception thrown will emit failure state
    throw Exception('Failed to load album');
  }
}
