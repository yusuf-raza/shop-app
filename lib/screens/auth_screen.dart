import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

enum AuthMode { signup, login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              color: Colors.white
            ),
          ),
          SingleChildScrollView(
            child: SizedBox(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Image(
                    image: AssetImage("assets/images/shop-logo.png"),
                    fit: BoxFit.cover,
                  ),
                  Text(
                    "Shop App",
                    style: TextStyle(
                        fontSize: 40,
                        fontFamily: GoogleFonts.pacifico().fontFamily),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: const AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key? key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.login;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Error occurred'),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Okay'))
              ],
            ));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.login) {
        await Provider.of<AuthProvider>(context, listen: false).signIn(
            _authData['email'].toString(), _authData['password'].toString());
        //Navigator.pushNamed(context, ProductOverviewScreen.routeName);
      } else {
        await Provider.of<AuthProvider>(context, listen: false).signUp(
            _authData['email'].toString(), _authData['password'].toString());
      }
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed!';
      if (error.message.contains('EMAIL_EXISTS')) {
        errorMessage = 'email already exists!';
      } else if (error.message.contains('INVALID_EMAIL')) {
        errorMessage = 'invalid email!';
      } else if (error.message.contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'email does not exists!';
      } else if (error.message.contains('INVALID_PASSWORD')) {
        errorMessage = 'invalid password!';
      } else if (error.message.contains('WEAK_PASSWORD')) {
        errorMessage = 'weak password!';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      print('auth screen error: $error');
      var errorMessage = 'Could not authenticate you at the moment!';
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.login) {
      setState(() {
        _authMode = AuthMode.signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.login;
      });
    }

    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5,
      child: Container(
        height: deviceSize.height * .4,
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'E-Mail',
                      icon: Icon(Icons.email)
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                    //return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Password',
                      icon: Icon(Icons.password)
                  ),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['password'] = value!;
                  },
                ),
                if (_authMode == AuthMode.signup)
                  TextFormField(
                    enabled: _authMode == AuthMode.signup,
                    decoration: const InputDecoration(labelText: 'Confirm Password', icon: Icon(Icons.password)),
                    obscureText: true,
                    validator: _authMode == AuthMode.signup
                        ? (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match!';
                            }
                            return null;
                          }
                        : null,
                  ),
                const SizedBox(
                  height: 10,
                ),
                if (_isLoading)
                   JumpingDotsProgressIndicator(
                    fontSize: 40,
                  )
                else
                  ElevatedButton(
                    onPressed: _submit,
                   child:
                        Text(_authMode == AuthMode.login ? 'Login' : 'Signup'),
                  ),
                TextButton(
                  onPressed: _switchAuthMode,
                  child: Text(
                      '${_authMode == AuthMode.login ? 'Signup' : 'Login'} instead'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
