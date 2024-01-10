import 'package:flutter/material.dart';
import '../data/img.dart';
import '../widget/my_text.dart';
import '../data/my_colors.dart';
import '../data/my_strings.dart';

class NoItem extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(Img.get("app_logo.png"), width: 80, height: 80, color: MyColors.grey_hard,),
        Container(height: 3),
        Text(MyStrings.no_item, style: MyText.subtitle1(context)!.copyWith(
            color: MyColors.grey_hard, fontWeight: FontWeight.bold
        )),
      ],
    );
  }
}