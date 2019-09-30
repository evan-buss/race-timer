import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
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
              color: Colors.red, fontSize: 200, fontFamily: "DigitalClock"),
        ),
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  final AudioCache player = AudioCache(prefix: "audio/");

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentTime = 15;
  double _fontSize = 1.0;
  bool _running = false;
  Timer _timer;

  DragStartDetails dragStart;
  DragUpdateDetails dragUpdate;

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
        if (_currentTime - 1 == 10 || _currentTime - 1 == 30) {
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
    setState(() {
      _currentTime = 15;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          ButtonBar(
            children: <Widget>[
              IconButton(
                color: Colors.white,
                icon: Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    if (_fontSize > 1) _fontSize -= .1;
                  });
                },
              ),
              IconButton(
                color: Colors.white,
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    if (_fontSize < 2.5) _fontSize += .1;
                  });
                },
              ),
              PopupMenuButton(
                  icon: Icon(
                    Icons.timer,
                    color: Colors.white,
                  ),
                  onSelected: (value) {
                    setState(() {
                      _currentTime = value;
                      _running = false;
                      _timer.cancel();
                    });
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(child: Text("50 Seconds"), value: 50),
                      PopupMenuItem(child: Text("30 Seconds"), value: 30),
                      PopupMenuItem(child: Text("15 Seconds"), value: 15)
                    ];
                  })
            ],
          ),
          Center(
            child: Text(
              '$_currentTime',
              style: Theme.of(context)
                  .textTheme
                  .display1
                  .apply(fontSizeFactor: _fontSize),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _running ? _stopCountdown : _startCountdown,
        tooltip: 'Start Countdown',
        child: _running ? Icon(Icons.stop) : Icon(Icons.play_arrow),
      ),
    );
  }
}
