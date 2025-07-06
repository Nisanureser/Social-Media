import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/painting.dart';
import 'package:social_media/screens/pageview_screen/Profile_page.dart';
import 'package:social_media/utils/colors.dart';
// CONNECTİOM STATE HATA BLOGU EKLİCEM
// TASARIM DEGİSCEM
// GERİ BUTONU EKLE ANASAYFAYA ÇEVİREBİLİRİM
// TIKLAYINCA PROFİLE GİDİCEK


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  String uid = FirebaseAuth.instance.currentUser!.uid;

  String _searchText = "";

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 10.0,


        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () { //ANASAYFAYA DÖNÜŞ YAPABİLİRİM
              if (_searchText.isNotEmpty) {
                setState(() {
                  _controller.clear();
                  _searchText = "";
                });
              }

            },
          ),
        ),

        title: Padding(
          padding: const EdgeInsets.only(left: 0.0),
          child: Container(
            height: 50,
              decoration: BoxDecoration(
                color: textFieldColor,
                borderRadius: BorderRadius.circular(15)
              ),
            child: TextFormField(

              controller: _controller,
              cursorColor: waveColor,
              decoration:  InputDecoration(

                fillColor: textFieldColor,
              border:InputBorder.none,

                hintText: "Kullanıcı Ara",
                hintStyle: TextStyle(fontWeight: FontWeight.w800),
                prefixIcon: Icon(Icons.search_rounded),
              suffixIconColor: waveColor
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value.trim();
                });
              },
            ),
          ),
        ),
      ),
      body: _searchText.isEmpty
          ?  Center(child: Text(""))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .where("username", isGreaterThanOrEqualTo: _searchText)
            .where("username", isLessThan: _searchText + 'z')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return  Center(child: CircularProgressIndicator());
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return  Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;
          if (users.isEmpty) {
            return  Column(mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(child: Text("Kullanıcı bulunamadı",style: TextStyle(fontSize: 20),)),
              ],
            );
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user["profilePhoto"]),
                ),
                title: Text(user["username"]),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage(uid: user.id)));
                },
              );
            },
          );
        },
      ),
    );
  }
}
