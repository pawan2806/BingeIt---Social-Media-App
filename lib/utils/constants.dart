import 'package:flutter/material.dart';

Color kPriColor = Color(0xFFECEDF5);
Color kSecondaryColor = Color(0xFF49B584);
Color kAttendance = Color(0xFFBFEB8C);
Color kTodo = Color(0xFFB48CE7);
Color kCirculars = Color(0xFFFDE19B);
Color kTimetable = Color(0xFFFF67A4);
Color kPink = Color(0xFFFF416C);
const kPrimaryColor = Color(0xFF7579e7);
const kPrimaryLightColor = Color(0xFFf8efd4);
const Color blueDark=Color(0xff7868e6);
Color kBlue=Color(0xffb8b5ff);
Color dark = Color(0xFF1B1E2B);
Color darkBG = Color(0xFF1B1E2B);

const kBottomContainerHeight = 80.0;
const kActiveCardColour = Color(0xFF1D1E33);
const kInactiveCardColour = Color(0xFF111328);
const kBottomContainerColour = Color(0xFFEB1555);


class ReusableCard extends StatelessWidget {
  ReusableCard({@required this.colour, this.cardChild, this.onPress});

  final Color colour;
  final Widget cardChild;
  final Function onPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        child: cardChild,
        margin: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: colour,
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
