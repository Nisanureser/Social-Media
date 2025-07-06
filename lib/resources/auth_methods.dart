import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:social_media/models/user_info.dart' as model;

import 'package:social_media/resources/storage_methods.dart';
//Kullanıcı kaydı oluşturma sayfası
class AuthMethods{
  final _auth = FirebaseAuth.instance;  //kullanici kimlik dogrulama icin
  final _fire = FirebaseFirestore.instance; // veritabanina yazma /okuma icin

  Future<bool> signInUser(  // kullanici kaydi olusturma islemi
      BuildContext context, // ui erisimleri icin örn hata mesajlarını göstermek
      String email,
      String password,
      String username,
      String bio,
      Uint8List? profilePhoto,) async{
    try {
      UserCredential _cred =  await _auth.createUserWithEmailAndPassword(  //bu metot kullaniciyi firevase authentication üzerinden eposta sifreyle kaydederiz
          email: email,
          password: password);
      
      String photoUrl = "https://cdn-icons-png.flaticon.com/128/847/847969.png";
      if(profilePhoto!= null){
        photoUrl = await StorageMethods().uploadImageToStorage("ProfilePhotos", profilePhoto, false);
      }
      model.User user = model.User(
        username : username,
        bio: bio,
        email: email,
        profilePhoto: photoUrl,
        createDate: DateTime.now(),
        uid: _cred.user!.uid,


      );
      await _fire.collection("users").doc(_cred.user!.uid).set(user.toJson());
    return true;
  } catch (err){

    return false;
  }
  }
  Future<bool>loginUser(String email,String password)async{

    try{
    await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    }catch(err){
      return false;
    }
  }
  Future<bool>signOutUser()async{
    try{
      await _auth.signOut();
      return true;
  } catch(err){
      return false;

    }
  }
}