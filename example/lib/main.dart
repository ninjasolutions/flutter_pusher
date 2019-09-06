import 'package:flutter/material.dart';
import 'package:flutter_pusher/flutter_pusher.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map _latestMessage;
  PusherError _lastError;
  PusherConnectionState _connectionState;
  FlutterPusher pusher = new FlutterPusher(FlutterPusherConfig(
      "PUSHER_APP_KEY",
      cluster: "PUSHER_APP_CLUSTER",
      authUrl: "AUTH_URL")); // Use auth url is required when you need to connect to private channels.

  @override
  initState() {
    super.initState();

    pusher.onConnectivityChanged.listen((state) {
      setState(() {
        _connectionState = state;
        if (state == PusherConnectionState.connected) {
          _lastError = null;
        }
      });
    });
    //pusher.onError.listen((err) => _lastError = err);
    _connectionState = PusherConnectionState.disconnected;
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
            title: new Text('Pusher example app.'),
          ),
          body: new Column(
            children: <Widget>[
              new Row(
                children: <Widget>[
                  new Text('Latest message ${_latestMessage.toString()}')
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
              buildConnectRow(context),
              buildErrorRow(context),
            ],
          )),
    );
  }

  Widget buildErrorRow(BuildContext context) {
    if (_lastError != null) {
      return new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[new Text("Error: ${_lastError.message}")],
      );
    } else {
      return new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[new Text("No Errors")],
      );
    }
  }

  Widget buildConnectRow(BuildContext context) {
    switch (_connectionState) {
      case PusherConnectionState.connected:
        return new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new MaterialButton(
                onPressed: disconnect, child: new Text("Disconnect"))
          ],
        );
      case PusherConnectionState.disconnected:
        return new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new MaterialButton(onPressed: connect, child: new Text("Connect"))
          ],
        );
      case PusherConnectionState.disconnecting:
        return new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[new Text("Disconnecting...")],
        );
      case PusherConnectionState.connecting:
        return new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[new Text("Connecting...")],
        );
      case PusherConnectionState.reconnectingWhenNetworkBecomesReachable:
        return new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text("Will reconnect when network becomes available")
          ],
        );
      case PusherConnectionState.reconnecting:
        return new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[new Text("Reconnecting...")],
        );
    }
    return new Text("Invalid state");
  }

  void connect() async {
    await pusher.connect();

    await pusher.subscribe("my-channel", "my-event");

    //await pusher.subscribePrivate("my-channel", "my-event");

    //await pusher.subscribePrivateAll("my-channel", ["test_event1", "test_event2"]);

    //await pusher.subscribeAll("test_channel", ["test_event3", "test_event4"]);

    pusher.onMessage.listen((pusher) {
      setState(() => _latestMessage = pusher.jsonBody);
    });
  }

  void disconnect() async {
    await pusher.unsubscribe("my-channel");
    await pusher.disconnect();
  }
}
