import 'package:bingeit/constants.dart';
import 'package:bingeit/presentation/pages/welcome_page/welcomeLogin.dart';
import 'package:bingeit/presentation/pages/welcome_page/welcomeSignup.dart';
import 'package:bingeit/presentation/pages/welcome_page/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:bingeit/screens/login1.dart';
import 'package:bingeit/screens/signup1.dart';
import 'package:bingeit/models/info_model.dart';
import 'package:animated_background/animated_background.dart';
import 'package:google_fonts/google_fonts.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  String name = 'Bingeit';
  String tagline="Binge watch then Binge it !";
  final Shader linearGradient = LinearGradient(
    colors: <Color>[darkBG, dAccent],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));
  PageController _pageController;
  int _selectedPage = 0;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: 0, viewportFraction: 0.8);
  }

  _infoSelector(int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (BuildContext context, Widget widget) {
        double value = 1;
        if (_pageController.position.haveDimensions) {
          value = _pageController.page - index;
          value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
        }
        return Center(
          child: SizedBox(
            height: Curves.easeInOut.transform(value) * 500.0,
            width: Curves.easeInOut.transform(value) * 400.0,
            child: widget,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          if(index==0 ){
            Navigator.push(
              context, PageTransition(type: PageTransitionType.scale, alignment: Alignment.bottomCenter, child:  WelcomeLogin(),),
//              MaterialPageRoute(
//                builder: (_) => LoginScreen(),
//              ),
            );

          } else {
            Navigator.push(
              context,
              PageTransition(type: PageTransitionType.scale, alignment: Alignment.bottomCenter, child: WelcomeSignup(),),
            );
          };
//
        },
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40.0),
              ),
              margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 30.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: Column(
                        //mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 15.0),

                          Text(
                            infos[index].category.toUpperCase(),
                            style: GoogleFonts.notoSans(
                              color: darkBG,
                              fontSize: 15.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 5.0),
                          Text(
                            infos[index].name,
                            style: GoogleFonts.notoSans(
                              color: darkBG,
                              fontSize: 25.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),



                        ],
                      ),
                    ),
                    Center(
                      child: Hero(
                        tag: infos[index].imageUrl,
                        child: Image(
                          height: 280.0,
                          width: 280.0,
                          image: AssetImage(
                            'assets/images/info$index.jpg',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),

                    ),





                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBG,






      body: Center(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/edit.png'),
              fit: BoxFit.fill,
            ),
          ),
          alignment: Alignment.center,
          child: AnnotatedRegion<SystemUiOverlayStyle>(

            value: SystemUiOverlayStyle.dark,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,

              children: <Widget>[
                //Image(image: AssetImage('assets/images/back0.jpg')),

                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20.0, bottom: 50.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[

                      Text(
                        "Watch. Recommend.",
                        style: GoogleFonts.lexendMega(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w900,
                            foreground: Paint()..shader = linearGradient
                        ),

                        ),
                      Text(
                        "Discuss. Explore.",
                        style: GoogleFonts.lexendMega(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w900,
                            foreground: Paint()..shader = linearGradient
                        ),

                      ),




                      // GlassmorphicContainer(
                      //   width: MediaQuery.of(context).size.width * 0.9,
                      //   height: 90,
                      //   borderRadius: 20,
                      //   blur: 20,
                      //   alignment: Alignment.bottomCenter,
                      //   border: 2,
                      //   linearGradient: LinearGradient(
                      //       begin: Alignment.topLeft,
                      //       end: Alignment.bottomRight,
                      //       colors: [
                      //         Color(0xFFffffff).withOpacity(0.1),
                      //         Color(0xFFFFFFFF).withOpacity(0.05),
                      //       ],
                      //       stops: [
                      //         0.1,
                      //         1,
                      //       ]),
                      //   borderGradient: LinearGradient(
                      //     begin: Alignment.topLeft,
                      //     end: Alignment.bottomRight,
                      //     colors: [
                      //       Color(0xFFffffff).withOpacity(0.5),
                      //       Color((0xFFFFFFFF)).withOpacity(0.5),
                      //     ],
                      //   ),
                      //   child: Text(
                      //     tagline,
                      //     style: GoogleFonts.lexendGiga(
                      //       textStyle: Theme.of(context).textTheme.display1,
                      //       fontSize: 25,
                      //       color: Colors.grey,
                      //       fontWeight: FontWeight.w700,
                      //     ),
                      //   ),
                      // ),

                    ],
                  ),
                ),

                Container(
                  height: 500.0,

                  width: double.infinity,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (int index) {
                      setState(() {
                        _selectedPage = index;
                      });
                    },
                    itemCount: infos.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _infoSelector(index);
                    },
                  ),
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }
}
