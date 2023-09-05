import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Get battery level.
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        brightness: Brightness.dark,
        colorScheme: const ColorScheme(
            brightness: Brightness.dark,
            inversePrimary:Color.fromARGB(255, 18, 18, 18),
            primary:Color(0xffbb86fc),
            onPrimary : Colors.black,
            secondary : Color(0xff03dac6),
            onSecondary : Colors.black,
            error : Color(0xffcf6679),
            onError : Colors.black,
            background : Color(0xff121212),
            onBackground : Colors.white,
            surface : Color(0xff121212),
            onSurface:  Colors.white,
            secondaryContainer:Color.fromARGB(255, 47, 47, 47),
        ),
        textTheme: TextTheme(),
        primaryColor: Colors.black87,
        shadowColor: Colors.black12,
        listTileTheme: ListTileThemeData(),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  static const platform = MethodChannel('com.yessvpn.flutter/channel');

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.

      connect();
      _counter++;
    });
  }

  Future<void> connect() async {
    String batteryLevel;
    try {
      final int result = await platform.invokeMethod('Connect',
          "\"${"{\"log\": {}, \"dns\": {}, \"router\": {}, \"inbounds\": [{\"port\": 1080, \"protocol\": \"socks\", \"sniffing\": {\"enabled\": true, \"destOverride\": [\"http\", \"tls\"]}, \"settings\": {\"auth\": \"noauth\"}}], \"outbounds\": [{\"protocol\": \"shadowsocks\", \"settings\": {\"servers\": [{\"address\": \"64.176.52.98\", \"method\": \"aes-256-gcm\", \"ota\": true, \"password\": \"ChinaNumber_1\", \"port\": 10086}]}}], \"services\": {}}".replaceAll("\"", "\\\"")}\"");
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }
  }

  Future<void> setApplicationPath() async {
    String batteryLevel;
    try {
      final int result = await platform.invokeMethod(
          "ApplicationPath", Platform.resolvedExecutable);
    } on PlatformException catch (e) {
      log("Failed to get battery level: '${e.message}'.");
    }
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
      // appBar: AppBar(
      //   // TRY THIS: Try changing the color here to a specific color (to
      //   // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
      //   // change color while the other colors stay the same.
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   // Here we take the value from the MyHomePage object that was created by
      //   // the App.build method, and use it to set our appbar title.
      //   title: Text(widget.title),
      // ),
      body: ListView(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        children: [
          Container(
            width: double.infinity,
            height: 60,
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  'images/flag/cn.svg',
                  width: 50,
                  height: 30,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 3,left: 10),
                    child: const Text(
                      '中国-香港',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: const Text(
                    "200ms",
                  ),
                )
              ],
            ),
          ),
          Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            //
            // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
            // action in the IDE, or press "p" in the console), to see the
            // wireframe for each widget.
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
