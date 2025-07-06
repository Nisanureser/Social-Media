import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:social_media/resources/firebase_methods.dart';
import 'package:social_media/screens/comment/comment_screen.dart';
import 'package:social_media/screens/pageview_screen/Profile_page.dart';
import 'package:social_media/utils/colors.dart';
import 'package:social_media/utils/global_class.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media/utils/utils.dart';
import 'package:social_media/widgets/post_widgets/like_list_modal.dart';
import 'package:social_media/widgets/post_widgets/post_more_sheet.dart';
import 'package:social_media/widgets/post_widgets/tagged_users_sheet.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.snap,
  });

  final snap;

  @override
  State<PostCard> createState() => PostCardState();
}

class PostCardState extends State<PostCard> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String uid = FirebaseAuth.instance.currentUser!.uid;
  String username = "";
  String profilePhoto = "";
  bool showMore = false;
  double photoCurrentIndex = 0;
  List<String> likedList =
      []; //listenin uzunluğuna göre begenme sayısı oluşacak

  void getUserData() async {
    if (widget.snap["author"] != null) {
      try {
        var userSnap = await FirebaseFirestore.instance
            .collection("users")
            .doc(widget.snap["author"]) //kullaniciID
            .get(); // belgeyi getirdim

        if (userSnap.exists) {
          setState(() {
            username = userSnap.data()?["username"] ?? "Bilinmeyen Kullanıcı";
            profilePhoto =
                userSnap.data()?["profilePhoto"] ?? "default_profilePhoto.png";
          });

          print(
              " POST CARD Firestore'dan çekilen author ID: ${widget.snap["author"]}");
        } else {
          print("Kullanıcı bulunamadı!");
        }
      } catch (e) {
        print("Firestore'dan veri çekerken hata oluştu: $e");
      }
    } else {
      print("Hata: widget.snap içinde 'author' alanı yok veya null.");
    }
  }

  void likeorUnlike(bool isLike) async {
    bool response = await FirebaseMethods().likeorUnlike(
      widget.snap["postId"],
      uid,
      widget.snap["author"],
      isLike,
    );
    if (!response) {
      if (mounted) {
        Utils().showSnackBar(
          "Gönderi şu anda beğenilemiyor, sonra tekrar deneyiniz",
          context,
          redColor,
        );
      }
    } else {
      if (isLike) {
        likedList.add(uid);
        print('Gönderi başarıyla beğenildi: ${widget.snap["postId"]}');
      } else {
        likedList.removeWhere((element) => element == uid);
      }

      setState(() {});
    }
  }

  // Dışarıdan erişilebilen beğeni metodu
  void handleLike() {
    print('PostCard -> handleLike metodu çağrıldı');
    _controller.forward();
    if (!likedList.contains(uid)) {
      print('PostCard -> Beğeni işlemi uygulanıyor (UID: $uid)');
      likeorUnlike(true);
    } else {
      print('PostCard -> Bu post zaten beğenilmiş');
    }
  }

  void getPostdata() async {
    await FirebaseFirestore.instance
        .collection("Posts")
        .doc(widget.snap["postId"])
        .collection("likes")
        .get()
        .then((value) {
      for (var element in List.from(value.docs)) {
        likedList.add(element["uid"]);
      }
    });
    if (mounted) {
      setState(() {});
    }
    getUserData();
  }

  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse(); // tekrardan calistirabiliyim diye
      }
    });
    getPostdata();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 10),
        height: 568,
        decoration: BoxDecoration(
            color: textFieldColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        ProfilePage(uid: widget.snap["author"])));
              },
              dense: true,
              leading: profilePhoto != ""
                  ? CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(profilePhoto,
                          cacheManager: GlobalClass
                              .customCacheManager // cabuk yüklemek icin

                          ),
                    )
                  : CircleAvatar(),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    username,
                    //style: TextStyle(fontFamily: "Poppins"),
                  ),
                ],
              ),
              trailing: IconButton(
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(25))),
                      builder: (context) {
                        return PostMoreSheet(snap: widget.snap, uid: uid);
                      });
                },
                icon: const Icon(Icons.more_vert_outlined),
              ),
            ),
            GestureDetector(
              onDoubleTap: () {
                _controller.forward();
                if (!likedList.contains(uid)) {
                  //tekrar begenmemek icin
                  likeorUnlike(true);
                }
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ExpandablePageView(
                    onPageChanged: (value) {
                      setState(() {
                        photoCurrentIndex = value.toDouble();
                      });
                    },
                    children: List.generate(
                      widget.snap["contentUrl"].length,
                      (index) => CachedNetworkImage(
                        cacheManager: GlobalClass.customCacheManager,
                        key: UniqueKey(),
                        memCacheHeight: 800,
                        //bellekte tutulacak resim boyutu
                        imageUrl: widget.snap['contentUrl'][index],

                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        filterQuality: FilterQuality.high,
                        errorWidget: (context, error, stackTrace) {
                          return Center(
                            child: Image.asset(
                              'assets/images/error_.png',
                              fit: BoxFit.cover,
                              height: 300.h,
                            ),
                          );
                        },
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => Center(
                          child: CircularProgressIndicator(
                            value: downloadProgress.progress,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: ScaleTransition(
                        scale: _animation,
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 80,
                        ),
                      ),
                    ),
                  ),
                  widget.snap["users"].isNotEmpty
                      ? Positioned(
                          bottom: 8.0,
                          left: 8.0,
                          child: IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(25))),
                                  context: context,
                                  builder: (context) =>
                                      TaggedUsers(snap: widget.snap));
                            },
                            icon: Icon(Icons.people_alt_rounded),
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    likeorUnlike(!likedList.contains(
                        uid)); // begenmediysek true olcak begendiysek false olcak
                  },
                  icon: Icon(
                    !likedList.contains(uid)
                        ? CupertinoIcons.heart
                        : CupertinoIcons.heart_fill,
                    color: !likedList.contains(uid) ? textColor : redColor,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) =>
                            LikeListModal(likedList: likedList));
                  },
                  child: Text(
                    "${likedList.length}  ",
                    style: TextStyle(
                        fontFamily: "Poppins", fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            CommentScreen(snap: widget.snap)));
                  },
                  icon: const Icon(CupertinoIcons.text_bubble),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.send_outlined),
                ),
                const Spacer(),
                SmoothIndicator(
                  offset: photoCurrentIndex, // degisim yapcaz
                  count: widget.snap["contentUrl"].length,
                  size: const Size(5, 10),
                  effect: const ScrollingDotsEffect(
                    activeDotColor: textColor,
                    activeStrokeWidth: 0.5,
                    dotWidth: 7,
                    dotHeight: 7,
                    fixedCenter: true,
                  ),
                ),
                const Spacer(
                  flex: 3,
                ),
                // Bookmark ikonu
                IconButton(
                  onPressed: () {
                    // Bookmark işlevselliği eklenecek
                  },
                  icon: Icon(
                    Icons.bookmark_border,
                    color: null,
                  ),
                  tooltip: 'Kaydet',
                ),
              ],
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RichText(
                    overflow: !showMore
                        ? TextOverflow.ellipsis
                        : TextOverflow.visible,
                    maxLines: !showMore ? 3 : null,
                    // showmore false sa 3 satır true ysa null
                    text: TextSpan(children: [
                      TextSpan(
                          text: "$username ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: textColor)),
                      TextSpan(
                          text: widget.snap['description'],
                          style: const TextStyle(
                              fontWeight: FontWeight.normal, color: textColor))
                    ])),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    showMore = !showMore;
                  });
                },
                child: Text(
                  !showMore ? "Daha fazla" : "Daha az",
                  style: TextStyle(color: waveColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
