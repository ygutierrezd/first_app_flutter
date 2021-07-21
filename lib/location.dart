import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import "package:dart_amqp/dart_amqp.dart";
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class Location extends StatefulWidget {
  @override
  _Location createState() => _Location();
}

class _Location extends State<Location> {
  late Position _currentPosition;

  late MqttServerClient client;
  @override
  void initState() {
    super.initState();
    _connectMQTT().whenComplete(() {
      setState(() {});
    });
  }

  _connectMQTT() async {
    client = MqttServerClient.withPort('18.209.118.253', 'flutterApp', 1883);
    client.logging(on: true);

    final connMessage = MqttConnectMessage()
        .authenticateAs('admin', 'admin')
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    client.connectionMessage = connMessage;
    try {
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // if (_currentPosition != null)
        //   Text(
        //       "LAT: ${_currentPosition.latitude}, LNG: ${_currentPosition.longitude}"),
        FlatButton(
          child: Text("Get location"),
          onPressed: () async {
            // _getCurrentLocation();
            //_publicRabbitMQ();
            await _connect();
          },
        ),
        FlatButton(
          child: Text("Disconect"),
          onPressed: () async {
            _disconect();
          },
        ),
      ],
    )));
  }

  _getCurrentLocation() {
    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      print(e);
    });
  }

  _publicRabbitMQ() async {
    var message = '4.33345|-74.333567|354270091075664|78|1';
    ConnectionSettings settings = ConnectionSettings(
        host: "18.209.118.253",
        authProvider: PlainAuthenticator("admin", "admin"));
    Client client = Client(settings: settings);
    Channel channel = await client.channel();
    Queue queue = await channel.queue("hello");
    //Exchange exchange = await channel.exchange("logs", ExchangeType.FANOUT);
    // We dont care about the routing key as our exchange type is FANOUT
    //exchange.publish(message.toString(), null);
    queue.publish(message);
    client.close();
  }

  _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    _currentPosition = await Geolocator.getCurrentPosition();
  }

  _connect() async {
    //client.subscribe('topic/test', MqttQos.atMostOnce);
    final builder = MqttClientPayloadBuilder();
    builder.addString('4.33345|-74.333567|354270091075664|78|1');
    client.publishMessage('topic/test', MqttQos.atMostOnce, builder.payload!);
    //print('EXAMPLE::Sleeping....');
    //await MqttUtilities.asyncSleep(60);
    //client.unsubscribe('topic/test');
    //
  }

  _disconect() {
    client.disconnect();
  }
}
