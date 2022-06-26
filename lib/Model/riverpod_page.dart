import 'package:flutter/material.dart';
import 'package:flutter_graphql_app/Model/products_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class RiverPodPage extends ConsumerStatefulWidget {
  const RiverPodPage({Key? key}) : super(key: key);

  @override
  _RiverPodPageState createState() => _RiverPodPageState();
}

class _RiverPodPageState extends ConsumerState<RiverPodPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      ref.read(_fetchData).getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(
        builder: (context,prov,_){
          return GraphQLProvider(
            client: prov.watch(_fetchData).client,
            child: Query(
                options: QueryOptions(document: gql(ProductsModel.productsGraphQl)),
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
      ),
    );
  }
}

final _fetchData = ChangeNotifierProvider<RiverPodState>((ref)=>RiverPodState());

class RiverPodState extends ChangeNotifier{
  late ValueNotifier<GraphQLClient> client = ValueNotifier(GraphQLClient(link: HttpLink(""),cache: GraphQLCache(store: InMemoryStore())));

  ValueNotifier<GraphQLClient> getData() {
    final HttpLink _httpLink = HttpLink("https://demo.saleor.io/graphql/");

    client = ValueNotifier(GraphQLClient(
        link: _httpLink ,
        cache: GraphQLCache(store: InMemoryStore())
    ));
    notifyListeners();

    return client;

  }
}