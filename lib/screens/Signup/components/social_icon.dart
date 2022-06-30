import 'package:flutter/material.dart';
import 'package:bingeit/constants.dart';



class SocalIcon extends StatelessWidget {
  final String iconSrc;
  final Function press;
  const SocalIcon({
    Key key,
    this.iconSrc,
    this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: kPrimaryLightColor,
          ),
          shape: BoxShape.circle,
        ),

        child: Image(
          height: 40.0,
          width: 40.0,
          image: AssetImage(
            iconSrc,
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
