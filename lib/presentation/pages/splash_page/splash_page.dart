import 'package:bingeit/application/auth/auth_check/auth_check_bloc.dart';
import 'package:bingeit/presentation/pages/home_page/home_page.dart';
import 'package:bingeit/presentation/pages/sign_up_page/verify_email_page.dart';
import 'package:bingeit/presentation/pages/welcome_page/create_username_page.dart';
import 'package:bingeit/presentation/pages/welcome_page/welcome_page.dart';
import 'package:bingeit/screens/precautions_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


Future<void> saveTokenToDatabase(String token) async {
  // Assume user is logged in for this example
  String userId = FirebaseAuth.instance.currentUser.uid;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .update({
    'tokens': token,
  });
}

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthCheckBloc>().add(
          const AuthCheckEvent.authCheckRequested(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCheckBloc, AuthCheckState>(
      listener: (context, state) {
        state.map(
          initial: (_) {},
          authenticated: (_) async {
            String token=await FirebaseMessaging.instance.getToken();
            await saveTokenToDatabase(token);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
            );
          },
          usernameNotGiven: (_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => CreateUsernamePage(),
              ),
            );
          },
          emailNotVerified: (_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => VerifyEmailPage(),
              ),
            );
          },
          unauthenticated: (_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => MainScreen(),
                // builder: (context) => WelcomePage(),
              ),
            );
          },
        );
      },
      child: Scaffold(
        backgroundColor: Color(0xFF1B1E2B),
        body: SafeArea(
          child: Center(
            child: Column(
              children: [
                Spacer(),
                // Padding(
                //   padding: const EdgeInsets.symmetric(vertical: 20.0),
                //   child: Image.asset(
                //     "assets/splash_logo.PNG",
                //     width: MediaQuery.of(context).size.width * 0.5,
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: CircularProgressIndicator(),
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(vertical: 20.0),
                //   child: const Text("Loading..."),
                // ),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
