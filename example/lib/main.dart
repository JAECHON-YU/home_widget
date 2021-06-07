import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:home_widget_example/coin_value.dart';
import 'package:home_widget_example/coin_web_socket.dart';
import 'package:workmanager/workmanager.dart';
import 'coin_value.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Used for Background Updates using Workmanager Plugin
void callbackDispatcher() {
  Workmanager.executeTask((taskName, inputData) async {
    final now = DateTime.now();


    final response = await Dio().get('https://api.bithumb.com/public/ticker/ALL_KRW');

    var coinValue = CoinValue.fromJson(response.data);


    return Future.wait<bool>([
      HomeWidget.saveWidgetData(
        'title',
        'BitCoin:KRW ${coinValue.data.btc.maxPrice}\n${coinValue.data.btc.unitsTraded}',
      ),
      HomeWidget.saveWidgetData(
        'message',
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
      ),
      HomeWidget.updateWidget(
        name: 'HomeWidgetExampleProvider',
        iOSName: 'HomeWidgetExample',
      ),
    ]).then((value) {
      return !value.contains(false);
    });
  });
}

/// Called when Doing Background Work initiated from Widget
void backgroundCallback(Uri data) async {
  print(data);

  if (data.host == 'titleclicked') {
    /*
    final greetings = [
      'Hello',
      'Hallo',
      'Bonjour',
      'Hola',
      'Ciao',
      '哈洛',
      '안녕하세요',
      'xin chào'
    ];
    final selectedGreeting = greetings[Random().nextInt(greetings.length)];
     */

    final now = DateTime.now();

    final response = await Dio().get('https://api.bithumb.com/public/ticker/ALL_KRW');

    var coinValue = CoinValue.fromJson(response.data);

    await HomeWidget.saveWidgetData<String>('title', 'BitCoin:KRW ${coinValue.data.btc.maxPrice}\n${coinValue.data.btc.unitsTraded}');
    await HomeWidget.saveWidgetData('message', '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',);
    await HomeWidget.updateWidget(
        name: 'HomeWidgetExampleProvider', iOSName: 'HomeWidgetExample');
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager.initialize(callbackDispatcher, isInDebugMode: kDebugMode);
  runApp(MaterialApp(home: MyApp(title: 'Coin',
    channel: IOWebSocketChannel.connect('wss://pubwss.bithumb.com/pub/ws'))));
}

class MyApp extends StatefulWidget {
  final String title;
  final WebSocketChannel channel;

  // ignore: public_member_api_docs
  MyApp({ Key key,  this.title,  this.channel})
      : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _controller = TextEditingController();

  var oldBTC = CoinWebSocket();
  var oldETH = CoinWebSocket();

  @override
  void initState() {
    super.initState();
    HomeWidget.setAppGroupId("group.teamhj.homeWidgetExample");
    HomeWidget.registerBackgroundCallback(backgroundCallback);
    _sendMessage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkForWidgetLaunch();
    HomeWidget.widgetClicked.listen(_launchedFromWidget);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {

    var ticker = {
      "type": "ticker",
      "symbols": ["BTC_KRW" , "ETH_KRW"],
      "tickTypes": ["30M"]
    };
    var orderbookdepth =
    {"type":"orderbookdepth", "symbols":["BTC_KRW" , "ETH_KRW"]};

    var tansactions =
    {"type":"transaction", "symbols":["BTC_KRW" , "ETH_KRW"]};

    var jsonString = json.encode(ticker);
    widget.channel.sink.add(jsonString);
    /*
    if (_controller.text.isNotEmpty) {
      widget.channel.sink.add(_controller.text);
    }

     */
  }

  Future<void> _sendData() async {
    try {
      return Future.wait([
        HomeWidget.saveWidgetData<String>('title', _titleController.text),
        HomeWidget.saveWidgetData<String>('message', _messageController.text),
      ]);
    } on PlatformException catch (exception) {
      debugPrint('Error Sending Data. $exception');
    }
  }

  Future<void> _updateWidget() async {
    try {
      return HomeWidget.updateWidget(
          name: 'HomeWidgetExampleProvider', iOSName: 'HomeWidgetExample');
    } on PlatformException catch (exception) {
      debugPrint('Error Updating Widget. $exception');
    }
  }

  Future<void> _loadData() async {
    try {
      return Future.wait([
        HomeWidget.getWidgetData<String>('title', defaultValue: 'Default Title')
            .then((value) => _titleController.text = value),
        HomeWidget.getWidgetData<String>('message',
                defaultValue: 'Default Message')
            .then((value) => _messageController.text = value),
      ]);
    } on PlatformException catch (exception) {
      debugPrint('Error Getting Data. $exception');
    }
  }

  Future<void> _sendAndUpdate() async {
    await _sendData();
    await _updateWidget();
  }

  void _checkForWidgetLaunch() {
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_launchedFromWidget);
  }

  void _launchedFromWidget(Uri uri) {
    if (uri != null) {
      showDialog(
          context: context,
          builder: (buildContext) => AlertDialog(
                title: Text('App started from HomeScreenWidget'),
                content: Text('Here is the URI: $uri'),
              ));
    }
  }

  void _startBackgroundUpdate() {
    Workmanager.registerPeriodicTask('1', 'widgetBackgroundUpdate',
        frequency: Duration(minutes: 15));
  }

  void _stopBackgroundUpdate() {
    Workmanager.cancelByUniqueName('1');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeWidget Example'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        tooltip: 'Send message',
        child: Icon(Icons.send),
      ),
      body: Center(
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Title',
              ),
              controller: _titleController,
            ),
            TextField(
              decoration: InputDecoration(
                hintText: 'Body',
              ),
              controller: _messageController,
            ),
            ElevatedButton(
              onPressed: _sendAndUpdate,
              child: Text('Send Data to Widget'),
            ),
            ElevatedButton(
              onPressed: _loadData,
              child: Text('Load Data'),
            ),
            ElevatedButton(
              onPressed: _checkForWidgetLaunch,
              child: Text('Check For Widget Launch'),
            ),
            if (Platform.isAndroid)
              ElevatedButton(
                onPressed: _startBackgroundUpdate,
                child: Text('Update in background'),
              ),
            if (Platform.isAndroid)
              ElevatedButton(
                onPressed: _stopBackgroundUpdate,
                child: Text('Stop updating in background'),
              ),
            Form(
              child: TextFormField(
                controller: _controller,
                decoration: InputDecoration(labelText: 'Send a message'),
              ),
            ),
            StreamBuilder(
              stream: widget.channel.stream,
              builder: (context, snapshot) {

                var cointicker = json.decode(snapshot.data);
                var cointicker1 = CoinWebSocket.fromJson(cointicker);

                if (cointicker1.content.symbol=="BTC_KRW") {
                  oldBTC = cointicker1;
                }
                if (cointicker1.content.symbol=="ETH_KRW") {
                  oldETH = cointicker1;
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child:
                  Column(
                    children: [

                      Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset('images/btc.png',width: 25, height: 25,),
                          Text(oldBTC.content.highPrice),
                          Text(oldBTC.content.lowPrice),
                          Text(oldBTC.content.chgRate+'%'),


                    ]),
                      SizedBox(height: 10,),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset('images/eth.png',width: 25, height: 25,),
                            Text(oldETH.content.highPrice),
                            Text(oldETH.content.lowPrice),
                            Text(oldETH.content.chgRate+'%'),


                          ]),
                  ]
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
