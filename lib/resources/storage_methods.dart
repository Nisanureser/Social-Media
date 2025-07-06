import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';


class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> uploadImageToStorage(String childName, Uint8List file,
      bool isPost) async {
    Reference ref = _storage.ref().child(childName).child( //childName profilephotos duracak klasör -- child ise dosya ismi dosya ism, kullanıcı uid ile oluşturuyoruz her profil resmi degistiginde varolanla degistiriyoruz
        _auth.currentUser!.uid);

    if (isPost) { //yukleme gönderi mi
      String id = const Uuid().v1();  //postYukleme
      ref = ref.child(id);
    }

    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
    //Firebase Storage referansı alınır ve kullanıcı UID’siyle ilişkilendirilir.
    // Eğer bu bir gönderiyse, bir UUID (benzersiz ID) oluşturulur.
    // Dosya Firebase Storage’a putData ile yüklenir.
    // Yüklemenin ardından, dosyanın indirilebilir URL’si döndürülür.
  }
}
