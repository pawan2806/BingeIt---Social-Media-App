import 'package:flutter/material.dart';

class CreditsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Color(0xFF1B1E2B),

      body: SafeArea(
        child: Column(

          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          size: 32,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          "Credits",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ],
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Image.asset(
                    "assets/tmdb_logo.png",
                    width: MediaQuery.of(context).size.width * 0.30,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                      "This product uses the TMDb API but is not endorsed in any way by TMDB.",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),

                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
