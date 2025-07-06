import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:social_media/models/post.dart';
import 'package:social_media/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';
import 'package:social_media/models/comment.dart';

class FirebaseMethods {
  // POST YÜKLEME İÇİN 2.ADIM
  final fire = FirebaseFirestore.instance;

  // final uid = FirebaseAuth.instance.currentUser!.uid;
  Future<bool> uploadPost(
    String description,
    String author,
    bool isComment,
    bool isDownload,
    String music,
    String type,
    List<Map> users,
    List<Uint8List> bytes,
    String musicName,
    Map musicData,
  ) async {
    try {
      List<String> contentUrl = [];
      for (var element in bytes) {
        String url =
            await StorageMethods().uploadImageToStorage("posts", element, true);
        contentUrl.add(url);
      }
      String id = Uuid().v1();
      Post post = Post(
          description: description,
          author: author,
          contentUrl: contentUrl,
          isComment: isComment,
          isDownload: isDownload,
          music: music,
          postId: id,
          publishDate: DateTime.now(),
          type: type,
          verified: true,
          users: users);
      await fire.collection("Posts").doc(id).set(post
          .toJson()); // FİREBASE KAYDETMEK İÇİN Posts adinda koleksiyon yaptık,oraya git bir dosya oluştur adına  oluşturduğumuz id yi verdim ve set dedim
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> likeorUnlike(
      String postId, String uid, String author, bool isLike) async {
    try {
      if (isLike) {
        // begeneceksek
        await fire
            .collection("Posts")
            .doc(postId)
            .collection("likes")
            .doc(uid)
            .set({"uid": uid});
      } else {
        await fire
            .collection("Posts")
            .doc(postId)
            .collection("likes")
            .doc(uid)
            .delete();
      }
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> sendComment(
      String postId, String uid, String text, String type,String postOwner) async {
    try {
      String commentId = Uuid().v1();
      Comment comment = Comment(
        postOwner: postOwner,
          text: text,
          uid: uid,
          commentId: commentId,
          date: DateTime.now(),
          type: type);

      await fire
          .collection("Posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .set(comment.toJson());
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> likeComment(
      String postId, String commentId, String uid, bool isLike) async {
    try {
      if (isLike) {
        await fire
            .collection("Posts")
            .doc(postId)
            .collection("comments")
            .doc(commentId)
            .collection("likes")
            .doc(uid)
            .set({"uid": uid});
      } else {
        await fire
            .collection("Posts")
            .doc(postId)
            .collection("comments")
            .doc(commentId)
            .collection("likes")
            .doc(uid)
            .delete();
      }
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> deleteComment(String postId, String commentId) async {
    try {
      await fire
          .collection("Posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .delete();
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> deletePost(Map snap) async {
    try {
      if (snap["type"] == "photo") {
        for (int i = 0; i < snap["contentUrl"].length; i++) {
          Reference photoRef =
              FirebaseStorage.instance.refFromURL(snap["contentUrl"][i]);
          await photoRef.delete();
        }
      }
      await fire.collection("Posts").doc(snap["postId"]).delete();
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> followOrUnFollow(
      String uid, String userUid, bool isFollow) async {
    try {
      if (isFollow) {
        await fire
            .collection("users")
            .doc(uid)
            .collection("followings")
            .doc(userUid)
            .set({
          "uid": userUid,
        });
        await fire
            .collection("users")
            .doc(userUid)
            .collection("followers")
            .doc(uid)
            .set({
          "uid": uid,
        });
      } else {
        await fire
            .collection("users")
            .doc(uid)
            .collection("followings")
            .doc(userUid)
            .delete();
        await fire
            .collection("users")
            .doc(userUid)
            .collection("followers")
            .doc(uid)
            .delete();
      }
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> editProfile(String uid, String username, String bio,
      Uint8List? image, String profilePhoto) async {
    try {
      String profilePhotoUrl = profilePhoto;
      if (image != null) {
        profilePhotoUrl = await StorageMethods()
            .uploadImageToStorage("ProfilePhotos", image, false);
      }
      await fire.collection("users").doc(uid).update({
        "username": username,
        "bio": bio,
        "profilePhoto": profilePhotoUrl,
      });
      return true;
    } catch (err) {
      return false;
    }
  }
}
