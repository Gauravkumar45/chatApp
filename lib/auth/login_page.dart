import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chatapp/auth/register_page.dart';
import 'package:firebase_chatapp/services/auth_service.dart';
import 'package:firebase_chatapp/services/database_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../helper/helper_function.dart';
import '../home_page.dart';
import '../widgets/widget.dart';

class LoginPage extends StatefulWidget{
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formkey = GlobalKey<FormState>();
  bool _isLoading = false;
  AuthService authService = AuthService();
  String email = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LogIn page'),
      ),
      body: _isLoading? Center(child: CircularProgressIndicator(),) : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
          child: Form(
              key: formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Text("Let's chat", style: TextStyle(
                      fontSize: 40, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 10,),
                  const Text('Login now to see what user are talking!',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w400),),
                  Image.asset("images/download.png"),
                  TextFormField(
                    decoration: textInputDecoration.copyWith(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email)
                    ),
                    onChanged: (val) {
                      setState(() {
                        email = val;
                      });
                    },
                    validator: (val) {
                      return RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]").hasMatch(val!)
                          ? null
                          : "Please enter a valid email";
                    },
                  ),
                  const SizedBox(height: 15,),
                  TextFormField(
                    obscureText: true,
                    decoration: textInputDecoration.copyWith(
                        labelText: "Password",
                        prefixIcon: Icon(Icons.lock)
                    ),
                    onChanged: (val) {
                      setState(() {
                        password = val;
                      });
                    },
                    validator: (val) {
                      if (val!.length < 6) {
                        return "Password must be at least 6 characters";
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 10,),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)
                            )
                        ),
                        onPressed: () {
                          login();
                        },
                        child: const Text("Sign In",style: TextStyle(fontSize: 18),)),
                  ),
                  const SizedBox(height: 10,),
                  Text.rich(
                    TextSpan(
                      text: "Don't have an account?",
                      style: const TextStyle(color: Colors.black,fontSize: 14),
                      children: <TextSpan>[
                        TextSpan(
                          text: "Register here",
                          style: const TextStyle(color: Colors.black,decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()..onTap = (){
                            nextScreen(context, const ResgisterPage());
                          }),
                      ],
                    )
                  )
                ],
              )),
        ),
      ),
    );
  }

  login() async {
    if (formkey.currentState!.validate()){
      setState(() {
        _isLoading = true;
      });
      await authService.loginUserWithEmailandPassword( email, password).then((value) async {
        if(value == true){
          QuerySnapshot snapshot = await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).gettingUserData(email);

          //saving the values to our share prefrences
          await HelperFunction.saveUserLoggedInStatus(true);
          await HelperFunction.saveUserEmailSF(email);
          await HelperFunction.saveUserNameSF(snapshot.docs[0]['fullName']);


          nextScreenReplace(context, const HomePage(title: '',));
        }else{
          showSnackBar(context,Colors.red,value);
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
}
