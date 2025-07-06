import 'package:flutter/material.dart';
import 'package:social_media/resources/firebase_methods.dart';
import 'package:social_media/utils/colors.dart';
import 'package:social_media/utils/utils.dart';

class DeleteComment extends StatefulWidget {
  const DeleteComment({
    super.key,
    required this.uid,
    required this.postId,
    required this.commentId,
    required this.commentAuthor,
    required this.postOwner,
  });

  final String uid;
  final String postId;
  final String commentId;
  final String commentAuthor;
  final String postOwner; // <- DÜZELTİLDİ

  @override
  State<DeleteComment> createState() => _DeleteCommentState();
}

class _DeleteCommentState extends State<DeleteComment> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          onTap: () async {
            if (widget.uid == widget.commentAuthor || widget.uid == widget.postOwner) {
              bool response = await FirebaseMethods()
                  .deleteComment(widget.postId, widget.commentId);
              if (context.mounted) {
                if (response) {
                  Navigator.pop(context); // Sheet kapansın
                  Utils().showSnackBar("Yorum silindi", context, Colors.white);
                } else {
                  Utils().showSnackBar(
                      "Yorum silinirken bir hata oluştu", context, redColor);
                }
              }
            } else {
              Utils().showSnackBar("Bu yorumu silemezsiniz.", context, redColor);
            }
          },
          leading: Icon(Icons.delete),
          title: Text("Yorumu Sil"),
          subtitle: Text("Yorumu Kalıcı Sil"),
        )
      ],
    );
  }
}
