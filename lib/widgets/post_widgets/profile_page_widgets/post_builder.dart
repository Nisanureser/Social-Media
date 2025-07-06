import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:social_media/widgets/post_widgets/profile_page_widgets/PostGridCard.dart';

class PostBuilder extends StatefulWidget {
  const PostBuilder({super.key,
  required this.uid});
  final String uid;

  @override
  State<PostBuilder> createState() => _PostBuilderState();
}

class _PostBuilderState extends State<PostBuilder> {
  String myUid = FirebaseAuth.instance.currentUser!.uid;

  Future<List<DocumentSnapshot>> fetchPosts() async {
    List<DocumentSnapshot> filteredPosts = [];

    QuerySnapshot<Map<String, dynamic>> snap = await FirebaseFirestore.instance
        .collection("Posts")
        .where("verified", isEqualTo: true)
        .get();

    for (var element in snap.docs) {
      List<dynamic> users = List.from(element.data()["users"]);
      for (var user in users) {
        if (user["uid"] == myUid) {
          filteredPosts.add(element);
        }
      }
    }

    return filteredPosts;
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future:
             FirebaseFirestore.instance
            .collection("Posts")
            .where("author", isEqualTo: widget.uid)
            .where("verified", isEqualTo: true)
            .get(),
        builder: (context,snapshot){
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

          return GridView.builder(
            itemCount:(snapshot.data! as dynamic).docs.length,
            gridDelegate: SliverQuiltedGridDelegate(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              repeatPattern: QuiltedGridRepeatPattern.inverted,
              pattern: [
                const QuiltedGridTile(1, 1),
                const QuiltedGridTile(1, 1),
                const QuiltedGridTile(1, 1),
              ],
            ),
            itemBuilder: (context, index) {
              return PostGridCard(
                data:  (snapshot.data as dynamic).docs[index].data()
              );
            },
          );
          },
    );
  }
}
