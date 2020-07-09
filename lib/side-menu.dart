import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'navigations.dart';

class SideMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text("Simeon Goergiev"),
            accountEmail: Text("sgeorgiev@mail.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme
                  .of(context)
                  .platform == TargetPlatform.iOS
                  ? Colors.blue
                  : Colors.white,
              child: Text(
                "S",
                style: TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          ListTile(
            title: Text("Main Menu"),
            trailing: Icon(Icons.arrow_forward),
            onTap: (){
              navigateToSystem(context);
            },
          ),
          ListTile(
            title: Text("History"),
            trailing: Icon(Icons.arrow_forward),
            onTap: (){
              navigateToTransactionsList(context);
            },
          ),
          ListTile(
            title: Text("Account"),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {},
          ),
        ],
      ),
    );
  }

}