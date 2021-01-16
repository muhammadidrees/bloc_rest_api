import 'package:bloc_rest_api/bloc_rest_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => RequestCubit<PostModel>(model: PostModel()),
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
          context.read<RequestCubit<PostModel>>().getRequest(
                handle: "posts/1",
              );
        },
        child: Icon(Icons.add),
      ),
      body: BlocBuilder<RequestCubit<PostModel>, RequestState>(
        builder: (context, state) {
          switch (state.status) {
            case RequestStatus.empty:
              return Center(child: Text("Press the button to get some data"));

            case RequestStatus.loading:
              return Center(child: CircularProgressIndicator());

            case RequestStatus.success:
              return Center(child: Text(state.model.toString()));

            case RequestStatus.failure:
              return Center(child: Text(state.errorMessage));
            default:
              return Container();
          }
        },
      ),
    );
  }
}
