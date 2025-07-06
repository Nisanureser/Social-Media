import 'package:flutter/material.dart';
import 'package:social_media/utils/colors.dart';
import 'package:social_media/widgets/post_widgets/post_card.dart';

class PostViewerPage extends StatefulWidget {
  const PostViewerPage({
    super.key,
    required this.snap,
  });
  final snap;

  @override
  State<PostViewerPage> createState() => _PostViewerPageState();
}

class _PostViewerPageState extends State<PostViewerPage> {
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Gönderi",
          style: TextStyle(
            color: textColor,
            fontFamily: "poppins1",
          ),
        ),
      ),
      body:PostCard(snap: widget.snap),

    );
  }
}