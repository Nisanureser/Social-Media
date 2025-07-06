import 'package:flutter/material.dart';
import 'package:social_media/utils/colors.dart';

class DeleteWarning extends StatefulWidget {
  const DeleteWarning(
      {super.key, required this.title, required this.description,
        required this.okPress,
        required this.okButtonTitle,
      });

  final String title;
  final String description;
  final String okButtonTitle;
  final VoidCallback okPress;

  @override
  State<DeleteWarning> createState() => _DeleteWarningState();
}

class _DeleteWarningState extends State<DeleteWarning> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: textFieldColor,
      title: Text(widget.title),
      content: Text(widget.description),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "İptal",style: TextStyle(color: textColor),
          ),
        ),
        TextButton(
          onPressed: widget.okPress,
          child: Text(
            widget.okButtonTitle ,style: TextStyle(color: textColor),
          ),
        ),
      ],
    );
  }
}
