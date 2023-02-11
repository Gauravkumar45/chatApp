import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chatapp/helper/helper_function.dart';
import 'package:firebase_chatapp/services/database_service.dart';
import 'package:flutter/material.dart';

class AuthService{
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  //login service
  Future loginUserWithEmailandPassword(String email, String password) async {
    try{
      User user = (await firebaseAuth.signInWithEmailAndPassword(email: email, password: password)).user!;
      if(user != null){
        return true;
      }
    }on FirebaseAuthException catch(e){
      return e.message;
    }
  }


  // register service
Future registerUserWithEmailandPassword(String fullname,String email, String password) async {
  try{
    User user = (await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password)).user!;


    if(user != null){
      DatabaseService(uid:user.uid).saveUserData(fullname, email);
      return true;
    }
  }on FirebaseAuthException catch(e){
    return e.message;
  }
}

//signout service

Future signOut() async{
  try{
    await HelperFunction.saveUserLoggedInStatus(false);
    await HelperFunction.saveUserEmailSF("");
    await HelperFunction.saveUserNameSF("");
    await firebaseAuth.signOut();
  }catch(e){
    return null;
  }
}
}