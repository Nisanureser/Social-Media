import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:social_media/utils/colors.dart';

class PhotoClick extends StatefulWidget {
  const PhotoClick({super.key, required this.bytes});
  final Uint8List bytes;  // bellekte resmi saklayan değişken

  @override
  State<PhotoClick> createState() => _PhotoClickState();
}

class _PhotoClickState extends State<PhotoClick> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: textColor, //buton ve ikon rengi
        elevation: 0,  // appbar gölgesi kaldırıyo
      ),
      body: Center(
        child: Image.memory(widget.bytes),  // resim verisi ımage memoryle gösterilecek
      ),
    );
  }
}
