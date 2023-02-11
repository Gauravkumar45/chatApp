import 'package:firebase_chatapp/helper/helper_function.dart';
import 'package:firebase_chatapp/services/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../home_page.dart';
import '../widgets/widget.dart';
import 'login_page.dart';

class ResgisterPage extends StatefulWidget {
  const ResgisterPage({Key? key}) : super(key: key);

  @override
  State<ResgisterPage> createState() => _ResgisterPageState();
}

class _ResgisterPageState extends State<ResgisterPage> {
  bool _isLoading = false;
  final formkey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  String fullname = "";
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register page'),
      ),
      body: _isLoading ? Center(child: CircularProgressIndicator(),) : SingleChildScrollView(
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
                  const Text('Create your account now to chat and explore',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w400),),
                  Image.asset("images/download.jpg"),
                  const SizedBox(height: 15,),
                  TextFormField(
                    obscureText: true,
                    decoration: textInputDecoration.copyWith(
                        labelText: "Full Name",
                        prefixIcon: Icon(Icons.person)
                    ),
                    onChanged: (val) {
                      setState(() {
                        fullname = val;
                      });
                    },
                    validator: (val) {
                      if (val!.isNotEmpty) {
                        return null;
                      } else {
                        return "Name cannot be empty";
                      }
                    },
                  ),
                  const SizedBox(height: 15,),
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
                          register();
                        },
                        child: const Text("Register",style: TextStyle(fontSize: 18),)),
                  ),
                  const SizedBox(height: 10,),
                  Text.rich(
                      TextSpan(
                        text: "Already have an account?",
                        style: const TextStyle(color: Colors.black,fontSize: 14),
                        children: <TextSpan>[
                          TextSpan(
                              text: "LogIn now",
                              style: const TextStyle(color: Colors.black,decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()..onTap = (){
                                nextScreen(context, const LoginPage());
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

  register() async {
    if (formkey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService.registerUserWithEmailandPassword(fullname, email, password).then((value) async {
        if(value == true){
          //saving the set prefrence state
        await HelperFunction.saveUserLoggedInStatus(true);
        await HelperFunction.saveUserNameSF(fullname);
        await HelperFunction.saveUserEmailSF(email);
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
