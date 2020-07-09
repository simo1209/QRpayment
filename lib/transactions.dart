import 'package:flutter/material.dart';
import 'package:qr_payment/login.dart';
import 'package:qr_payment/session.dart';
import 'package:qr_payment/side-menu.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'dart:async';

import 'package:qr_payment/system.dart';

import 'navigations.dart';

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
      drawer: SideMenu(),
      body: FutureBuilder(
        future: listTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            return createTransactionsWidget(snapshot.data);
          } else if (snapshot.hasError) {
            print("eror");
            return errorWidget(snapshot.error);
          } else {
            return CircularProgressIndicator();
          }
        },
      ),

    );
  }



  Future<http.Response> listTransactions() async {
    var response =
        await Session.get('/transactions/list');
    return response;
  }



  Widget createTransactionsWidget(response) {
    print(response);
    var parsedTransactions = jsonDecode(response.body);
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
            return createCheckingWidget(context, snapshot.data);
          } else if (snapshot.hasError){
            return Text(snapshot.error.toString());
        } else{
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Future checkTransaction() async {
    Session.headers["Content-Type"] = "application/json";
    var response = await Session.post(
        "/transactions/check",
        jsonEncode(<String, String>{'data': transactionData}));
    return response;
  }

  Widget createCheckingWidget(context, response) {

    if(response.statusCode == 200) {
      Transaction transaction = Transaction.fromJson(jsonDecode(response.body));
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
                    acceptTransaction(context, transaction.id);
                  },
                )
              ],
            )
          ],
        ),
      );
    }
    return Text(response.body);

  }

  void acceptTransaction(context, id) async {
    var response = await Session.post(
        "/transactions/accept",
        jsonEncode(<String, String>{'id': id.toString()}));
    if (response.statusCode == 201) {
      navigateToSystem(context);
    }
  }
}

class CreateTransaction extends StatelessWidget {
  static const String _title = 'Create Transaction';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(_title)),
      body: CreateTransactionPage(),
    );
  }
}

class CreateTransactionPage extends StatefulWidget {
  CreateTransactionPage({Key key}) : super(key: key);

  @override
  _CreateTransactionPageState createState() => _CreateTransactionPageState();
}

class _CreateTransactionPageState extends State<CreateTransactionPage> {
  final _formKey = GlobalKey<FormState>();

  final transactionDescription = TextEditingController();
  final transactionAmount = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Create Transaction",
                style: TextStyle(fontSize: 33),
              ),
              TextFormField(
                controller: transactionDescription,
                decoration: const InputDecoration(
                  hintText: 'Enter your transaction\'s description',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: transactionAmount,
                decoration: const InputDecoration(
                  hintText: 'Enter your transaction\'s amount',
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 8.0),
                    child: RaisedButton(
                      onPressed: () => _createTransaction(context),
                      child: Text('Create'),
                      color: Colors.lightBlue,
                      textColor: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 8.0),
                    child: RaisedButton(
                      onPressed: () => navigateToSystem(context),
                      child: Text('Cancel'),
                    ),
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _createTransaction(context) async {
    if (_formKey.currentState.validate()) {

      Session.headers ['Content-Type']='application/json; charset=UTF-8';
      var response = await Session.post(
        '/transactions/create',
        jsonEncode(<String, String>{
          'transaction_desc': transactionDescription.text,
          'amount': transactionAmount.text,
        }),
      );
      Session.headers.remove('Content-Type');
      if (response.statusCode == 201) {
        String imgUrl = response.body;
        navigateToTransactionCode(context,imgUrl);
      } else {
        print(response.body);
      }
    }
  }
}

class TransactionCode extends StatelessWidget {

  final String imgUrl;

  const TransactionCode({Key key, this.imgUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Your QR code:'),
        ),
        body: Center(
          child: Image.network(
            '${Session.host}$imgUrl',
            headers: Session.headers,
          ),
        ),
      ),
    );
  }
}


