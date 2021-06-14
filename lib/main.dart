import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(Root());
}

class Root extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      debugShowCheckedModeBanner: false,
      home: Joke(title: 'Random Joke Generator'),
    );
  }
}

Future<Map<String, dynamic>> get(String url) async {
  print('Api Get, url $url');
  var responseJson;
  try {
    Uri uri = Uri.parse(url);
    final response = await http.get(uri);
    responseJson = _returnResponse(response);
  } on SocketException {
    print('No net');
  }
  print('api get received!');
  return responseJson;
}

Map<String, dynamic>? _returnResponse(http.Response response) {
  switch (response.statusCode) {
    case 200:
      Map<String, dynamic> responseJson = jsonDecode(response.body.toString());
      print(responseJson);
      return responseJson;
    default:
      print(
          'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
  }
}

class JokeData {
  JokeData({required this.setup, required this.delivery});

  String? setup = '';
  String? delivery = '';

  String toString() {
    return "${setup}, ${delivery}";
  }

  JokeData.fromJson(Map<String, dynamic> json) {
    this.setup = json['setup']!=null ? json['setup'] : null;
    this.delivery = json['delivery']!=null ? json['delivery'] : null;
  }
}

class Joke extends StatefulWidget {
  Joke({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _JokeState createState() => _JokeState();
}

class _JokeState extends State<Joke> {
  late JokeData _data;
  String _joke = 'Loading';
  String _delivery = 'Loading';
  String _category = 'Programming';

  @override
  void initState() {
    super.initState();

    _generate();
  }

  Future _generate() async {
    final response = await get("https://v2.jokeapi.dev/joke/" + _category);
    print(response.toString());
    _data = JokeData.fromJson(response);
    if(_data.delivery == null || _data.setup == null) {
      print("ERROR - restarting Joke due to missing key data ===================================");
      setState(() {
        _joke = "Loading...";
        _delivery = "Loading...";
      });
      _generate();
      return;
    }
    print("setup: ${_data.setup}");
    print("delivery: ${_data.delivery}");
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _joke without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _joke = "${_data.setup}";
      _delivery = "${_data.delivery}";
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _generate method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the Joke object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Container(
          margin: EdgeInsets.all(30.0),
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              DropdownButton<String>(
                value: _category,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _category = newValue!;
                  });
                  _generate();
                },
                items: <String>['Any', 'Misc', 'Programming', 'Dark', 'Pun', 'Spooky', 'Christmas']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 100),
              Text(
                '$_joke',
                style: Theme.of(context).textTheme.headline4,
              ),
              SizedBox(height: 30),
              Text(
                '$_delivery',
                style: Theme.of(context).textTheme.headline4,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _generate,
        tooltip: 'Generate',
        child: Icon(Icons.calculate),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
