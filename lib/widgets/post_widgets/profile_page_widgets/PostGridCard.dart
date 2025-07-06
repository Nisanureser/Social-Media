import 'package:flutter/material.dart';
import 'package:social_media/screens/push/post_viewer_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostGridCard extends StatelessWidget {
  const PostGridCard({
    super.key,
    required this.data,
  });

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("Grid TIKLANDI");
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PostViewerPage(
              snap: data,
            ),
          ),
        );
      },
      child: AspectRatio(
        aspectRatio: 1,
        child: CachedNetworkImage(
          imageUrl: (data["contentUrl"] != null &&
              data["contentUrl"] is List &&
              data["contentUrl"].isNotEmpty)
              ? data["contentUrl"][0]
              : "https://via.placeholder.com/150",          fit: BoxFit.cover,
          placeholder: (context, url) =>  Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => const Center(
            child: Icon(Icons.broken_image),
          ),
        ),
      ),
    );
  }
}
