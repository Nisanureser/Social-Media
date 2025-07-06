
import 'dart:typed_data';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media/resources/auth_methods.dart';
import 'package:social_media/screens/auth/login_page.dart';
import 'package:social_media/utils/colors.dart';
import 'package:social_media/utils/utils.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  Uint8List? image;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Color(0xff49605a),
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

  void createAndSignIn() async {
    if (_nameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _emailController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      bool response = await AuthMethods().signInUser(
        context,
        _emailController.text,
        _passwordController.text,
        _nameController.text,
        _bioController.text,
        image,
      );
      if (mounted) {
        if (response) {
          Utils utils = Utils();
          utils.showSnackBar(
              "Hesap oluşturuldu giriş yapınız", context, waveColor);
        } else {
          Utils utils = Utils();
          utils.showSnackBar("Hesap oluşturulamadı lütfen yeniden deneyiniz.",
              context, errorColor);
        }
      }
      setState(() {
        isLoading = false;
      });
    } else {
      Utils utils = Utils();
      utils.showSnackBar(
          "Lütfen zorunlu alanları doldurunuz.", context, errorColor);
    }
  }

  @override
  void dispose() {
    // sayfa degisince kayit olunca bellekten siliyor
    _nameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Hesap Oluştur",
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
                        ? const CircleAvatar(
                            backgroundColor: textFieldColor,
                            radius: 60,
                            child: Icon(Icons.person),
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
                                          leading:
                                              Icon(Icons.camera_alt_outlined),
                                          title: const Text("Fotoğraf Çek"),
                                        ),
                                        ListTile(
                                          onTap: () {
                                            selectProfilePhoto(
                                                ImageSource.gallery);
                                          },
                                          leading:
                                              Icon(Icons.add_a_photo_outlined),
                                          title: Text("Galeriden Seç "),
                                        ),
                                      ],
                                    );
                                  });
                            },
                            icon: Icon(Icons.add_a_photo_outlined))),
                  ],
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
                    controller: _emailController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "E-mail adresi",
                      prefixIcon: Icon(Icons.mail_outline_outlined),
                    ),
                  ),
                ),
                SizedBox(
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
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Kullanıcı Adı",
                      prefixIcon: Icon(Icons.account_box_outlined),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: textFieldColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true, //sifre yazarken nokta nokta
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Şifre",
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                ),
                SizedBox(
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
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Bio",
                      prefixIcon: Icon(Icons.switch_account_outlined),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  onPressed: createAndSignIn,
                  child: !isLoading
                      ? Text(
                          "Kayıt Ol",
                          style: TextStyle(
                              fontFamily: "TextType", color: waveColor),
                        )
                      : Center(
                    child:CircularProgressIndicator(),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: textFieldColor,
                    foregroundColor: textColor,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Divider(
                        indent: 50,
                        thickness: 1,
                      ),
                    ),
                    const Text(
                      " Hesabınız varsa",
                      style: styleText,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()));
                      },
                      child: const Text("giriş yapın"),
                      style: TextButton.styleFrom(
                        foregroundColor: waveColor,
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        endIndent: 50,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
