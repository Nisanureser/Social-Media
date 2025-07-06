import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:social_media/screens/pageview_screen/Profile_page.dart';
import 'package:social_media/utils/colors.dart';

import '../../utils/global_class.dart';

class TaggedUsers extends StatelessWidget {
  const TaggedUsers({super.key, required this.snap});

  final snap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(

      child: Column(
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
    Column(
    children: List.generate(snap["users"].length, (index) {
      return ListTile(
        dense: true,
        leading: GestureDetector(
          onTap: (){
            Navigator.push(
                context,
                MaterialPageRoute(
                builder: (context) => ProfilePage(uid: snap["users"][index]["uid"])));

          },
          child: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(
              snap["users"][index]["profilePhoto"],
              cacheManager: GlobalClass.customCacheManager,
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              snap["users"][index]["username"]
              ,
              style: const TextStyle(

              ),
            ),

          ],
        ),
        isThreeLine: false,


      );},
    ),
    )],
    ),
    );
  }
}
