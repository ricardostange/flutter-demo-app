import 'dart:async';
import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int N = 4;
  int _speedMult = 120;
  int _prodMult = 1;
  List<int> _prodList = new List.filled(4,0);
  List<int> _cost = new List.filled(4,0);
  List<double> _costc = [10,1000, 100000, 10000000];
  List<double> _costb = [1, 500, 50000, 5000000];
  List<double> _costa = [10, 2, .5, .15];
  List<int> _productivity = [1, 10, 100, 1000];
  List<String> _names = ['Hydrogen', 'Helium', 'Lithium', 'Beryllium'];
  var _lastTime = DateTime.now();
  int _timeCounter = 0;
  var _offlineSeconds = 30;

  void _incrementCounter() {
    setState(() {
      _counter++;
      _timeCounter++;
    });
  }

  void _prodCount(){
    setState(() {
      for(int i=0; i<N ; i++) {
        _counter += _prodList[i] * _productivity[i] * _prodMult;
      }
    });
  }

  void _mainLoop(){
    _prodCount();
    Future.delayed(Duration(milliseconds: 1000~/_speedMult), () => _mainLoop());
  }

  void _timeProd(){
    var timeOffline = _lastTime.second - DateTime.now().second;
    if(timeOffline > _offlineSeconds){
      for(int i=0; i<N; i++) {
        _timeCounter += (_prodList[i] * _productivity[i] * _prodMult ) * _speedMult * timeOffline;
      }
      _counter = _timeCounter;
    }
    _timeCounter = _counter;
    _lastTime = DateTime.now();
  }

  void _timeCorrect() {
    _timeProd();
    Future.delayed(Duration(seconds: 1), () => _timeCorrect());
  }

  void _calculateCost(){
    for(int i=0; i<N; i++){
      _cost[i] = (_costa[i] * pow(_prodList[i],2) + _costb[i] * _prodList[i] + _costc[i]).round();
    }
  }
  void _buyOne(prodNumber){
    setState(() {
      if(_counter >= _cost[prodNumber]) {
        _counter -= _cost[prodNumber];
        _prodList[prodNumber] += 1;
      }
      _calculateCost();
    });
  }

  void _buyAll(prodNumber){
    setState(() {
      while(_counter >= _cost[prodNumber]) {
        _buyOne(prodNumber);
      }
    });
  }

  String _strCounter(number) {
    List<String> mult = [' ', 'K', 'M', 'B', 'T', 'Q'];
    String modifier = ' ';
    for (int i = 0; i < mult.length; i++) {
      if ((number ~/ 10000) > 0) {
        number ~/= 1000;
      } else {
        modifier = mult[i];
        break;
      }
    }
    if (number < 1000) {
      return number.toString().toString().padLeft(3,' ') + modifier;
    } else {
      return (number ~/ 1000).toString() + ',' +
          (number % 1000).toString().padLeft(3, '0') + modifier;
    }
  }
  
  
  String _strDisplay(number, clean){
    List<String> mult = [' ', 'K', 'M', 'B', 'T', 'Q'];
    String modifier = ' ';
    String sNumber;
    for(int i=0; i<mult.length; i++){
      if((number ~/ 1000) > 0) {
        number ~/= 1000;
      }else {
        modifier = mult[i];
        break;
      }
    }
    return number.toString().padLeft(3,' ') + modifier;
  }

  List<Widget> _genWidgets() {
    List<Widget> lWid = [];
    lWid.add(new Text('${_strCounter(_counter)}', style: Theme.of(context).textTheme.headline1));
    for(int i=0; i<N; i++) {
      lWid.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: 65,
                child: Container(
                  alignment: Alignment.center,
                  child: Text('${_strDisplay(_prodList[i], false)}', style: Theme
                    .of(context)
                    .textTheme
                    .headline5),
                ),
              ),
              Text('${_names[i]}', style: Theme
                  .of(context)
                  .textTheme
                  .headline5
              ),
              Spacer(),
              FlatButton(
                onPressed: () {
                  _buyOne(i);
                },
                child: Text(
                  '${_strDisplay(_cost[i], false)}',
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyText1,
                ),
              ),
              IconButton(
                icon: Icon(Icons.local_grocery_store),
                iconSize: 36.0,
                onPressed: () {
                  _buyAll(i);
                },
              )
            ],
          ),
      );
    }
    return lWid;
  }

  @override
  void initState() {
    super.initState();
    _calculateCost();
    _mainLoop();
    _timeCorrect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: _genWidgets(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        backgroundColor: Colors.grey,
        foregroundColor: Colors.white,
        tooltip: 'Increment',
        child: Icon(Icons.monetization_on),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
