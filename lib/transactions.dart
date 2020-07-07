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
  final String sellerName;
  final double amount;

  Transaction({this.id, this.transactionDesc, this.amount, this.sellerName});

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      transactionDesc: json['transaction_desc'],
      sellerName: json['seller_name'],
      amount: json['amount'],
    );
  }

  @override
  String toString() {
    return 'Transaction{id: $id, transactionDesc: $transactionDesc, sellerName: $sellerName, amount: $amount}';
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
    navigateToTransactionCheck(context, data);
  }

  Future<http.Response> listTransactions() async {
    var response =
        await Session.get('http://192.168.0.101:5000/transactions/list');
    return response;
  }

  Future navigateToTransactionCheck(context, data) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CheckTransaction(
                  transactionData: data,
                )));
  }

  Widget createTransactionsWidget(data) {
    var parsedTransactions = jsonDecode(data.body);
    var transactions = List<Transaction>();
    parsedTransactions.forEach((parsedTransaction) {
      transactions.add(Transaction.fromJson(parsedTransaction));
    });

    return ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
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

class CheckTransaction extends StatelessWidget {
  final String transactionData;

  const CheckTransaction({Key key, this.transactionData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Check Transaction")),
      body: FutureBuilder(
        future: checkTransaction(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return createCheckingWidget(snapshot.data);
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Future checkTransaction() async {
    Session.headers["Content-Type"] = "application/json";
    var response = await Session.post(
        "http://192.168.0.101:5000/transactions/check",
        jsonEncode(<String, String>{'data': transactionData}));
    return response;
  }

  Widget createCheckingWidget(data) {
    Transaction transaction = Transaction.fromJson(jsonDecode(data.body));
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text('Selelr Name'),
              Text('Description'),
              Text('Amount')
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(transaction.sellerName),
              Text(transaction.transactionDesc),
              Text(transaction.amount.toString())
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text("Accept"),
                color: Colors.lightBlue,
                textColor: Colors.white,
                onPressed: () {
                  print("Accepted");
                },
              )
            ],
          )
        ],
      ),
    );
  }
}
