import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media/resources/firebase_methods.dart';
import 'package:social_media/utils/colors.dart';
import 'package:social_media/utils/global_class.dart';

class FollowersBuilder extends StatefulWidget {
  const FollowersBuilder({super.key, required this.uid});
  final String uid;

  @override
  State<FollowersBuilder> createState() => _FollowersBuilderState();
}

class _FollowersBuilderState extends State<FollowersBuilder> {
  String myUid = FirebaseAuth.instance.currentUser!.uid;
  List<Map<String, dynamic>> following = [];
  List<String> myFollowing = [];
  bool isLoading = false;

  void getUserfollowing() async {
    setState(() {
      isLoading = true;
    });
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .collection("followers")
        .get()
        .then((value) {
      value.docs.forEach((element) async {
        String? followerUid = element.data()["uid"] as String?;
        if (followerUid != null) {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(followerUid)
              .get()
              .then((userDoc) {
            if (userDoc.exists && userDoc.data() != null) {
              var userData = userDoc.data()!;
              userData["uid"] = userDoc.id;
              following.add(userData);
              setState(() {}); // Rebuild the UI
            }
          });
        }
      });
    });

    getMyFollowing();
  }

  void getMyFollowing() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(myUid)
        .collection("followings")
        .get()
        .then((value) {
      value.docs.forEach((element) async {
        String? followingUid = element.data()["uid"] as String?;
        if (followingUid != null) {
          await FirebaseFirestore.instance
              .collection("users")
              .doc(followingUid)
              .get()
              .then((value) {
            if (value.exists &&
                value.data() != null &&
                value.data()!["uid"] != null) {
              myFollowing.add(value.data()!["uid"]);
              if (mounted) {
                setState(() {}); // Rebuild the UI
              }
            }
          });
        }
      });
    });

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void followOrUnFollow(String uid) async {
    bool response = await FirebaseMethods()
        .followOrUnFollow(myUid, uid, !myFollowing.contains(uid));
    if (response) {
      if (!myFollowing.contains(uid)) {
        myFollowing.add(uid);
      } else {
        myFollowing.removeWhere((element) => element == uid);
      }
      if (mounted) {
        setState(() {});
      }
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
                  "Takipçiler",
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
                                onPressed: () => followOrUnFollow(user["uid"]),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: textFieldColor,
                                  foregroundColor: waveColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  !myFollowing.contains(user["uid"])
                                      ? "Takip Et"
                                      : "Takiptesiniz",
                                ),
                              )
                            : const Text("Siz"), // Here is the correction
                      );
                    },
                  ),
                ),
              ],
            ),
          );
  }
}
