import 'package:flutter/material.dart';

class BioContainer extends StatefulWidget {
  const BioContainer({
    super.key,
    required this.bio,
  });

  final String bio;

  @override
  State<BioContainer> createState() => _BioContainerState();
}

class _BioContainerState extends State<BioContainer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.bio,

        ),

      ],
    );
  }
}
