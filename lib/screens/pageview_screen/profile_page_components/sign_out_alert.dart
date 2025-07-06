import 'package:flutter/material.dart';
import 'package:social_media/resources/auth_methods.dart';
import 'package:social_media/screens/auth/login_page.dart';
import 'package:social_media/utils/colors.dart';

class SignOutAlert extends StatelessWidget {
  const SignOutAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: textFieldColor,
      title: const Text("Hesabınızdan Çıkış Yapılsın mı?"),
      content: const Text("Bu hesaptan çıkış yapılacak"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "İptal",style: TextStyle(color: waveColor),
          ),
        ),
        TextButton(
          onPressed: () async {
            await AuthMethods().signOutUser();
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
                    (route) => false);
          },
          child: const Text(
            "Çıkış",style: TextStyle(color: waveColor),
          ),
        ),
      ],
    );
  }
}
