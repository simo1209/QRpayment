import 'package:flutter/material.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'dart:convert';
import 'dart:io';

class Transactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transactions',
      home: TransactionsPage(title: 'Your Transactions'),
    );
  }
}

class TransactionsPage extends StatefulWidget {
  TransactionsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  State<StatefulWidget> createState() => _TransactionsState();
}

class _TransactionsState extends State<TransactionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
              child: Text('Recipient of the transaction:      **********')),
          Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
              child: Text('Information about the transaction: **********')),
          Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
              child: Text('Amount about the transaction:      **********')),
          ButtonBar(
            children: <Widget>[
              RaisedButton(
                child: const Text('Accept'),
                onPressed: () {
                  print("Accepted");
                },
              ),
              RaisedButton(
                onPressed: () {
                  print("Declined");
                },
                child: const Text('Decline'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scan,
        tooltip: 'Increment',
        child: Icon(Icons.camera),
      ),
    );
  }

  Future _scan() async {
    String data = await scanner.scan(); // Read the QR encoded string
    final client = HttpClient();
    final request =
        await client.postUrl(Uri.parse("http://192.168.0.101:5000/transfer"));
    request.headers.set(HttpHeaders.contentTypeHeader, "plain/text");
    request.write(data); // Write the QR encoded string as the post request body
    final response = await request.close();
    response.transform(utf8.decoder).listen((content) {
      print(content);
    });
  }
}
