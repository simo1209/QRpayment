import 'package:flutter/material.dart';
import 'package:qr_payment/side-menu.dart';
import 'transactions.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class System extends StatelessWidget {
  static const String _title = 'System';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(
//            title: const Text(_title)
            ),
        drawer: SideMenu(),
        body: SystemPage(),
      ),
    );
  }
}

class SystemPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SystemPageState();
}

class SystemPageState extends State<SystemPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              children: <Widget>[
                IconButton(
                  iconSize: 216.0,
                  icon: Icon(Icons.camera),
                  tooltip: 'Scan',
                  onPressed: _scan,
                ),
                Text(
                  'Scan',
                  style: TextStyle(fontSize: 36),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                IconButton(
                  iconSize: 216.0,
                  icon: Icon(Icons.send),
                  tooltip: 'Scan',
                  onPressed: () {},
                ),
                Text(
                  'Create',
                  style: TextStyle(fontSize: 36),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future _scan() async {
    String data = await scanner.scan(); // Read the QR encoded string
    navigateToTransactionCheck(context, data);
  }

  Future navigateToTransactionCheck(context, data) async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CheckTransaction(
                  transactionData: data,
                )));
  }
}
