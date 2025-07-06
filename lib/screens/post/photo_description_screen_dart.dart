import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:social_media/resources/firebase_methods.dart';
import 'package:social_media/screens/post/photo_click_screen.dart';
import 'package:social_media/screens/post/users_tag.dart';
import 'package:social_media/utils/colors.dart';
import 'package:social_media/utils/utils.dart';
import 'dart:typed_data';

class PhotoDescriptionScreen extends StatefulWidget {
  //POST YÜKLEME İÇİN3.ADIM GÜNCELLEDİM
  final Stream<InstaAssetsExportDetails> photoStream;

  const PhotoDescriptionScreen({super.key, required this.photoStream});

  @override
  State<PhotoDescriptionScreen> createState() => _PhotoDescriptionScreenState();
}

class _PhotoDescriptionScreenState extends State<PhotoDescriptionScreen> {
  final TextEditingController _controller = TextEditingController();
  String uid = FirebaseAuth.instance.currentUser!.uid;
  bool isComment = false;
  bool isDownload = false;
  bool isUploading = false;
  List<Map> users = [];

  void uploadPost(List<File> croppedFiles) async {
    setState(() {
      isUploading = true;
    });
    List<Uint8List> bytes = [];
    for (var element in croppedFiles) {
      // BURDA KIRPILMIŞ DOSYALARI LİSTE ŞEKLİNDE ALIP FOR DÖNGÜSÜYLE BYTE A DÖNÜŞTÜRDÜM VE BYTE LİSTESİNE EKLEDİM
      var img = element.readAsBytesSync();
      bytes.add(img);
    }

    bool response = await FirebaseMethods().uploadPost(
      _controller.text,
      uid,
      isComment,
      isDownload,
      "",
      "photo",
      //location
      users,
      bytes,
      "",
      //MusicName
      {}, // MusicDate)
    );
    if (response) {
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } else {
      setState(() {
        isUploading = false;
      });
      if (mounted) {
        Utils().showSnackBar("Gönderi paylaşılamadı", context, Colors.red);
      }
    }
  }
  void addUsers(List<Map>userList){
    setState(() {
      users = userList;
    });
  }
  String checkUser(){
    switch(users.length){
      case == 2 :
        return"${users[0]["username"]},${users[1]["username"]}";
      case>2:
        return"${users[0]["username"]},${users[1]["username"]}+${users.length-2}";
      default:
        return "${users[0]["username"]}";


    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      //Scaffold u StreamBuilder la sarmaladım cunku gönderiyi paylastan da snapshot a eristim
        stream: widget.photoStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Icon(Icons.error),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text("Yeni gönderi"),
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: textColor,
            ),
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(

                    height: 300,

                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data!.croppedFiles.length, //
                        itemBuilder: (context, index) {
                          var img = snapshot.data!.croppedFiles[index]
                              .readAsBytesSync();
                          return Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 8.0),
                            child: SizedBox(
                              height: 300,
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PhotoClick(bytes: img),
                                      ),
                                    );
                                  },
                                  child: Image.memory(
                                    img,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      minLines: 1,
                      maxLength: 400,
                      keyboardType: TextInputType.multiline,
                      // asagi inmesi icin yapamadim
                      style: const TextStyle(fontFamily: ""),
                      controller: _controller,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "   Bir açıklama ekle..."),
                    ),
                  ),
                   ListTile(
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=> UsersTag(
                        addUsers: addUsers,
                        users: users,
                      )));
                    },
                    leading: Icon(Icons.people_alt_outlined),
                    title: Text(users.isEmpty?"Kişileri etiketle":checkUser()),
                     trailing: Icon(Icons.arrow_forward_ios_rounded),

                  ),
                ],
              ),
            ),
            bottomSheet: Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all(textFieldColor),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)))),
                  onPressed: () {
                    uploadPost(snapshot.data!.croppedFiles);
                  },
                  child: !isUploading
                      ? const Text(
                    "Gönderiyi Paylaş",
                    style: TextStyle(color: Colors.white),
                  )
                      : SizedBox(
                    height: 40,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  )),
            ),
          );
        });
  }
}
