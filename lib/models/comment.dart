import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String text;
  final String uid;
  final String commentId;
  final String type;
  final DateTime date;
  final String postOwner;

  Comment({
    required this.text,
    required this.uid,
    required this.commentId,
    required this.date,
    required this.type,
    required this.postOwner
  });

  Map<String, dynamic> toJson() => {
    "text": text,
    "uid": uid,
    "commentId": commentId,
    "date": date,
    "type": type,
    "postOwner": postOwner
  };

  static Comment fromSnap(DocumentSnapshot snap) {
    var snapshot = (snap.data() as Map<String, dynamic>);
    return Comment(
      text: snapshot["text"] ?? "",
      uid: snapshot["uid"] ?? "",
      commentId: snapshot["commentId"] ?? "",
      date: snapshot["date"] is Timestamp
          ? (snapshot["date"] as Timestamp).toDate()
          : DateTime.now(),      type: snapshot["type"] ?? "text", // varsaydik
      postOwner: snapshot["postOwner"] ?? "",

    );
  }
}