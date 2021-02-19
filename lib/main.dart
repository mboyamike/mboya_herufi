import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'constants.dart';

void main() {
  Link link = HttpLink(API_URL);
  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: link,
      cache: GraphQLCache(),
    ),
  );
  runApp(MyApp(client));
}

class MyApp extends StatelessWidget {
  final ValueNotifier<GraphQLClient> client;

  MyApp(this.client);

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String queryString = """
    {
        popular_artists {
            artists {
                name
                bio
                image {
                    url
                }
            }
        }
    }
  """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GraphQL test'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Query(
          options: QueryOptions(
            document: gql(queryString),
          ),
          builder: (QueryResult result,
              {VoidCallback refetch, FetchMore fetchMore}) {
            if (result.hasException) {
              return Text(result.exception.toString());
            }

            if (result.isLoading)
              return Center(
                child: CircularProgressIndicator(),
              );

            List artists = result.data['popular_artists']['artists'];
            return ListView.separated(
              itemCount: artists.length,
              separatorBuilder: (context,_) => Divider(),
              itemBuilder: (_, index) {
                return ListTile(
                  leading: TileNetworkImage(
                    url: artists[index]['image']['url'],
                  ),
                  title: Text(artists[index]['name']),
                  subtitle: Text(artists[index]['bio']),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class TileNetworkImage extends StatelessWidget {
  final String url;

  TileNetworkImage({this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: 80,
      child: Image.network(
        url,
        fit: BoxFit.cover,
      ),
    );
  }
}
