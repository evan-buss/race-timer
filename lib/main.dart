import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences prefs;

Future main() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp
  ]);

  prefs = await SharedPreferences.getInstance();
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
        primarySwatch: Colors.blueGrey,
        backgroundColor: Colors.black,
        textTheme: TextTheme(
          display1: TextStyle(
              color: Colors.red, fontSize: 200, fontFamily: "Digital"),
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
  int _currentTime = prefs.getInt("defaultTime") ?? 50;
  double _fontSize = prefs.getDouble("defaultFontSize") ?? 1.0;
  bool _running = false;
  Timer _timer;
  TextEditingController controller = TextEditingController();

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
      _currentTime = prefs.getInt("defaultTime") ?? 50;
    });
  }

  Widget _timeInputModal() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              keyboardType: TextInputType.number,
              controller: controller,
              decoration: new InputDecoration(
                labelText: "Enter time in seconds",
                fillColor: Colors.white,
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(25.0),
                  borderSide: new BorderSide(),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                bottom: 10 + MediaQuery.of(context).viewInsets.bottom),
            child: RaisedButton(
              child: Text("Set Custom Time"),
              onPressed: () {
                setState(() {
                  int newTime = int.parse(controller.text);
                  if (newTime > 0 && newTime < 100) {
                    _currentTime = newTime;
                    prefs.setInt("defaultTime", _currentTime);
                    Navigator.pop(context);
                  }
                });
              },
            ),
          )
        ],
      ),
    );
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
                    if (_fontSize > 1) {
                      _fontSize -= .1;
                      prefs.setDouble("defaultFontSize", _fontSize);
                    }
                  });
                },
              ),
              IconButton(
                color: Colors.white,
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    if (_fontSize < 2.5) {
                      _fontSize += .1;
                      prefs.setDouble("defaultFontSize", _fontSize);
                    }
                  });
                },
              ),
              PopupMenuButton(
                  icon: Icon(
                    Icons.timer,
                    color: Colors.white,
                  ),
                  onSelected: (value) {
                    if (value == -1) {
                      showModalBottomSheet(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20)),
                          ),
                          context: context,
                          builder: (BuildContext context) => _timeInputModal());
                    } else {
                      prefs.setInt("defaultTime", value);
                      setState(() {
                        _currentTime = value;
                        if (_running || _timer != null) {
                          _running = false;
                          _timer.cancel();
                        }
                      });
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(child: Text("50 Seconds"), value: 50),
                      PopupMenuItem(child: Text("30 Seconds"), value: 30),
                      PopupMenuItem(child: Text("15 Seconds"), value: 15),
                      PopupMenuItem(child: Text("Custom Time"), value: -1)
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
