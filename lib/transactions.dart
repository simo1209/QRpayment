import 'package:flutter/material.dart';
import 'package:qr_payment/session.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'dart:async';

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

class Transaction {
  final int id;
  final String transactionDesc;

  Transaction({this.id, this.transactionDesc});

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      transactionDesc: json['transaction_desc'],
    );
  }
}

class _TransactionsState extends State<TransactionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: listTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return createTransactionsWidget(snapshot.data);
          } else if (snapshot.hasError) {
            print("eror");
            return errorWidget(snapshot.error);
          } else {
            return CircularProgressIndicator();
          }
        },
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

  Future<http.Response> listTransactions() async {
    var response =
        await Session.get('http://192.168.0.101:5000/transactions/list');
    return response;
  }

  Widget createTransactionsWidget(data) {
    var parsedTransactions = jsonDecode(data.body);
    var transactions = List<Transaction>();
    parsedTransactions.forEach((parsedTransaction) {
      transactions.add(Transaction.fromJson(parsedTransaction));
    });

    return ListView.builder(
        itemCount: transactions.length, itemBuilder: (context, index) {
          return Column(
            children: <Widget>[
              ListTile(
                title: Text(transactions[index].transactionDesc),
              ),
              Divider(
                height: 2.0,
              )
            ],
          );
    });
  }

  Widget errorWidget(Object error) {
    return new Text(error.toString());
  }
}
