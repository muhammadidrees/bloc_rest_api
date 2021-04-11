# Bloc REST API

A flutter package to easily integrate and manage REST APIs. Now all you need to do is create a model class and all the rest is taken care of. :)

> Before using the package fimiliarize yourself with [bloc library](https://bloclibrary.dev/#/)

## Usage

To demonstrate the usage of the package we'll be using [JsonPlaceHolder](https://jsonplaceholder.typicode.com/)

First, we need to do add `bloc_rest_api` to the dependencies of the `pubspec.yaml`

```yaml
dependencies:
  bloc_rest_api: <latest version>
```

Next, we need to install it:

```sh
# Dart
pub get

# Flutter
flutter packages get
```

Now create a model class for the data that you want to fetch from the internet. This can easily be done by using online tools such as [QuickType](https://app.quicktype.io/)

In our case we'll be creating a model for Post.

```dart
import 'package:equatable/equatable.dart';

class PostModel extends Equatable {
  PostModel({
    this.userId,
    this.id,
    this.title,
    this.body,
  });

  final int userId;
  final int id;
  final String title;
  final String body;

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
        userId: json["userId"] == null ? null : json["userId"],
        id: json["id"] == null ? null : json["id"],
        title: json["title"] == null ? null : json["title"],
        body: json["body"] == null ? null : json["body"],
      );

  Map<String, dynamic> toJson() => {
        "userId": userId == null ? null : userId,
        "id": id == null ? null : id,
        "title": title == null ? null : title,
        "body": body == null ? null : body,
      };

  @override
  List<Object> get props => [userId, id];
}
```

Now create a provider for RequestCubit of type model (in our case `PostModel`) and pass in the fromMap function i.e. the fucntion that converts the incoming json to model.

```dart
MultiBlocProvider(
  providers: [
    // for single model
    BlocProvider(
      create: (context) => RequestCubit<PostModel>(
        (json) => PostModel.fromJson(json),
      ),
    ),
    // for list of posts simply update type and fromMap method
    BlocProvider(
      create: (context) => RequestCubit<List<PostModel>>(
        (json) =>
            List<PostModel>.from(json.map((x) => PostModel.fromJson(x))),
      ),
    ),
  ],
  child: AppView(),
);
```

To use the `getRequest` or `postRequest` methods simply use the `context.read()` funtion like:

```dart
context.read<RequestCubit<PostModel>>().getRequest(
      baseUrl: "https://jsonplaceholder.typicode.com/",
      handle: "posts/1",
    );
```


In case you are dealing with complex data and want to handle the mapping yourself you can you the request method that takes a function that returns Future of type T as parameter.

```dart
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

...
    context.read<RequestCubit<PostModel>>().request(fetchAlbum());
...
```

Finally react on the states by using either `BlocBuilder`, `BlocListner` or `BlocConsumer` method.

States can have one of 4 status distinguished as state.status:
     
1. RequestStatus.empty: Initial State
2. RequestStatus.loading: Loading State
3. RequestStatus.success: Success State
4. RequestStatus.error: Error State
 
__Node:__ The state retains the data on status change and is only changed either on the success state or by explicitly calling the emptyCubit method. This features allows you to show previous data even on API error.

Heres is an example builder method for PostModel:

```dart
BlocBuilder<RequestCubit<PostModel>, RequestState<PostModel>>(
  builder: (context, state) {
    switch (state.status) {
      case RequestStatus.empty:
        return Center(child: Text("Press the button to get some data"));

      case RequestStatus.loading:
        return Center(child: CircularProgressIndicator());

      case RequestStatus.success:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(state.model.toString()),
          ),
        );

      case RequestStatus.failure:
        return Center(child: Text(state.errorMessage));
      default:
        return Container();
    }
  },
),
```

#### ApiConfig

`baseUrl`, `header` and `responseTimeOut` can also be configured globally for all `RequestCubit` instances via `ApiConfig`

```dart
ApiConfig.baseUrl = "...";
ApiConfig.header = {"...": ""};
ApiConfig.responseTimeOut = Duration(...);
```

#### Other Userful Methods

You can use the updateModel method to update the state model manually.

```dart
context.read<RequestCubit<PostModel>>().updateModel(model);
```

Also you can empty or reinitialize the state using empty() method.

```dart
context.read<RequestCubit<PostModel>>().emtpy();
```

### Presisting REST APIs

Sometimes you want to presist the api data. For that you can simply replace the `RequestCubit` to `HydratedRequestCubit`.

Just make sure to provide fromMap and toMap functions in the provider.
```dart
BlocProvider(
  create: (context) => HydratedRequestCubit<PostModel>(
    fromMap: (json) => PostModel.fromJson(json),
    toMap: (model) => model.toJson(),
  ),
),
```

And also initialize the storage
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HydratedBloc.storage = await HydratedStorage.build();
  runApp(App());
}
```

And now you're state will never go away. :)
## Maintainers

- [Muhammad Idrees](https://github.com/muhammadIdrees)