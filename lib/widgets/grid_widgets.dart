import 'package:flutter/material.dart';

class GridItem extends StatelessWidget {
  final String image;

  const GridItem({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(image);
  }
}
