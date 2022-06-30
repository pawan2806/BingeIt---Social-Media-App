import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:bingeit/models/info_model.dart';
import 'package:bingeit/screens/signup1.dart';
import 'package:bingeit/components/already_have_an_account_acheck.dart';
import 'package:bingeit/components/rounded_button.dart';
import 'package:bingeit/components/rounded_input_field.dart';
import 'package:bingeit/components/rounded_password_field.dart';
import 'package:google_fonts/google_fonts.dart';


class LoginScreen extends StatefulWidget {
  final Info info;

  LoginScreen({this.info});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(
                      left: 30.0,
                      right: 30.0,
                      top: 40.0,
                    ),
                    height: 400.0,
                    color: Color(0xFFff4b5c),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Icon(
                                Icons.arrow_back,
                                size: 30.0,
                                color: Colors.white,
                              ),
                            ),

                            Text(
                              'Welcome Back',
                              style: GoogleFonts.notoSans(
                                color: Colors.white,
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                          ],
                        ),

                        SizedBox(height: 20.0),
                        Center(
                          child: Hero(
                            tag: infos[0].imageUrl,
                            child: Image(
                              height: 250.0,
                              width: 250.0,
                              image: AssetImage('assets/images/info0.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),



                      ],
                    ),
                  ),

                ],
              ),
              Container(

                height: 340.0,
                transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child :Column(

        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[

          SizedBox(height: 20.0),
          Text(
            "Please Enter Credentials",
            style: GoogleFonts.notoSans(fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
              fontSize: 20.0,
            ),
          ),
          SizedBox(height: 20.0),
          RoundedInputField(
            hintText: "Your Email",

            onChanged: (value) {},
          ),
          RoundedPasswordField(
            onChanged: (value) {},
          ),
          RoundedButton(
            text: "LOGIN",
            press: () {},
          ),
          SizedBox(height: 10.0),
            AlreadyHaveAnAccountCheck(
              press: () {
                Navigator.push(
                  context,
                  PageTransition(type: PageTransitionType.scale, alignment: Alignment.bottomCenter, child: SignScreen()),
                );
            },
            ),
        ],
      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
