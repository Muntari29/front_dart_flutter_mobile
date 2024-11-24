import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hot reload',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'TEST'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> _categories = [];
  List<dynamic> _articles = [];
  String _response = "No response yet";

  // Fetch Categories API
  Future<void> fetchCategories() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:8080/categories'));

      if (response.statusCode == 200) {
        final List categories = json.decode(response.body);
        setState(() {
          _categories = categories;
          _response = 'Fetched categories successfully';
        });
      } else {
        setState(() {
          _response = 'Failed to fetch categories: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _response = 'Error fetching categories: $e';
      });
    }
  }

  // Fetch Articles API
  Future<void> fetchArticles({String? category}) async {
    try {
      final uri = Uri.http('localhost:8080', '/articles',
          category != null ? {'category': category} : {});
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List articles = json.decode(response.body);
        setState(() {
          _articles = articles;
          _response = 'Fetched articles successfully';
        });
      } else {
        setState(() {
          _response = 'Failed to fetch articles: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _response = 'Error fetching articles: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCategories(); // Fetch categories on app start
    fetchArticles(); // Fetch all articles on app start
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          // Categories List
          Container(
            padding: const EdgeInsets.all(10),
            height: 100,
            child: _categories.isEmpty
                ? const Center(child: Text('Loading categories...'))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return GestureDetector(
                        onTap: () => fetchArticles(category: category['name']),
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: Colors.blueAccent,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Center(
                              child: Text(
                                category['name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Articles List
          Expanded(
            child: _articles.isEmpty
                ? const Center(child: Text('No articles found'))
                : ListView.builder(
                    itemCount: _articles.length,
                    itemBuilder: (context, index) {
                      final article = _articles[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: ListTile(
                          title: Text(
                            article['value'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Category: ${article['category_name']}",
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
