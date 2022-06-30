import 'dart:math';

import 'package:bingeit/presentation/pages/splash_page/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bingeit/constants.dart';
import 'package:bingeit/models/info_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bingeit/screens/Signup/components/social_icon.dart';
import 'package:bingeit/components/rounded_button.dart';
import 'package:bingeit/components/rounded_input_field.dart';
import 'package:bingeit/components/rounded_password_field.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

class ItemData {
  final Color color;
  final String image;
  final String text1;
  final String text2;
  final String text3;

  ItemData(this.color, this.image, this.text1, this.text2, this.text3);
}

/// Example of LiquidSwipe with itemBuilder
class WithBuilder extends StatefulWidget {
  @override
  _WithBuilder createState() => _WithBuilder();
}

class _WithBuilder extends State<WithBuilder> {
  int page = 0;
  LiquidController liquidController;
  UpdateType updateType;

  List<ItemData> data = [
    ItemData(Colors.blue, "assets/1.png", "Hi", "It's Me", "Sahdeep"),
    ItemData(Colors.deepPurpleAccent, "assets/1.png", "Take a", "Look At",
        "Liquid Swipe"),
    ItemData(Colors.green, "assets/1.png", "Liked?", "Fork!", "Give Star!"),
    ItemData(Colors.yellow, "assets/1.png", "Can be", "Used for",
        "Onboarding design"),
    ItemData(Colors.red, "assets/1.png", "Do", "try it", "Thank you"),
  ];

  @override
  void initState() {
    liquidController = LiquidController();
    super.initState();
  }

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((page ?? 0) - index).abs(),
      ),
    );
    double zoom = 1.0 + (2.0 - 1.0) * selectedness;
    return new Container(
      width: 25.0,
      child: new Center(
        child: new Material(
          color: Colors.white,
          type: MaterialType.circle,
          child: new Container(
            width: 8.0 * zoom,
            height: 8.0 * zoom,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            LiquidSwipe.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                return Container(
                  width: double.infinity,
                  color: data[index].color,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Image.asset(
                        data[index].image,
                        height: 400,
                        fit: BoxFit.contain,
                      ),
                      Padding(
                        padding: EdgeInsets.all(20.0),
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            data[index].text1,
                            style: stylo,
                          ),
                          Text(
                            data[index].text2,
                            style: stylo,
                          ),
                          Text(
                            data[index].text3,
                            style: stylo,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              positionSlideIcon: 0.8,
              slideIconWidget: Icon(Icons.arrow_back_ios),
              onPageChangeCallback: pageChangeCallback,
              waveType: WaveType.liquidReveal,
              liquidController: liquidController,
              fullTransitionValue: 880,
              enableSideReveal: true,
              enableLoop: true,
              ignoreUserGestureWhileAnimating: true,
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  Expanded(child: SizedBox()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List<Widget>.generate(data.length, _buildDot),
                  ),
                ],
              ),
            ),
            liquidController.currentPage + 1 <= data.length - 1 ?
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: FlatButton(
                  onPressed: () {
                    liquidController.animateToPage(
                        page: data.length - 1, duration: 700);
                  },
                  child: Text("Skip to End"),
                  color: Colors.white.withOpacity(0.01),
                ),
              ),
            ) : SizedBox(height: 0,),
            liquidController.currentPage + 1 <= data.length - 1 ?
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: FlatButton(
                  onPressed: () {
                    liquidController.jumpToPage(
                        page: liquidController.currentPage + 1 > data.length - 1
                            ? 0
                            : liquidController.currentPage + 1);
                  },
                  child: Text("Next"),
                  color: Colors.white.withOpacity(0.01),
                ),
              ),
            ) :  Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: FlatButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: false)
                        .push(
                      MaterialPageRoute(
                        builder: (context) => SplashPage(),
                      ),
                    );
                  },
                  child: Text("Splash Page"),
                  color: Colors.white.withOpacity(0.01),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  pageChangeCallback(int lpage) {
    setState(() {
      page = lpage;
    });
  }
}

///Example of App with LiquidSwipe by providing list of widgets

final stylo = TextStyle(
  fontSize: 30,
  fontFamily: "LexendGiga",
  fontWeight: FontWeight.w600,
);