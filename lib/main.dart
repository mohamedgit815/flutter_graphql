import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_graphql_app/Model/products_model.dart';
import 'package:flutter_graphql_app/Model/riverpod_page.dart';
import 'package:flutter_graphql_app/graphql_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';



const productsGraphQl = """
query products{
  products(first: 10, channel: "default-channel") {
    edges {
      node {
        id
        name
        description
        thumbnail{
          url
        }
      }
    }
  }
}
""";
Future<void> main() async{
  final HttpLink _httpLink = HttpLink("https://demo.saleor.io/graphql/");

  final ValueNotifier<GraphQLClient> _client = ValueNotifier(GraphQLClient(
      link: _httpLink ,
      cache: GraphQLCache(store: InMemoryStore())
  ));


  final GraphQLProvider _runApp = GraphQLProvider(client: _client,child: const ProviderScope(child:  MyApp()));


  runApp(_runApp);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Example") ,
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: (){
          Navigator.of(context).push(CupertinoPageRoute(builder: (context)=> const GraphQlPage()));
          }),

        IconButton(
            icon: const Icon(Icons.watch),
            onPressed: (){
              Navigator.of(context).push(CupertinoPageRoute(builder: (context)=> const RiverPodPage()));
            }),
        ],
      ),

      body: Query(
        options: QueryOptions(document: gql(productsGraphQl)) ,
        builder: (QueryResult result , {FetchMore? fetchMore ,VoidCallback? refetch}) {

          if(result.hasException) {
            return const Text("hasException");
          }

          if(result.isLoading || result.data == null) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (context,i)=> const Divider(thickness: 3),
                    itemCount: result.data!.length ,
                    itemBuilder: (context , i) {
                      final List<dynamic> _productList = result.data!['products']['edges'];
                      return ListTile(
                        title: Text(_productList[i]!['node']['name']),
                        subtitle: Text(_productList[i]!['node']['description']),
                        leading: CircleAvatar(backgroundImage: NetworkImage(_productList[i]!['node']['thumbnail']['url']),),
                      );
                    },
                  ),
                ),
              ],
            );
          }

      ),
    );
  }
}

