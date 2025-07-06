import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:social_media/resources/firebase_methods.dart';
import 'package:social_media/screens/pageview_screen/profile_page_components/followers_builder.dart';
import 'package:social_media/screens/pageview_screen/profile_page_components/following_builder.dart';
import 'package:social_media/screens/pageview_screen/profile_page_components/sign_out_alert.dart';
import 'package:social_media/widgets/post_widgets/post_share.dart';
import 'package:social_media/utils/colors.dart';
import 'package:social_media/utils/global_class.dart';
import 'package:social_media/widgets/post_widgets/post_share.dart';
import 'package:social_media/widgets/post_widgets/profile_page_widgets/bio_container.dart';
import 'package:social_media/widgets/post_widgets/profile_page_widgets/edit_profile.dart';
import 'package:social_media/widgets/post_widgets/profile_page_widgets/post_builder.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key, required this.uid});
  final String uid;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String myUid = FirebaseAuth.instance.currentUser!.uid;
  String username = "";
  String profilePhoto = "";
  String bio = "...";
  List<String> followings = [];
  List<String> followers = [];
  int postLength = 0;
  bool isLoaded = false;
  Map<String, dynamic>? userSnap;

  @override
  void initState() {
    super.initState();
    if (widget.uid.isEmpty) {
      print(" HATA: widget.uid boş geldi!");
      return;
    }
    getUserData();
  }

  void getFollowing() async {
    var snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .collection("followings")
        .get();

    followings = snap.docs.map((doc) => doc["uid"].toString()).toList();
    setState(() {});
    getFollowers();
  }

  void getFollowers() async {
    var snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .collection("followers")
        .get();

    followers = snap.docs.map((doc) => doc["uid"].toString()).toList();
    setState(() {});
  }

  void getPost() async {
    var snap = await FirebaseFirestore.instance
        .collection("Posts")
        .where("author", isEqualTo: widget.uid)
        .get();

    setState(() {
      postLength = snap.docs.length;
      isLoaded = true;
    });
  }

  void getUserData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snap = await FirebaseFirestore
          .instance
          .collection("users")
          .doc(widget.uid)
          .get();

      if (!snap.exists || snap.data() == null) {
        print("Kullanıcı bulunamadı: ${widget.uid}");
        return;
      }

      Map<String, dynamic> data = snap.data()!;

      setState(() {
        username = data["username"] ?? "Bilinmeyen";
        profilePhoto = data["profilePhoto"] ?? "";
        bio = data["bio"] ?? "...";
        userSnap = data;
      });

      getFollowing();
      getPost();
    } catch (e) {
      print("Firestore'dan veri çekerken hata oluştu: $e");
    }
  }

  void followOrUnFollow() async {
    bool response = await FirebaseMethods()
        .followOrUnFollow(myUid, widget.uid, !followers.contains(myUid));
    if (response) {
      if (!followers.contains(myUid)) {
        followers.add(myUid);
      } else {
        followers.removeWhere((element) => element == myUid);
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0.0,
        bottomOpacity: 0.0,
        title: Text(
          username,
          style: const TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        elevation: 0.0,
        actions: [
          widget.uid == myUid
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.white,
                          builder: (context) {
                            return const PostShare();
                          },
                        );
                      },
                      icon: const Icon(Icons.add),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.menu_rounded),
                    ),
                  ],
                )
              : const SizedBox(),
        ],
      ),
      body: DefaultTabController(
        length: 1,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: profilePhoto.isNotEmpty
                                    ? CachedNetworkImageProvider(profilePhoto,
                                        cacheManager:
                                            GlobalClass.customCacheManager)
                                    : const AssetImage(
                                            "assets/images/white_screen.png")
                                        as ImageProvider,
                              ),
                              buildStatColumn(postLength, "Gönderi"),
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.white,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20)),
                                    ),
                                    builder: (context) =>
                                        FollowersBuilder(uid: widget.uid),
                                  );
                                },
                                child: buildStatColumn(
                                    followers.length, "Takipçi"),
                              ),
                              GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.white,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20)),
                                      ),
                                      builder: (context) =>
                                          FollowingBuilder(uid: widget.uid),
                                    );
                                  },
                                  child: buildStatColumn(
                                      followings.length, "Takip")),
                            ],
                          ),
                          const SizedBox(height: 10),
                          BioContainer(bio: bio),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              textFieldColor),
                                    ),
                                    onPressed: () {
                                      if (widget.uid == myUid) {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditProfile(snap: userSnap!),
                                          ),
                                        );
                                      } else {
                                        followOrUnFollow();
                                      }
                                    },
                                    child: Text(
                                      widget.uid == myUid
                                          ? "Profili Düzenle"
                                          : (followers.contains(myUid)
                                              ? "Takibi Bırak"
                                              : "Takip Et"),
                                      style: const TextStyle(color: textColor),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                if (widget.uid == myUid)
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                textFieldColor),
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              const SignOutAlert(),
                                        );
                                      },
                                      child: const Text(
                                        "Çıkış Yap",
                                        style: TextStyle(color: textColor),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
          body: Column(
            children: [
              const TabBar(
                indicatorColor: Color(0xFFe491a1),
                tabs: [
                  Tab(
                    icon: Icon(
                      Icons.grid_on_rounded,
                      color: Color(0xFFe491a1),
                    ),
                  )
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    PostBuilder(uid: widget.uid),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Column buildStatColumn(int number, String label) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        number.toString(),
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      Container(
        margin: const EdgeInsets.only(top: 4),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
      ),
    ],
  );
}
