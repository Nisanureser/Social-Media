import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media/resources/firebase_methods.dart';
import 'package:social_media/utils/colors.dart';
import 'package:social_media/utils/utils.dart';
import 'package:social_media/widgets/post_widgets/delete_warning.dart';

class PostMoreSheet extends StatefulWidget {
  const PostMoreSheet({super.key, required this.snap, required this.uid});

  final snap;
  final String uid;

  @override
  State<PostMoreSheet> createState() => _PostMoreSheetState();
}

class _PostMoreSheetState extends State<PostMoreSheet> {
  List<String> followings = [];
  Map userSnap = {};

  void deletePost() async {
    bool response = await FirebaseMethods().deletePost(widget.snap);
    if (response) {
      if (mounted) {
        Utils().showSnackBar("Bu gönderi silindi", context, waveColor);
        Navigator.pop(context);
        Navigator.pop(context);
      }
    }
  }

  void getFollowing() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .collection("followings")
        .get()
        .then((value) {
      for (QueryDocumentSnapshot<Map<String, dynamic>> element in value.docs) {
        followings.add(element.data()["uid"]);
        setState(() {});
      }
    });
    setState(() {});
    getUserData();
  }

  void followOrUnFollow() async {
    bool response = await FirebaseMethods().followOrUnFollow(widget.uid,
        widget.snap["author"], !followings.contains(widget.snap["author"]));
    if (response) {
      if (!followings.contains(widget.snap["author"])) {
        followings.add(widget.snap["author"]);
      } else {
        followings.removeWhere((element) => element == widget.snap["author"]);
      }
      setState(() {});
    }
  }

  void getUserData() async {
    var snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.snap["author"])
        .get();
    userSnap = Map.from(snap.data()!);
    setState(() {});
  }

  @override
  void initState() {
    getFollowing();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.uid == widget.snap["author"]
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 10,
                  margin: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: textColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) => DeleteWarning(
                          title: "Bu gönderi silinsin mi?",
                          description: "Gönderi kalıcı olarak silinir",
                          okPress: deletePost,
                          okButtonTitle: "Sil"));
                },
                leading: Icon(Icons.delete),
                title: Text("Gönderiyi Sil"),
                trailing: Icon(Icons.arrow_forward_ios_rounded),
              ),
              ListTile(
                onTap: () => Navigator.pop(context),
                leading: Icon(
                  Icons.arrow_back_ios_new_rounded,
                ),
                title: Text("Geri"),
              ),
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 10,
                  margin: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: textColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              ListTile(
                 onTap: followOrUnFollow ,
                leading: Icon(Icons.add),
                title: Text(!followings.contains(widget.snap["author"])
                    ? "Takip et"
                    : "Takibi Bırak"),
                trailing: Icon(Icons.arrow_forward_ios_rounded),
              )
            ],
          );
  }
}
