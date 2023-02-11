import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chatapp/auth/login_page.dart';
import 'package:firebase_chatapp/helper/helper_function.dart';
import 'package:firebase_chatapp/profile_page.dart';
import 'package:firebase_chatapp/search_page.dart';
import 'package:firebase_chatapp/services/auth_service.dart';
import 'package:firebase_chatapp/services/database_service.dart';
import 'package:firebase_chatapp/user_tile.dart';
import 'package:firebase_chatapp/widgets/widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthService authService = AuthService();
  String userName = "";
  String email = "";
  Stream? users;
  bool _isLoading = false;
  String UserTitleName = "";

  @override
  void initState() {
    super.initState();
    gettingUserData();
  }
  
  //string manupulation
  String getId(String res){
    return res.substring(0,res.indexOf("_"));
  }
  String getName(String res){
    return res.substring(0,res.indexOf("_")+1);
  }
  
  gettingUserData() async{
    await HelperFunction.getUserEmailFromSF().then((value) {
      setState(() {
        email = value!;
      });
    });
    await HelperFunction.getUserNameFromSF().then((value) {
      setState(() {
        userName = value!;
      });
    });

    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).getUsers().then((snapshot){
      setState(() {
        users = snapshot;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: (){
                nextScreen(context, const Searchpage());
              }, icon: const Icon(Icons.search))
        ],
        elevation: 0,
        centerTitle: true,
        title: const Text("Let's Chat",style: TextStyle(fontSize: 27,fontWeight: FontWeight.bold),),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: <Widget>[
            const Icon(Icons.account_circle,
            size: 150,
            color: Colors.blueGrey,
            ),
            const SizedBox(
              height: 15,
            ),
            Text(userName, textAlign: TextAlign.center,style: const TextStyle(fontWeight: FontWeight.bold),),
            const SizedBox(height: 30,),
            const Divider(height: 2,),
            ListTile(onTap: (){},
              selected: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
              leading: const Icon(Icons.home),
              title: const Text('Home',style: TextStyle(color: Colors.black),),
            ),
            ListTile(onTap: (){
              nextScreenReplace(context, ProfilePage(email: email, username: userName,));
            },
              selected: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
              leading: const Icon(Icons.person),
              title: const Text('Profile',style: TextStyle(color: Colors.black),),
            ),
            ListTile(onTap: () async {
              showDialog(
                barrierDismissible: false,
                  context: context,
                  builder: (context){
                return AlertDialog(
                  title: const Text("Logout"),
                  content: const Text('Are you sure you want to logout ?'),
                  actions: [
                    IconButton(onPressed: (){
                      Navigator.pop(context);
                    }, icon: const Icon(Icons.cancel,color: Colors.red,)),
                    IconButton(onPressed: ()async {
                      await authService.signOut();
                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginPage()), (route) => false);
                    }, icon: const Icon(Icons.done,color: Colors.green,)),
                  ],
                );
              });
            },
              selected: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Logout',style: TextStyle(color: Colors.black),),
            ),

          ],
        ),
      ),
      body: userList(),
      floatingActionButton: FloatingActionButton(onPressed: (){
        popUpDialog(context);
      },
        elevation: 0,
        child: const Icon(Icons.add,color: Colors.white,size: 30,),
      ),
    );
  }

  popUpDialog(BuildContext context){
    showDialog(
      barrierDismissible: false,
        context: context,
        builder: (context){
      return StatefulBuilder(
        builder: ((context,setState){
        return AlertDialog(
          title: const Text("Create a user",textAlign: TextAlign.left,),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            _isLoading == true ? Center(child: CircularProgressIndicator()) :
            TextField(
              onChanged: (val){
                setState(() {
                  UserTitleName = val;
                });
              },
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.red)
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: Colors.green)
                )
              ),
            ),
          ],),
          actions: [
            ElevatedButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: const Text("CANCEL"),
            ),
            ElevatedButton(
              onPressed: ()async {
                if(userName!=""){
                  setState(() {
                    _isLoading =true;
                  });
                  DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).createUser(userName, FirebaseAuth.instance.currentUser!.uid).whenComplete(() {
                    _isLoading = false;
                  });
                  Navigator.of(context).pop();
                  showSnackBar(context,Colors.green ,"User created successfully");
                }
              },
              child: const Text("CREATE"),
            ),
          ],
        );
        })
      );
    });
  }

  userList(){
  //   return StreamBuilder(
  //     stream: users,
  //       builder: (context,AsyncSnapshot snapshot){
  //       if(snapshot.hasData){
  //         if(snapshot.data['users']!= null){
  //           if(snapshot.data['users'] != 0){
  //               return ListView.builder(
  //                 itemCount: snapshot.data['users'],
  //                   itemBuilder: (context,index){
  //                     return UserTile(userId:getId(snapshot.data['users'][index]),userName: getName(snapshot.data['users'][index]));
  //                   });
  //           }else{
  //             return noUsersWidget();
  //           }
  //         }else{
  //           return noUsersWidget();
  //         }
  //       }else{
  //         return Center(child: CircularProgressIndicator(),);
  //       }
  //
  //       });
  }

  noUsersWidget(){
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: (){
                popUpDialog(context);
              },
            ),
            Icon(Icons.add_circle,color: Colors.grey[700],size: 75,),
            const SizedBox(height: 20,),
            const Text("There's no any users, Tap on the add icon to create a user or also search button.",
            textAlign: TextAlign.center,)
          ],
        ),
      ),
    );
  }
}