import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:network_connectivity_flutter/no_connection_widget.dart';
import 'package:network_connectivity_flutter/overlay_handler.dart';

void main() {
  runApp(const MyApp());
}

final OverlayHandler _overlayHandler = OverlayHandler();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// Connectivity Class object
  final Connectivity _connectivity = Connectivity();

  /// Stream object for listen connection state
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();

    /// initially check the connection state
    initConnectivity();

    /// listen connection state
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((event) {
      updateConnectionState(event);
    });
  }

  @override
  void dispose() {
    /// cancel connection subscription
    _connectivitySubscription.cancel();
    super.dispose();
  }

  /*
  * Initially check connection state of the device
  * */
  Future<void> initConnectivity() async {
    late ConnectivityResult _connectionResult;
    try {
      _connectionResult = await _connectivity.checkConnectivity();
    } catch (e) {
      debugPrint('--------------------');
      debugPrint('Network Error : ${e.toString()}');
      debugPrint('--------------------');
      return;
    }

    updateConnectionState(_connectionResult);
  }

  /*
  * Method that insert overlay widget when device is Offline
  * and remove overlay when device is Online....
  * */
  Future<void> updateConnectionState(ConnectivityResult result) async {
    if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
      /// connected
      _overlayHandler.removeOverlay(context);
    } else {
      /// disconnected
      _overlayHandler.insertOverlay(
        context,
        OverlayEntry(
          builder: (context) {
            return const NoConnection();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Connectivity Flutter'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SecondScreen()));
          },
          child: const Text('Next Screen'),
        ),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Go back'),
        ),
      ),
    );
  }
}
