import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pusher/pusher.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Event lastEvent;
  String lastConnectionState;
  Channel channel;

  var channelController = TextEditingController(text: "my-channel");
  var eventController = TextEditingController(text: "my-event");
  var triggerController = TextEditingController(text: "client-trigger");

  @override
  void initState() {
    super.initState();
    initPusher();
  }

  Future<void> initPusher() async {
    try {
      await Pusher.init(
          "APP_KEY",
          PusherOptions(
            cluster: "eu",
          ),
          enableLogging: true);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text('Plugin example app'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildInfo(),
                RaisedButton(
                  child: Text("Connect"),
                  onPressed: () {
                    Pusher.connect(onConnectionStateChange: (x) async {
                      if (mounted)
                        setState(() {
                          lastConnectionState = x.currentState;
                        });
                    }, onError: (x) {
                      debugPrint("Error: ${x.message}");
                    });
                  },
                ),
                RaisedButton(
                  child: Text("Disconnect"),
                  onPressed: () {
                    Pusher.disconnect();
                  },
                ),
                Row(
                  children: <Widget>[
                    Container(
                      width: 200,
                      child: TextField(
                        autocorrect: false,
                        controller: channelController,
                        decoration: InputDecoration(hintText: "Channel"),
                      ),
                    ),
                    RaisedButton(
                      child: Text("Subscribe"),
                      onPressed: () async {
                        channel =
                            await Pusher.subscribe(channelController.text);
                      },
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Container(
                      width: 200,
                      child: TextField(
                        controller: channelController,
                        decoration: InputDecoration(hintText: "Channel"),
                      ),
                    ),
                    RaisedButton(
                      child: Text("Unsubscribe"),
                      onPressed: () async {
                        await Pusher.unsubscribe(channelController.text);
                        channel = null;
                      },
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Container(
                      width: 200,
                      child: TextField(
                        controller: eventController,
                        decoration: InputDecoration(hintText: "Event"),
                      ),
                    ),
                    RaisedButton(
                      child: Text("Bind"),
                      onPressed: () async {
                        await channel.bind(eventController.text, (x) {
                          if (mounted)
                            setState(() {
                              lastEvent = x;
                            });
                        });
                      },
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Container(
                      width: 200,
                      child: TextField(
                        controller: eventController,
                        decoration: InputDecoration(hintText: "Event"),
                      ),
                    ),
                    RaisedButton(
                      child: Text("Unbind"),
                      onPressed: () async {
                        await channel.unbind(eventController.text);
                      },
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Container(
                      width: 200,
                      child: TextField(
                        controller: triggerController,
                        decoration: InputDecoration(hintText: "Trigger"),
                      ),
                    ),
                    RaisedButton(
                      child: Text("Trigger"),
                      onPressed: () async {
                        await channel.trigger(triggerController.text,
                            data: '{"testValue": 123, "anotherOne": false, "nested": {"w0t": "m8"}}');
                      },
                    )
                  ],
                ),
              ],
            ),
          )),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Connection State: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(lastConnectionState ?? "Unknown"),
          ],
        ),
        SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Last Event Channel: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(lastEvent?.channel ?? ""),
          ],
        ),
        SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Last Event Name: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(lastEvent?.event ?? ""),
          ],
        ),
        SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Last Event Data: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(lastEvent?.data ?? ""),
          ],
        ),
      ],
    );
  }
}
