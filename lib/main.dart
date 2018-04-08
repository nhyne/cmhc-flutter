import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';

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

  Map _protocols;
  final _suggestions = <WordPair> [];
  final _biggerFont = const TextStyle(fontSize: 18.0);

  Future<List> _getProtocols() async {
    var httpClient = new HttpClient();
    httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    var url = 'https://cmhc-protocols.org/api/protocols';

    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    Map data = json.decode(responseBody);
    // print(data['data']);
    return data['data'];
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    List values = snapshot.data;
    print(values);
    return new ListView.builder(
      itemCount: values.length,
      padding: const EdgeInsets.all(16.0),
      // The itemBuilder callback is called once per suggested word pairing,
      // and places each suggestion into a ListTile row.
      // For even rows, the function adds a ListTile row for the word pairing.
      // For odd rows, the function adds a Divider widget to visually
      // separate the entries. Note that the divider may be difficult
      // to see on smaller devices.
      itemBuilder: (BuildContext context, int index) {
        // Add a one-pixel-high divider widget before each row in theListView.
        if (index.isOdd) return new Divider();
        if (values == null) return new ListTile(title: 'Getting data...');
        print(values[index]);
        print(values.length);
        return _buildRow(values[index]);
      }
    );
  }

  Widget _buildRow(Map data) {
    return new ListTile(
      title: new Text(
        data['attributes']['title'],
        style: _biggerFont,
      ),
    );
  }

  Widget build(BuildContext context) {

    var futureBuilder = new FutureBuilder(
      future: _getProtocols(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return new Text('loading...');
          default:
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            else
              return createListView(context, snapshot);
        }
      }
    );
    return new Scaffold (
      appBar: new AppBar(
        title: new Text('Home Page'),
      ),
      body: futureBuilder,
    );
  }
}