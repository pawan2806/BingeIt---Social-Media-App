import 'dart:io';
import 'dart:ui';

import 'package:bingeit/application/auth/sign_in_form/sign_in_form_bloc.dart';
import 'package:bingeit/presentation/pages/sign_up_page/sign_up_page.dart';
import 'package:bingeit/presentation/pages/splash_page/splash_page.dart';
import 'package:bingeit/presentation/pages/welcome_page/forgot_password_page.dart';
import 'package:bingeit/presentation/utilities/utilities.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/rendering.dart';

class InnerShadow extends SingleChildRenderObjectWidget {
  const InnerShadow({
    Key key,
    this.blur = 10,
    this.color = Colors.black38,
    this.offset = const Offset(10, 10),
    Widget child,
  }) : super(key: key, child: child);

  final double blur;
  final Color color;
  final Offset offset;

  @override
  RenderObject createRenderObject(BuildContext context) {
    final _RenderInnerShadow renderObject = _RenderInnerShadow();
    updateRenderObject(context, renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderInnerShadow renderObject) {
    renderObject
      ..color = color
      ..blur = blur
      ..dx = offset.dx
      ..dy = offset.dy;
  }
}

class _RenderInnerShadow extends RenderProxyBox {
  double blur;
  Color color;
  double dx;
  double dy;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;

    final Rect rectOuter = offset & size;
    final Rect rectInner = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      size.width - dx,
      size.height - dy,
    );
    final Canvas canvas = context.canvas..saveLayer(rectOuter, Paint());
    context.paintChild(child, offset);
    final Paint shadowPaint = Paint()
      ..blendMode = BlendMode.srcATop
      ..imageFilter = ImageFilter.blur(sigmaX: blur, sigmaY: blur)
      ..colorFilter = ColorFilter.mode(color, BlendMode.srcOut);

    canvas
      ..saveLayer(rectOuter, shadowPaint)
      ..saveLayer(rectInner, Paint())
      ..translate(dx, dy);
    context.paintChild(child, offset);
    context.canvas..restore()..restore()..restore();
  }
}
class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool isAgreed = false;

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
      backgroundColor: Color(0xFF1B1E2B),
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
                    Padding(
                      padding: const EdgeInsets.only(top: 50.0, bottom: 20),
                      child: Container(
                        height: 200.0,
                        width: 300.0,
                        decoration: new BoxDecoration(
                            gradient: new LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFFFFFFFF),
                                Color(0xFFDBEEFF),
                              ],
                            )),
                        child:  Center(
                          child: Container(

                            height: 150.0,
                            width: 250.0,

                            decoration:  BoxDecoration(

                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                  Radius.circular(60.0) //                 <--- border radius here
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xff9EC1E1),
                                  spreadRadius: 0,
                                  blurRadius: 48.0,
                                  offset: Offset(24,24), // changes position of shadow
                                ),

                              ],
                            ),
                            child: InnerShadow(
                              blur:48,
                              color:Color(0xffB7D9FA),
                              offset: const Offset(-24,-24),
                              child: InnerShadow(
                                blur:24,
                                color:Color(0xffF1FBFF),
                                offset: const Offset(12, 12),

                              ),
                            )
                          ),
                        ),
                      ),
                      // Text(
                      //   "bingeit",
                      //   style: TextStyle(
                      //     fontSize: 40,
                      //     fontWeight: FontWeight.w500,
                      //     color: Color(0xFF6398ff),
                      //   ),
                      // ),
                    ),
                    Text("Discuss your favorite movies with friends"),
                    state.isSubmitting ? LinearProgressIndicator(value: null) : Text(""),
                    Padding(
                      padding: const EdgeInsets.only(left: 25, right: 25, top: 25),
                      child: TextFormField(
                        autocorrect: false,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.email,
                            color: Color(0xFFB100FF),
                          ),
                          labelText: 'Email',
                        ),
                        onChanged: (value) => context.read<SignInFormBloc>().add(
                              SignInFormEvent.emailChanged(value),
                            ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(25),
                      child: TextFormField(
                        autocorrect: false,
                        obscureText: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Color(0xFFB100FF),
                          ),
                          labelText: 'Password',
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
                    Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                          ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0, bottom: 8.0),
                      child: ElevatedButton(
                        style: kAlreadyHaveAccountButton,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SignUpPage(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: "Don't have an account?",
                              style: TextStyle(color: Colors.grey[300]),
                              children: [
                                TextSpan(
                                  text: "\nRegister for free.",
                                  style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey[50]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
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
