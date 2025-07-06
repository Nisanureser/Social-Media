import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LikeListModal extends StatelessWidget {
  final List<String> likedList;

  const LikeListModal({Key? key, required this.likedList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Container(
          height: 5,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Beğenenler",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: "poppins1",
          ),
        ),
        const SizedBox(height: 12),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: likedList.length,
            itemBuilder: (context, index) {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection("users")
                    .doc(likedList[index])
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(height: 50, child: Center(child: CircularProgressIndicator()));
                  }

                  if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                    return const SizedBox(height: 40, child: Center(child: Text('Kullanıcı bulunamadı')));
                  }

                  var userData = snapshot.data!;
                  String username = userData["username"] ?? "Bilinmeyen";
                  String profilePhoto = userData["profilePhoto"] ?? "default_profilePhoto.png";

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: CachedNetworkImageProvider(profilePhoto),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(username, style: const TextStyle(fontSize: 16)),
                        ),

                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
