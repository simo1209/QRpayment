import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:qr_payment/session.dart';
import 'package:qr_payment/side-menu.dart';

class Account {

  final String firstName;
  final String lastName;
  final String email;
  final double balance;

  Account({this.firstName, this.lastName, this.email, this.balance});

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      balance: json['balance'],
    );
  }

  @override
  String toString() {
    return 'Account{firstName: $firstName, lastName: $lastName, email: $email, balance: $balance}';
  }
}

class Accounts extends StatelessWidget {
  static const String _title = 'Your Account';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        drawer: SideMenu(),
        body: AccountsPage(),
      ),
    );
  }
}

class AccountsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AccountsPageState();
}

class AccountsPageState extends State<AccountsPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getAccountInformation(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return createAccountWidget(context, snapshot.data);
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Future getAccountInformation() async {
    var response = await Session.get("/auth/user");
    return response;
  }

  Widget createAccountWidget(BuildContext context, Response data) {

    if(data.statusCode == 200){
      Account account = Account.fromJson(jsonDecode(data.body));
      return Column(
        children: <Widget>[
          ListTile(
            title: Text('${account.firstName} ${account.lastName}'),
          ),
          Divider(
            height: 2.0,
          ),
          ListTile(
            title: Text('Email: ${account.email}'),
          ),
          Divider(
            height: 2.0,
          ),
          ListTile(
            title: Text('Balance: ${account.balance.toString()}'),
          ),
          Divider(
            height: 2.0,
          ),
        ],
      );
    }
    return Text(data.body);

  }
}
