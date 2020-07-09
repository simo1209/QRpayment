import 'package:flutter/material.dart';
import 'package:qr_payment/system.dart';
import 'package:qr_payment/transactions.dart';

import 'login.dart';

Future navigateToTransactionsList(context) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => Transactions()));
}

Future navigateToSystem(context) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => System()));
}

Future navigateToRegister(context) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => Register()));
}

Future navigateToCreateTransaction(context) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => CreateTransaction()));
}

Future navigateToTransactionCode(context, imgUrl) async {
  Navigator.push(context, MaterialPageRoute(builder: (context) => TransactionCode(imgUrl: imgUrl,)));
}