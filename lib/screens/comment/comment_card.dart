import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media/models/comment.dart';
import 'package:social_media/resources/firebase_methods.dart';
import 'package:social_media/screens/comment/comment_delete.dart';
import 'package:social_media/screens/pageview_screen/Profile_page.dart';
import 'package:social_media/utils/colors.dart';
import 'package:social_media/utils/global_class.dart';
import 'package:social_media/utils/utils.dart';

class CommentCard extends StatefulWidget {
  const CommentCard({
    super.key,
    required this.snapshot,
    required this.postSnap,
  });

  final Comment snapshot;
  final postSnap;

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  String profilePhoto = "";
  String username = "";
  String uid = FirebaseAuth.instance.currentUser!.uid;
  List<String> likesList = [];

  void getUserData() async {
    var userSnap = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.snapshot.uid)
        .get();
    username = userSnap.data()!["username"];
    profilePhoto = userSnap.data()!["profilePhoto"];
    setState(() {});
  }

  Future<void> commentLikes() async {
    likesList.clear();
    await FirebaseFirestore.instance
        .collection("Posts")
        .doc(widget.postSnap["postId"])
        .collection("comments")
        .doc(widget.snapshot.commentId)
        .collection("likes")
        .get()
        .then((value) {
      for (var element in value.docs) {
        likesList.add(element.data()["uid"]); // beğeni yapan kullanıcıyı ekle
      }
    });
    setState(() {});
  }

  void likeComment() async {
    bool isLiked = likesList.contains(uid); // Kullanıcının mevcut beğeni durumu

    bool response = await FirebaseMethods().likeComment(
      widget.postSnap["postId"],
      widget.snapshot.commentId,
      uid,
      !isLiked, // Eğer beğenilmediyse ekle beğenildiyse kaldirid
    );

    if (!response) {
      if (mounted) {
        Utils().showSnackBar("Yorum beğenilemedi!", context, redColor);
      }
    } else {
      setState(() {
        if (isLiked) {
          likesList.remove(uid);
        } else {
          likesList.add(uid);
        }
      });
    }
  }

  @override
  void initState() {
    getUserData();
    commentLikes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:  (){
        showModalBottomSheet(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25)
            )
          ),
            context: context,
            builder: (context) =>
                DeleteComment(
                  postOwner: widget.snapshot.postOwner,
                    uid: uid,
                    postId: widget.postSnap["postId"],
                    commentId: widget.snapshot.commentId,
                    commentAuthor: widget.snapshot.uid));
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(uid: widget.snapshot.uid),
                  ),
                );
              },
              child: profilePhoto.isNotEmpty
                  ? CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                  profilePhoto,
                  cacheManager: GlobalClass.customCacheManager,
                ),
              )
                  : const CircleAvatar(),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                  text: "$username ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(text: widget.snapshot.text),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat.yMMMd().add_Hm().format(
                            widget.snapshot.date),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: likeComment,
                  icon: Icon(!likesList.contains(uid)
                      ? CupertinoIcons.heart
                      : CupertinoIcons.heart_fill),
                  color: !likesList.contains(uid) ? null : redColor,
                ),
                Text("${likesList.length}"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
