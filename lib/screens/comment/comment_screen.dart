import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media/models/comment.dart';
import 'package:social_media/resources/firebase_methods.dart';
import 'package:social_media/screens/comment/comment_card.dart';
import 'package:social_media/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media/utils/utils.dart';

class CommentScreen extends StatefulWidget {
  const CommentScreen({super.key, required this.snap});

  final snap;

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  Future? future;

  String uid = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _controller = TextEditingController();

  void sendComment() async {
    if (_controller.text.isNotEmpty) {
      bool response = await FirebaseMethods().sendComment(widget.snap["postId"],
          uid, _controller.text, "text", widget.snap["postOwner"]?? "defaultOwner");
      if (!response) {
        if (mounted) {
          Utils().showSnackBar(

              "Yorum Yapılamadı,sonra tekrar deneyiniz", context, redColor);
          print("yorum yapılamadı");
        }
      } else {
        print("yorum başarılı");
        _controller.clear();
        setState(
            () {}); // yorum kutusu temizle future i sonrasinda güncelle yorumu gösterdim
        future = FirebaseFirestore.instance
            .collection("Posts")
            .doc(widget.snap["postId"])
            .collection("comments")
            .get();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Yorumlar",
          style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection("Posts")
            .doc(widget.snap["postId"])
            .collection("comments")
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Henüz yorum yok"));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              Comment comment = Comment.fromSnap(snapshot.data!.docs[index]);

              return CommentCard(
                postSnap: widget.snap,
                snapshot: comment,
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: MediaQuery.of(context)
            .viewInsets, //klavye acilinca sayfayi yukari kaydirdim!!!!!
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.only(left: 8.0, right: 4.0),
          height: 45,
          decoration: BoxDecoration(
            color: textFieldColor,
            borderRadius: BorderRadius.all(Radius.circular(25)),
          ),
          child: TextFormField(
            controller: _controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Yorumunuzu Giriniz",
              suffixIcon: IconButton(
                onPressed: sendComment,
                icon: const Icon(
                  Icons.send_rounded,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
