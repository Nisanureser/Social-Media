import 'package:cloud_firestore/cloud_firestore.dart';

class User{

  final String email;
  final String username;
  final String bio;
  final String profilePhoto;
  final DateTime createDate;
  final String uid;


  User({
    required this.email,
    required this.username,
    required this.bio,
    required this.profilePhoto,
    required this.createDate,
    required this.uid,
  });

  Map<String,dynamic> toJson() =>  // user i json a cevirdik
      {
        "email": email,
        "username": username,
        "bio": bio,
        "profilePhoto" : profilePhoto,
        "createDate" : createDate,
        "uid":uid,



      };
  static User fromSnap(DocumentSnapshot snap){  // veritabanından json formatındaki veriyi dart a çeviiririz
    var snapshot = (snap.data() as Map<String,dynamic>);
    return User(
        email: snapshot["email"],
        username: snap["username"],
        bio: snapshot["bio"],
        profilePhoto: snapshot["profilePhoto"],
      createDate: (snapshot['createDate'] as Timestamp).toDate(),
      uid: snap.id,
    );
  }

}