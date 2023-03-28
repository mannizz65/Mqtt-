import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MQTT Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'MQTT Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MqttServerClient _client = MqttServerClient.withPort(
      'live-data.haltian.com', 'jskjfslkdjsdlkjsdlj', 1883);
  bool _connected = false;
  String _data = '';

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    try {
      await _client.connect();
      setState(() {
        _connected = true;
      });
      _client.subscribe('cloudext/json/pr/fi/office/TSAR01EWI02500568/#', MqttQos.atMostOnce);
      _client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        print(DateTime.now());
        final MqttMessage message = c[0].payload;
        if (message is MqttPublishMessage) {
          final payload =
          MqttPublishPayload.bytesToStringAsString(message.payload.message);

          // Here you can process the received data
          print('Received message: $payload');
          setState(() {
            _data=payload;
          });
        }
      });
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Connection status:',
            ),
            Text(
              _connected ? 'Connected' : 'Not connected',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 16),
            Text(
              'Received data:',
            ),
            Text(
              _data,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}