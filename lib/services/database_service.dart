import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService{
  final String? uid;
  DatabaseService({this.uid});

  //refrence for our collection
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection("users");
  final CollectionReference userCollection = FirebaseFirestore.instance.collection("user");

  //saveing a user data
    Future saveUserData(String fullname,String email)async{
    return await userCollection.doc(uid).set({
    "fullName":fullname,
    "email":email,
    "users":[],
    "profilePic":"",
    "uid":uid,
    });
  }

  //getting user data
    Future gettingUserData(String email)async{
          QuerySnapshot snapshot = await userCollection.where("email",isEqualTo: email).get();
          return snapshot;
    }

    //get user
    getUsers()async{
      return userCollection.doc(uid).snapshots();
    }

    //creatring a user
    Future createUser(String userName,String id) async{
      DocumentReference documentReference = await userCollection.add({
        "Username" : userName,
        "userIcon" : "",
        "admin" : "${id}_$userName",
        "members" : [],
        "userId" : "",
        "recentMessage": "",
        "recentMesageBySener" : "",
      });

      //update the user
      await documentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"]),
        "userId" : documentReference.id
      });

      DocumentReference userDocumentsRefrence = await userCollection.doc(uid);
      return await userDocumentsRefrence.update({
        "users":FieldValue.arrayUnion(["${documentReference.id}_$userName"])
      });
    }
}