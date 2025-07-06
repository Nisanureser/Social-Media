import 'package:cloud_firestore/cloud_firestore.dart';

//post için model oluşturdum   1.ADIM

class Post {
  final String description;
  final String author; //kişi Id
  final List<String> contentUrl; // foto url
  final bool isComment;
  final bool isDownload; //indirme izni
  final String music;
  final String postId;
  final DateTime publishDate; //paylasma zaman
  final String type; // gönderi video mu foto mu
  final bool verified; // gönderi onaylandı mı
  final List<Map> users; //etiketlenen kullanıcı

  Post(
      {required this.description,
        required this.author,
        required this.contentUrl,
        required this.isComment,
        required this.isDownload,
        required this.music,
        required this.postId,
        required this.publishDate,
        required this.type,
        required this.verified,
        required this.users});

  Map<String, dynamic> toJson() => { //json a çevirdik
    'description': description,
    'author': author,
    'contentUrl': contentUrl,
    'isComment': isComment,
    'isDownload': isDownload,
    'music': music,
    'postId': postId,
    'publishDate': publishDate,
    'type': type,
    'verified': verified,
    'users': users,
  };
  static Post fromSnap(DocumentSnapshot snap){   // json u dart a
    var snapshot = (snap.data()as Map<String,dynamic>);
    return Post(
      description: snapshot['description'],
      author: snapshot['author'],
      contentUrl: snapshot['contentUrl'],
      isComment: snapshot['isComment'],
      isDownload: snapshot['isDownload'],
      music: snapshot['music'],
      postId: snapshot['postId'],
      publishDate: (snapshot['publishDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: snapshot['type'],
      verified: snapshot['verified'],
      users: snapshot['users'],
    );

  }
}
