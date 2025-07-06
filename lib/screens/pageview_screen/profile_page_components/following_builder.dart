import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media/resources/firebase_methods.dart';
import 'package:social_media/utils/colors.dart';
import 'package:social_media/utils/global_class.dart';

class FollowingBuilder extends StatefulWidget {
  const FollowingBuilder({super.key, required this.uid});
  final String uid;

  @override
  State<FollowingBuilder> createState() => _FollowingBuilderState();
}

class _FollowingBuilderState extends State<FollowingBuilder> {
  String myUid = FirebaseAuth.instance.currentUser!.uid;
  List<Map<String, dynamic>> following = [];
  List<String> myFollowing = [];
  bool isLoading = false;

  void getUserfollowing() async {
    setState(() {
      isLoading = true;
    });

    final followingsSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .collection("followings")
        .get();

    List<Map<String, dynamic>> tempFollowings = [];

    for (var doc in followingsSnapshot.docs) {
      String followerUid = doc.data()["uid"];
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(followerUid)
          .get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        userData["uid"] = userDoc.id;
        tempFollowings.add(userData);
      }
    }

    final myFollowingSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(myUid)
        .collection("followings")
        .get();

    List<String> tempMyFollowing = myFollowingSnapshot.docs
        .map((doc) => doc.data()["uid"] as String)
        .toList();

    setState(() {
      following = tempFollowings;
      myFollowing = tempMyFollowing;
      isLoading = false;
    });
  }



  void getMyFollowing() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(myUid)
        .collection("followings")
        .get()
        .then((value) {
      value.docs.forEach((element) async {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(element.data()["uid"])
            .get()
            .then((value) {
          myFollowing.add(value.data()!["uid"]);
          setState(() {}); // Rebuild the UI
        });
      });
    });
    setState(() {
      isLoading = false;
    });
  }

  Future<bool> followOrUnFollow(String myUid, String targetUid, bool isFollow) async {
    try {
      if (isFollow) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(myUid)
            .collection("followings")
            .doc(targetUid)
            .set({"uid": targetUid});

        await FirebaseFirestore.instance
            .collection("users")
            .doc(targetUid)
            .collection("followers")
            .doc(myUid)
            .set({"uid": myUid});
      } else {
        // takipten cik
        await FirebaseFirestore.instance
            .collection("users")
            .doc(myUid)
            .collection("followings")
            .doc(targetUid)
            .delete();

        await FirebaseFirestore.instance
            .collection("users")
            .doc(targetUid)
            .collection("followers")
            .doc(myUid)
            .delete();
      }

      return true;
    } catch (e) {
      print("Takip işlemi hatası: $e");
      return false;
    }
  }

  @override
  void initState() {
    getUserfollowing();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const SizedBox(
      height: 300,
      child: Center(child: CircularProgressIndicator()),
    )
        : Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            height: 5,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Takip Edilenler",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: "poppins1",
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: following.length,
              itemBuilder: (context, index) {
                final user = following[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                      user["profilePhoto"],
                      cacheManager: GlobalClass.customCacheManager,
                    ),
                  ),
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user["username"],
                        style: const TextStyle(
                          fontFamily: "poppins1",
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    user["bio"] ?? "",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  trailing: (myUid != user["uid"])
                      ? ElevatedButton(
                    onPressed: () async {
                      bool result = await followOrUnFollow(
                        myUid,
                        user["uid"],
                        !myFollowing.contains(user["uid"]),
                      );

                      if (result) {
                        setState(() {
                          if (!myFollowing.contains(user["uid"])) {
                            myFollowing.add(user["uid"]);
                          } else {
                            myFollowing.remove(user["uid"]);
                          }
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: textFieldColor,
                      foregroundColor: waveColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      !myFollowing.contains(user["uid"]) ? "Takip Et" : "Takibi Bırak",
                    ),
                  )
                      : const Text("Siz"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}