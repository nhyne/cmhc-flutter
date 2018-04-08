import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'dart:io';
import 'dart:convert';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Startup Name Generator',
      home: new RandomWords(),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  createState() => new RandomWordsState();
}

class RandomWordsState extends State<RandomWords> {
  @override

  var _protocols = '';
  final _suggestions = <WordPair> [];
  final _biggerFont = const TextStyle(fontSize: 18.0);

  _getProtocols() async {
    var httpClient = new HttpClient();
    httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    var url = 'https://cmhc-protocols.org/api/protocols';

    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    Map data = json.decode(responseBody);
    print(data['data']);
    setState(() {
      _protocols = data['data'];
    });
  }

  Widget _buildSuggestions() {
    return new ListView.builder(
      padding: const EdgeInsets.all(16.0),
      // The itemBuilder callback is called once per suggested word pairing,
      // and places each suggestion into a ListTile row.
      // For even rows, the function adds a ListTile row for the word pairing.
      // For odd rows, the function adds a Divider widget to visually
      // separate the entries. Note that the divider may be difficult
      // to see on smaller devices.
      itemBuilder: (context, i) {
        // Add a one-pixel-high divider widget before each row in theListView.
        if (i.isOdd) return new Divider();

        // The syntax "i ~/ 2" divides i by 2 and returns an integer result.
        // For example: 1, 2, 3, 4, 5 becomes 0, 1, 1, 2, 2.
        // This calculates the actual number of word pairings in the ListView,
        // minus the divider widgets.
        final index = i ~/ 2;
        // If you've reached the end of the available word pairings...
        if (index >= _suggestions.length) {
          // ...then generate 10 more and add them to the suggestions list.
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);
      }
    );
  }

  Widget _buildRow(WordPair data) {
    return new ListTile(
      title: new Text(
        data.asPascalCase,
        style: _biggerFont,
      ),
    );
  }

  Widget build(BuildContext context) {
    print(_protocols);
    _getProtocols();
    print(_protocols);
    return new Scaffold (
      appBar: new AppBar(
        title: new Text('Startup Name Generator'),
      ),
      body: _buildSuggestions(),
    );
  }
}