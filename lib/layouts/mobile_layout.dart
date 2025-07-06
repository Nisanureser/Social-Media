import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media/screens/pageview_screen/Profile_page.dart';
import 'package:social_media/screens/pageview_screen/feed.dart';
import 'package:social_media/screens/pageview_screen/search_page.dart';
import 'package:social_media/utils/colors.dart';
import 'package:social_media/widgets/post_widgets/post_share.dart';

class MobileLayout extends StatefulWidget {
  const MobileLayout({super.key});

  @override
  State<MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends State<MobileLayout> {
  String uid = FirebaseAuth.instance.currentUser!.uid;
  final PageController _pageController = PageController();
  int _page = 0;

  void onChangedPage(int page) {
    setState(() {
      _page = page;
    });
  }

  void nextPage(int page) {
    _pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: onChangedPage,
              children: [
                Feed(key: feedGlobalKey),
                const SearchPage(),
                ProfilePage(uid: FirebaseAuth.instance.currentUser!.uid),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            color: textFieldColor,
            border: Border(
              top: BorderSide(
                width: 1,
                color: waveColor.withOpacity(0.2),
              ),
            )),
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                onPressed: () {
                  nextPage(0);
                },
                icon: Icon(
                  Icons.home_rounded,
                  color: _page == 0 ? Colors.black : null,
                )),
            IconButton(
                onPressed: () {
                  nextPage(1);
                },
                icon: Icon(Icons.search_rounded,
                    color: _page == 1 ? Colors.black : null)),
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
                icon: const Icon(
                  Icons.add_box_outlined,
                )),
            IconButton(
                onPressed: () {
                  nextPage(2);
                },
                icon: Icon(
                    _page != 2
                        ? Icons.account_circle_outlined
                        : Icons.account_circle_rounded,
                    color: _page == 2 ? Colors.black : null)),
          ],
        ),
      ),
    );
  }
}
