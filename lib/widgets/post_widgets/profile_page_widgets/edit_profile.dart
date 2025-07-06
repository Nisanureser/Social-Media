import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media/resources/auth_methods.dart';
import 'package:social_media/resources/firebase_methods.dart';
import 'package:social_media/utils/colors.dart';
import 'package:social_media/utils/global_class.dart';
import 'package:social_media/utils/utils.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key, required this.snap});

  final Map<String, dynamic> snap;
  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String myUid = FirebaseAuth.instance.currentUser!.uid;
  Uint8List? image;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool isLoading = false;

  void selectProfilePhoto(ImageSource source) async {
    // kullanicinin galeriden veya kameradan foto secmesini sagla
    String? selectedImg = await Utils().pickImage(
        source); // source parametresi kullanicinin resmi nereden sececegini belirliyo(kamera veya galeri) ve utils den pickimage cagir
    if (selectedImg != null && selectedImg.isNotEmpty) {
      CropImage(selectedImg);
    }
  }

  Future<CroppedFile?> CropImage(String path) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: const Color(0xff49605a),
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Cropper',
          ),
          WebUiSettings(
            context: context,
          ),
        ]);
    if (croppedFile != null) {
      image = await croppedFile.readAsBytes();

      setState(() {});
//resmi basarili kirparsak Uint8List formatina dönüstürüp bellege al
    }
  }

  void editProfile() async {
    if (_nameController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      bool response = await FirebaseMethods().editProfile(
          myUid,
          _nameController.text,
          _bioController.text,
          image,
          widget.snap["profilePhoto"]);
      if (mounted) {
        if (response) {
          Utils().showSnackBar(
            "Profil Düzenlendi!",
            context,
            waveColor,
          );
        } else {
          Utils().showSnackBar(
            "Bir Sorun Oluştur!",
            context,
            redColor,
          );
        }
      }
      setState(() {
        isLoading = false;
      });
    } else {
      Utils().showSnackBar(
          "Lütfen gerekli alanları doldurunuz, boş alanlar var!",
          context,
          waveColor);
    }
  }

  @override
  void initState() {
    _nameController.text = widget.snap["username"];
    _bioController.text = widget.snap["bio"];
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text("Düzenle"),

      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Profili Düzenle",
                  style: TextStyle(
                      fontSize: 20,
                      fontFamily: "TextType",
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 15,
                ),
                Stack(
                  children: [
                    image == null
                        ?  CircleAvatar(
                            backgroundColor: textFieldColor,
                            radius: 60,
                            backgroundImage: CachedNetworkImageProvider(
                                widget.snap["profilePhoto"],
                                cacheManager: GlobalClass.customCacheManager),
                          )
                        : CircleAvatar(
                            radius: 60,
                            backgroundImage: MemoryImage(image!),
                          ),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          onTap: () {
                                            selectProfilePhoto(
                                                ImageSource.camera);
                                          },
                                          leading: const Icon(
                                              Icons.camera_alt_outlined),
                                          title: const Text("Fotoğraf Çek"),
                                        ),
                                        ListTile(
                                          onTap: () {
                                            selectProfilePhoto(
                                                ImageSource.gallery);
                                          },
                                          leading: const Icon(
                                              Icons.add_a_photo_outlined),
                                          title: const Text("Galeriden Seç "),
                                        ),
                                      ],
                                    );
                                  });
                            },
                            icon: const Icon(Icons.add_a_photo_outlined))),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: textFieldColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Kullanıcı Adı",
                      prefixIcon: Icon(Icons.account_box_outlined),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: textFieldColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextFormField(
                    controller: _bioController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Bio",
                      prefixIcon: Icon(Icons.switch_account_outlined),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  onPressed: editProfile,
                  child: !isLoading
                      ? const Text(
                          "Kaydet",
                          style: TextStyle(
                              fontFamily: "TextType", color: waveColor),
                        )
                      : const Center(
                          child: CircularProgressIndicator(),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: textFieldColor,
                    foregroundColor: textColor,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
