import 'package:flutter/material.dart';

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
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text("Simeon Goergiev"),
                accountEmail: Text("sgeorgiev@mail.com"),
                currentAccountPicture: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).platform == TargetPlatform.iOS
                          ? Colors.blue
                          : Colors.white,
                  child: Text(
                    "S",
                    style: TextStyle(fontSize: 40.0),
                  ),
                ),
              ),
              ListTile(
                title: Text("History"),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {},
              ),
              ListTile(
                title: Text("Account"),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {},
              ),
            ],
          ),
        ),
        body: Scaffold(
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
                      onPressed: () {},
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
        ),
      ),
    );
  }
}
