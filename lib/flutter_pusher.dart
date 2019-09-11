import 'dart:async';

import 'package:flutter/services.dart';

enum PusherConnectionState {
  connecting,
  connected,
  disconnecting,
  disconnected,
  reconnecting,
  reconnectingWhenNetworkBecomesReachable
}

class FlutterPusherConfig {
  FlutterPusherConfig(this.apiKey, {this.cluster, this.authUrl});

  final String apiKey;
  final String cluster;
  final String authUrl;

  Map<String, dynamic> toMap() {
    Map<String, dynamic> args = {
      'apiKey': apiKey,
    };

    if (cluster != null) {
      args['cluster'] = cluster;
    }

    if (authUrl != null) {
      args['authUrl'] = authUrl;
    }

    return args;
  }
}

class FlutterPusher {
  final MethodChannel _channel;
  final EventChannel _connectivityEventChannel;
  final EventChannel _messageChannel;
  final EventChannel _errorChannel;

  /// Creates a [FlutterPusher] with the specified [apiKey] from pusher.
  ///
  /// The [apiKey] may not be null.
  FlutterPusher(FlutterPusherConfig config)
      : _channel = new MethodChannel('plugins.indoor.solutions/pusher'),
        _messageChannel =
            new EventChannel('plugins.indoor.solutions/pusher_message'),
        _errorChannel = EventChannel('plugins.indoor.solutions/pusher_error'),
        _connectivityEventChannel =
            EventChannel('plugins.indoor.solutions/pusher_connection') {
    _channel.invokeMethod('create', config.toMap());
  }

  /// Connect to the pusher service.
  Future<void> connect() => _channel.invokeMethod('connect');

  /// Disconnect from the pusher service
  Future<void> disconnect() => _channel.invokeMethod('disconnect');

  /// Subscribe to a channel with the name [channelName] for the event [event]
  ///
  /// Calling this method will cause any messages matching the [event] and [channelName]
  /// provided to be delivered to the [onMessage] method. After calling this you
  /// must listen to the [Stream] returned from [onMessage].
  Future<void> subscribe(String channelName, String event) => _channel
      .invokeMethod('subscribe', {"channel": channelName, "event": event});

  /// Subscribe to the channel [channelName] for each [eventName] in [events]
  ///
  /// This method is just for convenience if you need to register multiple events
  /// for the same channel.
  Future<void> subscribeAll(String channelName, List<String> events) async {
    await Future.wait(events.map((e) => subscribe(channelName, e)));
  }

  /// Subscribe to a private channel with the name [channelName] for the event [event]
  ///
  /// Calling this method will cause any messages matching the [event] and [channelName]
  /// provided to be delivered to the [onMessage] method. After calling this you
  /// must listen to the [Stream] returned from [onMessage].
  Future<void> subscribePrivate(String channelName, String event) =>
      _channel.invokeMethod(
          'subscribePrivate', {"channel": channelName, "event": event});

  /// Subscribe to the private channel [channelName] for each [eventName] in [events]
  ///
  /// This method is just for convenience if you need to register multiple events
  /// for the same channel.
  Future<void> subscribePrivateAll(
      String channelName, List<String> events) async {
    await Future.wait(events.map((e) => subscribePrivate(channelName, e)));
  }

  /// Unsubscribe from a channel with the name [channelName]
  ///
  /// This will un-subscribe you from all events on that channel.
  Future<void> unsubscribe(String channelName) =>
      _channel.invokeMethod('unsubscribe', channelName);

  /// Trigger [event] (will be prefixed with "client-" in case you have not) for [channelName].
  ///
  /// Client events can only be triggered on private and presence channels because they require authentication
  /// You can only trigger a client event once a subscription has been successfully registered with Channels.
  Future<void> trigger(String channelName, String event, {String data}) =>
      _channel.invokeMethod('triggerPrivate',
          {"channel": channelName, "event": event, "data": data ?? null});

  /// Get the [Stream] of [PusherMessage] for the channels and events you've
  /// signed up for.
  ///
  Stream<PusherMessage> get onMessage =>
      _messageChannel.receiveBroadcastStream().map(_toPusherMessage);

  Stream<PusherError> get onError =>
      _errorChannel.receiveBroadcastStream().map(_toPusherError);

  /// Get a [Stream] of [PusherConnectionState] events.
  /// Use this method to get notified about connection-related information.
  ///
  Stream<PusherConnectionState> get onConnectivityChanged =>
      _connectivityEventChannel
          .receiveBroadcastStream()
          .map(_connectivityStringToState);

  PusherConnectionState _connectivityStringToState(dynamic string) {
    switch (string) {
      case 'connecting':
        return PusherConnectionState.connecting;
      case 'connected':
        return PusherConnectionState.connected;
      case 'disconnected':
        return PusherConnectionState.disconnected;
      case 'disconnecting':
        return PusherConnectionState.disconnecting;
      case 'reconnecting':
        return PusherConnectionState.reconnecting;
      case 'reconnectingWhenNetworkBecomesReachable':
        return PusherConnectionState.reconnectingWhenNetworkBecomesReachable;
    }
    return PusherConnectionState.disconnected;
  }

  PusherMessage _toPusherMessage(dynamic map) {
    if (map is Map) {
      return PusherMessage(map['channel'], map['event'], map['body']);
    }
    return null;
  }

  PusherError _toPusherError(dynamic map) {
    return PusherError(map['code'], map['message']);
  }
}

class PusherMessage {
  final String channelName;
  final String eventName;
  final dynamic
      jsonBody; // This body can be either JSON object or a list of JSON objects

  PusherMessage(this.channelName, this.eventName, this.jsonBody);
}

class PusherError {
  final int code;
  final String message;

  PusherError(this.code, this.message);

  toString() => "$code,$message";
}
