import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future main() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Race Timer',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        primarySwatch: Colors.blue,
        backgroundColor: Colors.black,
        textTheme: TextTheme(
            display1: TextStyle(
                color: Colors.red, fontSize: 200, fontFamily: "DigitalClock")),
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final AudioCache player = AudioCache(prefix: "audio/");

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentTime = 15;
  bool _running = false;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.player.loadAll(["0 seconds.mp3", "5 seconds.mp3", "10 seconds.mp3"]);
  }

  @override
  void dispose() {
    widget.player.clearCache();
    super.dispose();
  }

  _startCountdown() {
    _running = true;
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_currentTime - 1 < 0) {
        timer.cancel();
      } else {
        if (_currentTime - 1 == 10) {
          widget.player.play('10 seconds.mp3');
        } else if (_currentTime - 1 > 0 && _currentTime - 1 <= 5) {
          widget.player.play('5 seconds.mp3');
        } else if (_currentTime - 1 == 0) {
          widget.player.play('0 seconds.mp3');
        }
        setState(() {
          _currentTime--;
        });
      }
    });
  }

  _stopCountdown() {
    _running = false;
    _timer.cancel();
    _timer = null;
    setState(() {
      _currentTime = 15;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$_currentTime',
              style: Theme.of(context).textTheme.display1,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _running ? _stopCountdown : _startCountdown,
        tooltip: 'Start Countdown',
        child: _running ? Icon(Icons.stop) : Icon(Icons.play_arrow),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
