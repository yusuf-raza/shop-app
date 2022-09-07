import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  String? _token ;
  String? _userId;
  DateTime? _expiryDate;


  String? get userId{
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlType) async {
    var url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlType?key=AIzaSyDZI6v2Z-be_htk40JUa68Cs9gFM-bFPhQ");

    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      final responseData = json.decode(response.body);

      print(response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      //setting the _token as the tokenId received from firebase
      _token = responseData['idToken'];
      //setting the _userId as the user id received from firebase
      _userId = responseData['localId'];
      //setting up token expiry time by adding the expiresIn response from firebase into current time stamp
      _expiryDate = DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn'])));
      notifyListeners();

     // print('token: $_token');
     // print('user id: $_userId');
     // print('expiry date: $_expiryDate');
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> signIn(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  void logOut(){
    _token = null;
    _userId = null;
    _expiryDate = null;

    notifyListeners();
  }

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate?.isAfter(DateTime.now()) ?? false) {
      return _token;
    }
    return null;
  }
}
