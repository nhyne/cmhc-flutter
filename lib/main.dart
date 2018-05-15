import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Startup Name Generator',
      home: new CmhcProtocolsList(),
    );
  }
}

class CmhcProtocolsList extends StatefulWidget {
  @override
  createState() => new ProtocolsState();
}

class ProtocolsState extends State<CmhcProtocolsList> {
  @override

  Map _protocols;
  final _biggerFont = const TextStyle(fontSize: 18.0);

  Future<List> _getProtocols() async {
    var httpClient = new HttpClient();
    httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    var url = 'https://cmhc-protocols.org/api/protocols';

    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    Map data = json.decode(responseBody);
    return data['data'];
  }

  void _selectTile(Map data) {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return new Scaffold(
            appBar: new AppBar(
              title: new Text('Steps'),  
            ),
            body: new Image.network('https://storage.googleapis.com/cmhc-protocols-production/DpwTsWs79559Sm221bh3rniR'),
          );
        }
      ),
    );
  }

  Widget createProtocolListView(BuildContext context, AsyncSnapshot snapshot) {
    List values = snapshot.data;
    return new ListView.builder(
      itemCount: values.length,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (BuildContext context, int index) {
        // Add a one-pixel-high divider widget before each row in theListView.
        return _buildProtocolRow(values[index]);
      }
    );
  }

  Widget createStepListView(BuildContext context, AsyncSnapshot snapshot) {
    List values = snapshot.data;
    return new ListView.builder(
      itemCount: values.length,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (BuildContext context, int index) {
        // Add a one-pixel-high divider widget before each row in theListView.
        return _buildStepRow(values[index]);
      }
    );
  }

  Widget _buildStepRow(Map data) {
    return new ListTile(
      title: new Text(
        data['attributes']['information'],
        style: _biggerFont,
      ),
    );
  }

  Widget _buildProtocolRow(Map data) {
    return new ListTile(
      title: new Text(
        data['attributes']['title'],
        style: _biggerFont,
      ),
      onTap: () { _selectTile(data); },
    );
  }

  Widget build(BuildContext context) {

    var futureBuilder = new FutureBuilder(
      future: _getProtocols(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return new ListTile(
              title: new Text('loading...', style: _biggerFont)
            );
          default:
            if (snapshot.hasError)
              return new Text('Error: ${snapshot.error}');
            else
              return createProtocolListView(context, snapshot);
        }
      }
    );
    return new Scaffold (
      appBar: new AppBar(
        title: new Text('Protocols'),
      ),
      body: futureBuilder,
    );
  }
}