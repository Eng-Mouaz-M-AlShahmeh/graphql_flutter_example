/* Developed by Eng Mouaz M AlShahmeh */
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter GraphQL Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> characters = [];
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : characters.isEmpty
              ? Center(
                  child: ElevatedButton(
                    child: const Text("Fetch GraphQL API"),
                    onPressed: () {
                      fetchData();
                    },
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListView.builder(
                      itemCount: characters.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                '${characters[index]['image']}',
                              ),
                            ),
                            title: Text(
                              characters[index]['name'],
                            ),
                          ),
                        );
                      }),
                ),
    );
  }

  void fetchData() async {
    setState(() {
      _loading = true;
    });
    HttpLink link = HttpLink("https://rickandmortyapi.com/graphql");
    GraphQLClient qlClient = GraphQLClient(
      link: link,
      cache: GraphQLCache(
        store: HiveStore(),
      ),
    );
    QueryResult queryResult = await qlClient.query(
      QueryOptions(
        document: gql("""
query {
  characters(page: 1) {
    results {
      name
      image 
      location {
        name
      }
      created
    }
  }
}
"""),
      ),
    );

    setState(() {
      characters = queryResult.data!['characters']['results'];
      _loading = false;
    });
  }
}
