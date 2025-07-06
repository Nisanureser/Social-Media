import 'package:flutter/material.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:social_media/screens/post/photo_description_screen_dart.dart';
import 'package:social_media/utils/colors.dart';
import 'dart:typed_data';
import 'package:social_media/utils/utils.dart';

class PostShare extends StatefulWidget {
  const PostShare({super.key});

  @override
  State<PostShare> createState() => _PostShareState();
}

class _PostShareState extends State<PostShare> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            width: 70,
            height: 10,
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: textColor, borderRadius: BorderRadius.circular(30)),
          ),
        ),
        ListTile(
          onTap: () {
            final theme =
                InstaAssetPicker.themeData(Theme.of(context).primaryColor);
            InstaAssetPicker.pickAssets(
              context,
              pickerTheme: theme.copyWith(
                canvasColor: Colors.black,
                splashColor: Colors.grey,
                colorScheme: theme.colorScheme.copyWith(
                  background: Colors.black87,
                ),
                appBarTheme: theme.appBarTheme.copyWith(
                  backgroundColor: Colors.black,
                  titleTextStyle: Theme.of(context)
                      .appBarTheme
                      .titleTextStyle
                      ?.copyWith(color: Colors.white),
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    disabledForegroundColor: Colors.red,
                  ),
                ),
              ),

              onCompleted: (_) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PhotoDescriptionScreen(
                      photoStream: _,
                    ),
                  ),
                );
              },
              title: ("Yeni gönderi"), // confirm solunda
            );
          },
          title: Text(
            "Gönderi Paylaş",
            style: TextStyle(fontFamily: "Variable"),
          ),
          leading: Icon(
            Icons.photo_camera,
          ),
        ),
        SizedBox(
          height: 8,
        )
      ],
    );
  }
}
