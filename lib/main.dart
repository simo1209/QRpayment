import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static const String _title = 'Login';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: MyStatefulWidget(),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Login",
              style: TextStyle(fontSize: 33),
            ),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: 'Enter your email',
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Enter your password',
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
                    onPressed: () => _login(),
                    child: Text('Sign In'),
                    color: Colors.lightBlue,
                    textColor: Colors.white,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 8.0),
                  child: RaisedButton(
                    onPressed: () {
                      navigateToRegister(context);
                    },
                    child: Text('Register'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future navigateToRegister(context) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Register()));
  }

  Future _login() async {
    if (_formKey.currentState.validate()) {
      String email = emailController.text;
      String password = passwordController.text;
      String basicAuth =
          'Basic ' + base64Encode(utf8.encode('$email:$password'));
      print(basicAuth);

      var r = await http.post('http://192.168.0.101:5000/auth/login',
          headers: <String, String>{'Authorization': basicAuth});
      print(r.statusCode);
      print(r.body);
    }
  }
}

class Register extends StatelessWidget {
  static const String _title = 'Register';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(_title)),
      body: RegisterPage(),
    );
  }
}

class RegisterPage extends StatefulWidget {
  RegisterPage({Key key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Register",
              style: TextStyle(fontSize: 33),
            ),
            TextFormField(
              controller: firstNameController,
              decoration: const InputDecoration(
                hintText: 'Enter your first name',
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            TextFormField(
              controller: lastNameController,
              decoration: const InputDecoration(
                hintText: 'Enter your last name',
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: 'Enter your email',
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Enter your password',
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            TextFormField(
              controller: phoneController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Enter your phone number',
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
                    onPressed: () => _register(),
                    child: Text('Sign Up'),
                    color: Colors.lightBlue,
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future _register() async {
    //TODO: Implement the registration request
  }
}
