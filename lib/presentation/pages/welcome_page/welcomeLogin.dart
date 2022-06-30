import 'dart:io';
import 'dart:ui';

import 'package:bingeit/application/auth/sign_in_form/sign_in_form_bloc.dart';
import 'package:bingeit/constants.dart';
import 'package:bingeit/models/info_model.dart';
import 'package:bingeit/presentation/pages/sign_up_page/sign_up_page.dart';
import 'package:bingeit/presentation/pages/splash_page/splash_page.dart';
import 'package:bingeit/presentation/pages/welcome_page/forgot_password_page.dart';
import 'package:bingeit/presentation/utilities/utilities.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/rendering.dart';

class WelcomeLogin extends StatefulWidget {
  @override
  _WelcomeLoginState createState() => _WelcomeLoginState();
}

class _WelcomeLoginState extends State<WelcomeLogin> {
  bool isAgreed = false;
  bool _obscureText = true;

  void _launchWebPage(BuildContext context) async {
    try {
      if (await canLaunch("https://www.bingeit.com/")) {
        await launch("https://www.bingeit.com/");
      } else {
        throw 'Could not launch web page';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //Color(0xFF1B1E2B),
      body: SafeArea(
        child: BlocConsumer<SignInFormBloc, SignInFormState>(
          listener: (context, state) {
            if (state.errorMessage.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  duration: Duration(seconds: 1),
                ),
              );
            }
            if (state.isAuthStateChanged) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => SplashPage(),
                ),
              );
            }
          },
          builder: (context, state) {
            return ListView(
              children: [
                Column(
                  children: [
                    Stack(
                      children: <Widget>[
                        Container(

                          padding: EdgeInsets.only(
                            left: 15.0,
                            right: 15.0,
                            top: 10.0,
                          ),
                          height: MediaQuery.of(context).size.height * 0.4,
                          color: Colors.white,
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
                                      color: dAccent,
                                    ),
                                  ),

                                  Text(
                                    'Welcome Back',
                                    style: GoogleFonts.lexendExa(
                                      color: dAccent,
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
                                    image: AssetImage('assets/images/info0.jpg',),
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
                      height: MediaQuery.of(context).size.height*0.55,
                      decoration: BoxDecoration(
                        color: darkBG,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(30.0),
                            topLeft: Radius.circular(30.0)),
                      ),
                      child: Column(

                        children: [
                         // Text("Discuss your favorite movies with friends"),

                          state.isSubmitting ? LinearProgressIndicator(value: null) : Text(""),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 25, ),
                              child: Text(

                                'login',
                                style: GoogleFonts.lexendExa(

                                  color: Colors.blueGrey,
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 25, right: 25, top: 15),
                            child: TextFormField(
                              autocorrect: false,

                              cursorColor: Color(0xFF7868E6),
                              decoration: const InputDecoration(
                                hintText: "Your Email",
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: dAccent,
                                ),
                                labelText: 'Email',
                              ),
                              onChanged: (value) => context.read<SignInFormBloc>().add(
                                SignInFormEvent.emailChanged(value),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 25),
                            child: TextFormField(
                              autocorrect: false,
                              cursorColor: Color(0xFF7868E6),
                              obscureText: _obscureText,
                              decoration:  InputDecoration(
                                hintText: 'Enter your password',
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: dAccent,
                                ),
                                labelText: 'Password',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: dAccent,
                                   ),
                                  onPressed: () {
            setState(() => _obscureText= !_obscureText);
            },),

                              ),
                              onChanged: (value) => context.read<SignInFormBloc>().add(
                                SignInFormEvent.passwordChanged(value),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5.0, bottom: 8.0),
                            child: ElevatedButton(
                              style: kNotWatchedButton,
                              onPressed: () {
                                context.read<SignInFormBloc>().add(
                                  SignInFormEvent.signInWithEmailAndPasswordPressed(),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text("Sign In"),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                              );
                            },
                            child: Text(
                              "Forgot password?",
                              style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey[400]),
                            ),
                          ),
                          Divider(
                            color: Colors.black,
                            thickness: 1,
                            indent: MediaQuery.of(context).size.width * 0.1,
                            endIndent: MediaQuery.of(context).size.width * 0.1,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 15, right: 10),
                            child: ListTile(
                              leading: Checkbox(
                                activeColor: Color(0xFF6398ff),
                                value: isAgreed,
                                onChanged: (bool value) {
                                  setState(() {
                                    isAgreed = value;
                                  });
                                },
                              ),
                              title: RichText(
                                text: TextSpan(
                                  text: "I confirm that I am over 18 and I agree to the ",
                                  style: TextStyle(color: Colors.grey[300]),
                                  children: [
                                    TextSpan(
                                      text: "Terms of Use",
                                      style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey[50]),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          _launchWebPage(context);
                                        },
                                    ),
                                    TextSpan(text: " and ", style: TextStyle()),
                                    TextSpan(
                                      text: "Privacy Policy",
                                      style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey[50]),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          _launchWebPage(context);
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: SignInButton(
                              Buttons.GoogleDark,
                              onPressed: () {
                                !isAgreed
                                    ? ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("You need to check the checkbox before continuing"),
                                    duration: Duration(seconds: 1),
                                  ),
                                )
                                    : context.read<SignInFormBloc>().add(
                                  SignInFormEvent.signInWithGooglePressed(),
                                );
                              },
                              text: "Sign In With Google",
                            ),
                          ),

                        ],
                      ),
                    )


                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
