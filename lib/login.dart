import 'package:flutter/material.dart';
import 'package:qr_payment/system.dart';
import 'package:qr_payment/session.dart';
import 'dart:convert';
import 'package:qr_payment/transactions.dart';

import 'navigations.dart';


void main() => runApp(Login());

class Login extends StatelessWidget {
  static const String _title = 'Login';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: LoginPage(),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
              keyboardType: TextInputType.emailAddress,
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
                    onPressed: () => _login(context),
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



  Future _login(context) async {
    if (_formKey.currentState.validate()) {
      String email = emailController.text;
      String password = passwordController.text;

      var response = await Session.login(email, password);

      if(response.statusCode == 200){
        navigateToSystem(context);
      }
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                keyboardType: TextInputType.emailAddress,
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
                      onPressed: () => _register(context),
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
      ),
    );
  }

  Future _register(context) async {
    if (_formKey.currentState.validate()) {
      String email = emailController.text;
      String password = passwordController.text;
      String fName = firstNameController.text;
      String lName = lastNameController.text;
      String phone = phoneController.text;

      Session.headers = {
        'Content-Type': 'application/json; charset=UTF-8',
      };
      var response = await Session.post(
        '/auth/register',
        jsonEncode(<String, String>{
          'email': email,
          'password': password,
          'first_name': fName,
          'last_name': lName,
          'phone': phone,
        }),
      );

      if (response.statusCode == 201) {
        navigateToSystem(context);
      } else {
        throw Exception('Failed to create album.');
      }
    }
  }
}